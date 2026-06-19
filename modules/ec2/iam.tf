resource "aws_iam_policy" "bastion_eks_api" {
  name        = "bastion_eks_api"
  path        = "/"
  description = "Policy to allow the bastion to authenticate to the EKS API"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : "eks:DescribeCluster",
        "Resource" : var.eks_cluster_arn
      }
    ]
  })
}

resource "aws_iam_policy" "bastion_ssm" {
  name        = "bastion_ssm"
  path        = "/"
  description = "Policy to allow the bastion to authenticate to SSM"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
          "Effect": "Allow",
          "Action": [
              "ssm:DescribeParameters"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": [
              "ssm:GetParameter"
          ],
          "Resource": [
            "arn:aws:ssm:eu-north-1:your_account_id:parameter/blackbelt*"
          ]
      }
    ]
  })
}

resource "aws_iam_role" "bastion_role" {
  name = "bastion_role"

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
    }
  ]
}
EOF
  tags = {
    Name = "${var.project_name}-bastion-role"
  }
}

resource "aws_iam_role_policy_attachment" "bastion_eks_access_attach" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.bastion_eks_api.arn
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_attach" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.bastion_ssm.arn
}