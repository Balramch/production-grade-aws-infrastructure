# Update aws-auth ConfigMap to allow Karpenter nodes to join the cluster
# Using null_resource with kubectl since kubernetes provider may not be configured
resource "null_resource" "aws_auth_update" {
  triggers = {
    node_role_arn = aws_iam_role.karpenter_node.arn
    cluster_name  = var.cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      
      # Wait for cluster to be ready
      echo "Waiting for EKS cluster to be ready..."
      kubectl cluster-info > /dev/null 2>&1 || (echo "Error: Cannot connect to cluster. Make sure kubeconfig is configured." && exit 1)
      
      # Get current aws-auth configmap
      kubectl get configmap aws-auth -n kube-system -o yaml > /tmp/aws-auth-${var.cluster_name}.yaml || true
      
      # Check if role already exists
      if grep -q "${aws_iam_role.karpenter_node.arn}" /tmp/aws-auth-${var.cluster_name}.yaml 2>/dev/null; then
        echo "Karpenter node role already exists in aws-auth"
        exit 0
      fi
      
      # Extract current mapRoles
      CURRENT_ROLES=$(kubectl get configmap aws-auth -n kube-system -o jsonpath='{.data.mapRoles}' 2>/dev/null || echo "")
      
      # Add Karpenter node role using kubectl patch
      KARPENTER_ROLE="groups:\n  - system:bootstrappers\n  - system:nodes\nrolearn: ${aws_iam_role.karpenter_node.arn}\nusername: system:node:{{EC2PrivateDNSName}}"
      
      # Try to patch first (works if mapRoles exists)
      kubectl patch configmap aws-auth -n kube-system --type json -p="[{\"op\": \"add\", \"path\": \"/data/mapRoles/-\", \"value\": \"${KARPENTER_ROLE}\"}]" 2>/dev/null || {
        # If patch fails, use apply with full configmap
        echo "Using apply method to update aws-auth..."
        cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
${CURRENT_ROLES}
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: ${aws_iam_role.karpenter_node.arn}
      username: system:node:{{EC2PrivateDNSName}}
EOF
      }
      
      echo "Successfully added Karpenter node role to aws-auth"
    EOT
  }

  depends_on = [
    data.aws_eks_cluster.this,
    aws_iam_role.karpenter_node
  ]
}
