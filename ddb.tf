data "aws_dynamodb_table" "dynamodb_streams_source" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.ddb_trigger) == true
  }
  name = each.value["ddb_trigger_table_name"]

  depends_on = [
    local.lambda_merged
  ]
}

resource "aws_lambda_event_source_mapping" "dynamodb_stream_source_mapping" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.ddb_trigger) == true
  }
  event_source_arn                   = data.aws_dynamodb_table.dynamodb_streams_source[each.key].stream_arn
  function_name                      = format("%s:%s", local.lambda_short_name_to_arn_mapping[each.key], each.value["ddb_trigger_alias"])
  starting_position                  = each.value["ddb_trigger_start_pos"]
  batch_size                         = each.value["ddb_trigger_batch_size"]
  maximum_batching_window_in_seconds = each.value["ddb_trigger_maximum_batching_window_in_seconds"]
  maximum_retry_attempts             = each.value["ddb_trigger_maximum_retry_attempts"]
  maximum_record_age_in_seconds      = each.value["ddb_trigger_maximum_record_age_in_seconds"]
  parallelization_factor             = each.value["ddb_trigger_parallelization_factor"]
  bisect_batch_on_function_error     = tobool(each.value["ddb_trigger_bisect_batch_on_function_error"])

  dynamic "filter_criteria" {
    for_each = lookup(var.ddb_filtering_pattern, each.key, null) == null ? [] : [true]
    content {
      filter {
        pattern = jsonencode(var.ddb_filtering_pattern[each.key])
      }
    }
  }

  depends_on = [
    aws_iam_policy.ddb_policy,
    aws_iam_role_policy_attachment.ddb_policy_attachment
  ]
}

resource "aws_iam_policy" "ddb_policy" {
  for_each = length(keys(data.aws_dynamodb_table.dynamodb_streams_source)) > 0 ? { "create" : true } : {}

  name        = format("DDB-lambda-trigger-policy-%s", local.base_name)
  description = "Dynamo DB access policy for lambda"

  policy = templatefile(format("%s/templates/ddb-policy.json.tmpl", path.module),
  { tableArns = jsonencode([for stream in data.aws_dynamodb_table.dynamodb_streams_source : stream.stream_arn]) })

  depends_on = [
    data.aws_dynamodb_table.dynamodb_streams_source,
  ]
}

resource "aws_iam_role_policy_attachment" "ddb_policy_attachment" {
  for_each   = length(keys(data.aws_dynamodb_table.dynamodb_streams_source)) > 0 ? { "create" : true } : {}
  role       = aws_iam_role.role[0].name
  policy_arn = aws_iam_policy.ddb_policy[each.key].arn

}
