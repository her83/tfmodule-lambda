resource "aws_cloudwatch_log_subscription_filter" "lambdafunction_logfilter" {
  for_each        = var.lambdafunction_logfilters
  name            = each.value["apploggroup_name"]
  log_group_name  = each.value["apploggroup_name"]
  filter_pattern  = ""
  destination_arn = local.lambda_short_name_to_arn_mapping[each.key]
  distribution    = "Random"
}


resource "aws_lambda_permission" "allow_cloudwatch_to_lambdafunction_logfilter" {
  for_each      = var.lambdafunction_logfilters
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_short_name_to_arn_mapping[each.key]
  principal     = "logs.${var.region}.amazonaws.com"
  source_arn = format("arn:aws:logs:%s:%s:log-group:%s:*",
    var.region,
    data.aws_caller_identity.current.account_id,
  each.value["apploggroup_name"])
}
