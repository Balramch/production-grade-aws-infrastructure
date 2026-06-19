# Create namespace if it doesn't exist
resource "null_resource" "karpenter_namespace" {
  count = var.karpenter_namespace != "kube-system" ? 1 : 0

  triggers = {
    namespace = var.karpenter_namespace
  }

  provisioner "local-exec" {
    command = <<-EOT
      kubectl create namespace ${var.karpenter_namespace} --dry-run=client -o yaml | kubectl apply -f -
    EOT
  }

  depends_on = [data.aws_eks_cluster.this]
}

# Install Karpenter CRDs
resource "null_resource" "karpenter_crds" {
  triggers = {
    cluster_name = var.cluster_name
    version      = var.karpenter_version
  }

  provisioner "local-exec" {
    command = <<-EOT
      kubectl create -f ${path.module}/manifests/karpenter.sh_nodepools.yaml --server-side || true
      kubectl create -f ${path.module}/manifests/karpenter.k8s.aws_ec2nodeclasses.yaml --server-side || true
      kubectl create -f ${path.module}/manifests/karpenter.sh_nodeclaims.yaml --server-side || true
    EOT
  }

  depends_on = [data.aws_eks_cluster.this]
}

# Generate Helm values file
locals {
  helm_values_file = "${path.module}/.helm-values-${md5(jsonencode({
    cluster_name            = var.cluster_name
    interruption_queue      = var.enable_interruption_queue ? aws_sqs_queue.karpenter_interruption[0].name : ""
    controller_role_arn     = aws_iam_role.karpenter_controller.arn
    node_affinity_nodegroups = var.node_affinity_node_groups
  }))}.yaml"
  
  helm_values_content = templatefile("${path.module}/templates/helm-values.yaml.tpl", {
    cluster_name            = var.cluster_name
    interruption_queue      = var.enable_interruption_queue ? aws_sqs_queue.karpenter_interruption[0].name : ""
    controller_role_arn     = aws_iam_role.karpenter_controller.arn
    node_affinity_nodegroups = var.node_affinity_node_groups
  })
}

# Write Helm values file
resource "local_file" "helm_values" {
  content  = local.helm_values_content
  filename = local.helm_values_file
}

# Karpenter Helm Release using local-exec
resource "null_resource" "karpenter_helm" {
  triggers = {
    cluster_name         = var.cluster_name
    karpenter_version    = var.karpenter_version
    controller_role_arn  = aws_iam_role.karpenter_controller.arn
    interruption_queue   = var.enable_interruption_queue ? aws_sqs_queue.karpenter_interruption[0].name : ""
    helm_values          = md5(local.helm_values_content)
    node_groups          = join(",", var.node_affinity_node_groups)
  }

  provisioner "local-exec" {
    command = <<-EOT
      helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
        --version ${var.karpenter_version} \
        --namespace ${var.karpenter_namespace} \
        --create-namespace \
        --values ${local.helm_values_file} \
        --wait
    EOT
  }

  depends_on = [
    null_resource.karpenter_crds,
    aws_iam_role.karpenter_controller,
    null_resource.aws_auth_update,
    local_file.helm_values
  ]
}

# Default EC2NodeClass
locals {
  ec2nodeclass_yaml = yamlencode({
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"
    metadata = {
      name = "default"
    }
    spec = {
      role = aws_iam_role.karpenter_node.name
      amiSelectorTerms = [
        {
          alias = "al2023@v1"
        }
      ]
      subnetSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
      securityGroupSelectorTerms = [
        {
          tags = {
            "karpenter.sh/discovery" = var.cluster_name
          }
        }
      ]
    }
  })
}

resource "null_resource" "karpenter_ec2nodeclass" {
  triggers = {
    node_role_name = aws_iam_role.karpenter_node.name
    cluster_name   = var.cluster_name
    yaml_content   = md5(local.ec2nodeclass_yaml)
  }

  provisioner "local-exec" {
    command = <<-EOT
      cat <<EOF | kubectl apply -f -
${local.ec2nodeclass_yaml}
EOF
    EOT
  }

  depends_on = [
    null_resource.karpenter_crds,
    null_resource.karpenter_helm
  ]
}

# Default NodePool
locals {
  nodepool_yaml = yamlencode({
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata = {
      name = "default"
    }
    spec = {
      template = {
        spec = {
          requirements = concat(
            [
              {
                key      = "kubernetes.io/arch"
                operator = "In"
                values   = var.nodepool_config.instance_architectures
              },
              {
                key      = "kubernetes.io/os"
                operator = "In"
                values   = ["linux"]
              },
              {
                key      = "karpenter.sh/capacity-type"
                operator = "In"
                values   = var.nodepool_config.capacity_types
              },
              {
                key      = "karpenter.k8s.aws/instance-category"
                operator = "In"
                values   = var.nodepool_config.instance_categories
              },
              {
                key      = "karpenter.k8s.aws/instance-generation"
                operator = "Gt"
                values   = [var.nodepool_config.min_instance_generation]
              }
            ]
          )
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = "default"
          }
          expireAfter = var.nodepool_config.expire_after
        }
      }
      limits = {
        cpu = var.nodepool_config.cpu_limit
      }
      disruption = {
        consolidationPolicy = var.nodepool_config.consolidation_policy
        consolidateAfter    = var.nodepool_config.consolidate_after
      }
    }
  })
}

resource "null_resource" "karpenter_nodepool" {
  triggers = {
    cluster_name = var.cluster_name
    yaml_content = md5(local.nodepool_yaml)
  }

  provisioner "local-exec" {
    command = <<-EOT
      cat <<EOF | kubectl apply -f -
${local.nodepool_yaml}
EOF
    EOT
  }

  depends_on = [
    null_resource.karpenter_crds,
    null_resource.karpenter_ec2nodeclass,
    null_resource.karpenter_helm
  ]
}
