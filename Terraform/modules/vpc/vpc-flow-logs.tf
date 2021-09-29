############################
# VPC flow-logs #
############################
locals {

  # Only create flow log if user selected to create a VPC as well
  enable_flow_log = "${var.create_vpc[local.env]}" && "${var.enable_flow_log[local.env]}"

  create_flow_log_cloudwatch_iam_role  = local.enable_flow_log && "${var.flow_log_destination_type[local.env]}" != "s3" && "${var.create_flow_log_cloudwatch_iam_role[local.env]}"
  create_flow_log_cloudwatch_log_group = local.enable_flow_log && "${var.flow_log_destination_type[local.env]}" != "s3" && "${var.create_flow_log_cloudwatch_log_group[local.env]}"

  flow_log_destination_arn = local.create_flow_log_cloudwatch_log_group ? aws_cloudwatch_log_group.flow_log[0].arn : "${var.flow_log_destination_arn[local.env]}"
  flow_log_iam_role_arn    = "${var.flow_log_destination_type[local.env]}" != "s3" && local.create_flow_log_cloudwatch_iam_role ? aws_iam_role.vpc_flow_log_cloudwatch[0].arn : "${var.flow_log_cloudwatch_iam_role_arn[local.env]}"
}

################################################################################
# Flow Log
################################################################################

resource "aws_flow_log" "this" {
  count = local.enable_flow_log ? 1 : 0

  log_destination_type     = "${var.flow_log_destination_type[local.env]}"
  log_destination          = local.flow_log_destination_arn
  log_format               = "${var.flow_log_log_format[local.env]}"
  iam_role_arn             = local.flow_log_iam_role_arn
  traffic_type             = "${var.flow_log_traffic_type[local.env]}"
  vpc_id                   = local.vpc_id
  max_aggregation_interval = "${var.flow_log_max_aggregation_interval[local.env]}"

  tags = merge("${var.tags[local.env]}", "${var.vpc_flow_log_tags[local.env]}")
}

################################################################################
# Flow Log CloudWatch
################################################################################

resource "aws_cloudwatch_log_group" "flow_log" {
  count = local.create_flow_log_cloudwatch_log_group ? 1 : 0

  name              = "${var.flow_log_cloudwatch_log_group_name_prefix[local.env]}${local.vpc_id}"
  retention_in_days = "${var.flow_log_cloudwatch_log_group_retention_in_days[local.env]}"
  kms_key_id        = "${var.flow_log_cloudwatch_log_group_kms_key_id[local.env]}"

  tags = merge("${var.tags[local.env]}", "${var.vpc_flow_log_tags[local.env]}")
}

resource "aws_iam_role" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  name_prefix          = "vpc-flow-log-role-"
  assume_role_policy   = data.aws_iam_policy_document.flow_log_cloudwatch_assume_role[0].json
  permissions_boundary = "${var.vpc_flow_log_permissions_boundary[local.env]}"

  tags = merge("${var.tags[local.env]}", "${var.vpc_flow_log_tags[local.env]}")
}

data "aws_iam_policy_document" "flow_log_cloudwatch_assume_role" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  statement {
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  role       = aws_iam_role.vpc_flow_log_cloudwatch[0].name
  policy_arn = aws_iam_policy.vpc_flow_log_cloudwatch[0].arn
}

resource "aws_iam_policy" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  name_prefix = "vpc-flow-log-to-cloudwatch-"
  policy      = data.aws_iam_policy_document.vpc_flow_log_cloudwatch[0].json
}

data "aws_iam_policy_document" "vpc_flow_log_cloudwatch" {
  count = local.create_flow_log_cloudwatch_iam_role ? 1 : 0

  statement {
    sid = "AWSVPCFlowLogsPushToCloudWatch"

    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}