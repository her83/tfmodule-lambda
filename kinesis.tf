data "aws_kinesis_stream" "existing_stream" {
  for_each = var.use_kinesis_stream && local.existing_kinesis_stream_name != "" ? toset([local.existing_kinesis_stream_name]) : toset([])
  name     = each.key
}

resource "aws_kinesis_stream" "stream" {
  count       = var.use_kinesis_stream && local.existing_kinesis_stream_name == "" ? 1 : 0
  name        = format("%s-%s", local.base_name, var.kinesis_stream_suffix_custom != "" ? var.kinesis_stream_suffix_custom : module.global-config.general["account_environments/${var.environment}"])
  shard_count = var.kinesis_stream_mode == "PROVISIONED" ? var.kinesis_shard_count : null

  stream_mode_details {
    stream_mode = var.kinesis_stream_mode
  }
}

resource "aws_cloudwatch_log_subscription_filter" "logfilter" {
  for_each        = var.use_kinesis_stream ? local.lambda_merged : {}
  name            = format("%s-%s", each.key, var.environment)
  role_arn        = format("arn:aws:iam::%s:role/CWLtoKinesisRole", local.account_id)
  log_group_name  = aws_cloudwatch_log_group.default[each.key].name
  filter_pattern  = ""
  destination_arn = local.existing_kinesis_stream_name != "" ? data.aws_kinesis_stream.existing_stream[local.existing_kinesis_stream_name].arn : aws_kinesis_stream.stream[0].arn
}

resource "aws_cloudwatch_log_subscription_filter" "logfilter_sns" {
  for_each        = var.use_kinesis_stream ? local.sns_topics : {}
  name            = format("%s-%s", each.key, var.environment)
  role_arn        = format("arn:aws:iam::%s:role/CWLtoKinesisRole", local.account_id)
  log_group_name  = aws_cloudwatch_log_group.sns_default[each.key].name
  filter_pattern  = ""
  destination_arn = local.existing_kinesis_stream_name != "" ? data.aws_kinesis_stream.existing_stream[local.existing_kinesis_stream_name].arn : aws_kinesis_stream.stream[0].arn
}