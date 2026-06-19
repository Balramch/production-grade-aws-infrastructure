resource "aws_iam_role" "this" {
  name = "${var.project_name}-${var.node_group_name}-EKSNodes"

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
    Name = "${var.project_name}-${var.node_group_name}-EKSNodes"
  }
}