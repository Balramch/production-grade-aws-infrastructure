resource "aws_iam_role" "this" {
  name = "${var.project_name}-ManagedPrometheusEKSPush"

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
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.oidc_url, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(var.oidc_url, "https://", "")}:sub": "system:serviceaccount:${var.prometheus_agent_sa}",
          "${replace(var.oidc_url, "https://", "")}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

  tags = {
    Name = "${var.project_name}-ManagedPrometheusEKSPush"
  }
}

resource "aws_iam_policy" "this" {
  name = "${var.project_name}-APS-Push"
  path        = "/"
  description = "Policy to allow Prometheus on EKS to push to APS"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {"Effect": "Allow",
          "Action": [
            "aps:RemoteWrite", 
            "aps:GetSeries", 
            "aps:GetLabels",
            "aps:GetMetricMetadata"
          ], 
          "Resource": "*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "managed_prometheus_push" {
  role       = aws_iam_role.this.id
  policy_arn = aws_iam_policy.this.arn
}