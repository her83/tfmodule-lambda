resource "aws_lambda_event_source_mapping" "kafka_trigger" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.kafka_trigger) == true
  }
  function_name     = local.lambda_short_name_to_arn_mapping[each.key]
  topics            = try(each.value["kafka_topics"], ["default"])
  starting_position = try(each.value["kafka_starting_position"], "TRIM_HORIZON")

  self_managed_event_source {
    endpoints = {
      KAFKA_BOOTSTRAP_SERVERS = each.value["kafka_bootstrap_servers"]
    }
  }
  dynamic "source_access_configuration" {
    for_each = each.value["kafka_source_access"]

    content {
      type = source_access_configuration.value.type
      uri  = source_access_configuration.value.uri
    }
  }
}
