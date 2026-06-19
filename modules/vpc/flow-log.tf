# resource "aws_flow_log" "vpc" {
#   count           = var.create_vpc_flow_log ? 1 : 0
#   iam_role_arn    = element(aws_iam_role.vpc[*].arn, count.index)
#   log_destination = element(aws_cloudwatch_log_group.vpc[*].arn, count.index)
#   traffic_type    = "ALL"
#   vpc_id          = aws_vpc.vpc.id
# }

# resource "aws_cloudwatch_log_group" "vpc" {
#   count = var.create_vpc_flow_log ? 1 : 0
#   name  = "${var.project_name}-vpc-log"
# }

resource "aws_iam_role" "vpc" {
  count              = var.create_vpc_flow_log ? 1 : 0
  name               = "${var.project_name}-vpc-flow-log-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "vpc" {
  count  = var.create_vpc_flow_log ? 1 : 0
  name   = "${var.project_name}-vpc-flow-log-policy"
  role   = element(aws_iam_role.vpc[*].id, count.index)
  policy = data.aws_iam_policy_document.vpc.json
}
