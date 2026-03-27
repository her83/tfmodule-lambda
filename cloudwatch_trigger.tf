resource "aws_cloudwatch_event_rule" "scheduled_lambda_trigger" {
  for_each            = var.scheduled_lambda_triggers
  name                = format("%s-%s-%s", local.base_name, each.value["lambda_function_base_name"], each.value["name"])
  is_enabled          = each.value["enabled"]
  schedule_expression = format("%s(%s)", each.value["sched_type"], each.value["sched_expression"])
  description         = lookup(each.value, "description", "")

  tags = merge(jsondecode(data.template_file.global_tags_map.rendered), //, 
  jsondecode(data.template_file.tag_maps[each.value["lambda_function_base_name"]].rendered))

  // Worked for me after I added `depends_on`
  depends_on = [
    aws_lambda_function.default
  ]

}

resource "aws_cloudwatch_event_target" "scheduled_lambda_trigger_target" {
  for_each  = var.scheduled_lambda_triggers
  target_id = each.value["name"] // Worked for me after I added `target_id`
  rule      = aws_cloudwatch_event_rule.scheduled_lambda_trigger[each.key].name
  arn       = local.lambda_short_name_to_arn_mapping[each.value["lambda_function_base_name"]]
  input     = each.value["input"]
}

resource "aws_lambda_permission" "scheduled_lambda_trigger_permission" {
  for_each      = var.scheduled_lambda_triggers
  statement_id  = format("AllowExecutionFromCloudWatch_%s", each.value["name"])
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_short_name_to_arn_mapping[each.value["lambda_function_base_name"]]
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled_lambda_trigger[each.key].arn
}


resource "aws_cloudwatch_event_rule" "scheduled_lambda_trigger_dr" {
  for_each            = var.scheduled_lambda_triggers_dr
  provider            = aws.dr
  name                = format("%s-%s-%s", local.base_name, each.value["lambda_function_base_name"], each.value["name"])
  is_enabled          = each.value["enabled"]
  schedule_expression = format("$s(%s)", each.value["sched_type"], each.value["sched_expression"])

  tags = merge(jsondecode(data.template_file.global_tags_map.rendered), //, 
  jsondecode(data.template_file.tag_maps[each.value["lambda_function_base_name"]].rendered))

  // Worked for me after I added `depends_on`
  depends_on = [
    aws_lambda_function.default
  ]

}

resource "aws_cloudwatch_event_target" "scheduled_lambda_trigger_target_dr" {
  for_each  = var.scheduled_lambda_triggers_dr
  provider  = aws
  target_id = each.value["name"] // Worked for me after I added `target_id`
  rule      = aws_cloudwatch_event_rule.scheduled_lambda_trigger[each.key].name
  arn       = local.lambda_short_name_to_arn_mapping[each.value["lambda_function_base_name"]]
  input     = each.value["input"]
}

resource "aws_lambda_permission" "scheduled_lambda_trigger_permission_dr" {
  for_each      = var.scheduled_lambda_triggers_dr
  provider      = aws
  statement_id  = format("AllowExecutionFromCloudWatch_%s", each.value["name"])
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_short_name_to_arn_mapping[each.value["lambda_function_base_name"]]
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled_lambda_trigger[each.key].arn
}

resource "aws_cloudwatch_event_rule" "event_lambda_trigger" {
  for_each      = var.event_lambda_triggers
  name          = format("%s-%s-%s", local.base_name, each.value["lambda_function_base_name"], each.value["name"])
  is_enabled    = each.value["enabled"]
  event_pattern = each.value["event_pattern"]
  description   = lookup(each.value, "description", "")

  tags = merge(jsondecode(data.template_file.global_tags_map.rendered), //, 
  jsondecode(data.template_file.tag_maps[each.value["lambda_function_base_name"]].rendered))

  // Worked for me after I added `depends_on`
  depends_on = [
    aws_lambda_function.default
  ]
}
resource "aws_cloudwatch_event_target" "event_lambda_trigger_target" {
  for_each  = var.event_lambda_triggers
  target_id = each.value["name"] // Worked for me after I added `target_id`
  rule      = aws_cloudwatch_event_rule.event_lambda_trigger[each.key].name
  arn       = local.lambda_short_name_to_arn_mapping[each.value["lambda_function_base_name"]]
}

resource "aws_lambda_permission" "event_lambda_trigger_permission" {
  for_each      = var.event_lambda_triggers
  statement_id  = format("AllowExecutionFromCloudWatch_%s", each.value["name"])
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_short_name_to_arn_mapping[each.value["lambda_function_base_name"]]
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_lambda_trigger[each.key].arn
}
