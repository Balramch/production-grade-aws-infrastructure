resource "aws_iam_role" "this" {
  name = "${var.project_name}-${var.cluster_name}-EKSCluster"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name = "${var.project_name}-${var.cluster_name}-EKSCluster"
  }
}

resource "aws_iam_role" "alb_controller" {
  name = "${var.project_name}-${var.cluster_name}-ALBController"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")}:sub": "system:serviceaccount:${var.alb_controller_sa}",
          "${replace(aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

  tags = {
    Name = "${var.project_name}-${var.cluster_name}-ALBController"
  }
}

resource "aws_iam_role" "argo_workflows" {
  count = var.argo_workflows_sa != null ? 1 : 0

  name = "${var.project_name}-${var.cluster_name}-ArgoWorkflows"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")}:sub": "system:serviceaccount:${var.argo_workflows_sa}",
          "${replace(aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

  tags = {
    Name = "${var.project_name}-${var.cluster_name}-ArgoWorkflows"
  }
}