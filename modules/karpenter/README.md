# Karpenter Module

This Terraform module deploys Karpenter for automatic node provisioning in an EKS cluster, following the migration guide from Cluster Autoscaler to Karpenter.

## Features

- Creates IAM roles for Karpenter nodes and controller
- Tags subnets and security groups for Karpenter discovery
- Deploys Karpenter using Helm
- Creates default NodePool and EC2NodeClass
- Updates aws-auth ConfigMap to allow Karpenter nodes to join the cluster
- Optional SQS queue for spot interruption handling

## Prerequisites

- Existing EKS cluster
- kubectl configured and authenticated to the cluster
- helm CLI installed
- AWS CLI configured with appropriate permissions

## Usage

```hcl
module "karpenter" {
  source = "./modules/karpenter"
  
  cluster_name      = module.eks.cluster_name
  cluster_version   = var.cluster_version
  project_name      = local.project_name
  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets
  security_group_ids = [
    module.eks.default_secgroup,
    module.eks.eks_api_secgroups[0]
  ]
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  aws_region        = var.aws_region
  
  # Optional: Configure node affinity to run Karpenter on existing node groups
  node_affinity_node_groups = [
    "general-nodes",
    "monitoring-nodes"
  ]
  
  tags = var.common_tags
}
```

## Migration from Cluster Autoscaler

After deploying Karpenter:

1. **Verify Karpenter is running:**
   ```bash
   kubectl get pods -n kube-system -l app.kubernetes.io/name=karpenter
   ```

2. **Scale down Cluster Autoscaler:**
   ```bash
   kubectl scale deploy/cluster-autoscaler -n kube-system --replicas=0
   ```

3. **Scale down existing node groups** (keep minimum nodes for critical workloads):
   ```bash
   aws eks update-nodegroup-config --cluster-name <cluster-name> \
     --nodegroup-name <nodegroup-name> \
     --scaling-config "minSize=2,maxSize=2,desiredSize=2"
   ```

4. **Monitor Karpenter logs:**
   ```bash
   kubectl logs -f -n kube-system -l app.kubernetes.io/name=karpenter -c controller
   ```

5. **Verify new nodes are being created:**
   ```bash
   kubectl get nodes
   ```

## Variables

See `variables.tf` for all available variables and their descriptions.

## Outputs

- `karpenter_node_role_arn` - ARN of the Karpenter node IAM role
- `karpenter_node_role_name` - Name of the Karpenter node IAM role
- `karpenter_controller_role_arn` - ARN of the Karpenter controller IAM role
- `karpenter_controller_role_name` - Name of the Karpenter controller IAM role
- `interruption_queue_name` - Name of the SQS queue for spot interruptions
- `interruption_queue_url` - URL of the SQS queue for spot interruptions

## Notes

- The module uses `null_resource` with `local-exec` for Kubernetes operations, requiring kubectl and helm to be available in your PATH
- Make sure your kubeconfig is configured before running Terraform
- The default NodePool uses spot instances - adjust `nodepool_config` if needed
- Critical workloads (like CoreDNS) should have node affinity to run on existing node groups
