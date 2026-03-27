# Data source for Kinesis streams
data "aws_kinesis_stream" "kinesis_streams_source" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.kinesis_trigger) == true
  }
  name = each.value["kinesis_trigger_stream_name"]

  depends_on = [
    local.lambda_merged
  ]
}

# Event source mapping for Kinesis streams
resource "aws_lambda_event_source_mapping" "kinesis_event_source_mapping" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.kinesis_trigger) == true
  }
  event_source_arn                   = data.aws_kinesis_stream.kinesis_streams_source[each.key].arn
  function_name                      = format("%s:%s", local.lambda_short_name_to_arn_mapping[each.key], each.value["kinesis_trigger_alias"])
  starting_position                  = "LATEST"
  batch_size                         = each.value["kinesis_trigger_batch_size"]
  maximum_batching_window_in_seconds = each.value["kinesis_trigger_max_batching_window_in_seconds"]
  maximum_record_age_in_seconds      = each.value["kinesis_trigger_max_record_age_in_seconds"]
  maximum_retry_attempts             = each.value["kinesis_trigger_max_retry_attempts"]
  depends_on = [
    aws_lambda_function.default
  ]
}
