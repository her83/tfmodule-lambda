resource "aws_cloudwatch_metric_alarm" "execution_time_warning" {
  for_each            = var.lambda_alarms_actions_enabled[var.environment]["warning"] ? local.lambda_merged : {}
  alarm_name          = format("%s-%s-MaxDurationWarn", local.base_name, local.lambda_merged[each.key]["name"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Maximum"
  threshold           = local.lambda_merged[each.key]["lambda_timeout"] * 1000.0 * local.lambda_merged[each.key]["max_duration_warning_threshold"]
  alarm_description = format("%s[SNOWDESC:WARNING %s] %s-%s Max Duration WARNING Threshold Reached.",
    local.alarm_description_base,
    local.lambda_merged[each.key]["snow_description"],
    local.base_name,
  each.key)
  treat_missing_data = local.lambda_merged[each.key]["execution_time_treat_missing_data"]

  # insufficient_data_actions = [
  #   "${aws_sns_topic.alarms.arn}",
  # ]
  actions_enabled = var.lambda_alarms_actions_enabled[var.environment]["warning"]
  alarm_actions = [
    data.aws_sns_topic.alarm_topic_p4.arn,
  ]

  ok_actions = [
    data.aws_sns_topic.alarm_topic_p4.arn,
  ]

  dimensions = {
    FunctionName = aws_lambda_function.default[each.key].function_name
    Resource     = aws_lambda_function.default[each.key].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "execution_time_high" {
  for_each            = var.lambda_alarms_actions_enabled[var.environment]["high"] ? local.lambda_merged : {}
  alarm_name          = format("%s-%s-MaxDurationHigh", local.base_name, local.lambda_merged[each.key]["name"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Maximum"
  threshold           = local.lambda_merged[each.key]["lambda_timeout"] * 1000.0 * local.lambda_merged[each.key]["max_duration_high_threshold"]
  alarm_description = format("%s[SNOWDESC:HIGH %s] %s-%s Max Duration HIGH Threshold Reached.",
    local.alarm_description_base,
    local.lambda_merged[each.key]["snow_description"],
    local.base_name,
  each.key)
  treat_missing_data = local.lambda_merged[each.key]["execution_time_treat_missing_data"]

  # insufficient_data_actions = [
  #   "${aws_sns_topic.alarms.arn}",
  # ]
  actions_enabled = var.lambda_alarms_actions_enabled[var.environment]["high"]
  alarm_actions = [
    data.aws_sns_topic.alarm_topic_p3.arn,
  ]

  ok_actions = [
    data.aws_sns_topic.alarm_topic_p3.arn,
  ]

  dimensions = {
    FunctionName = aws_lambda_function.default[each.key].function_name
    Resource     = aws_lambda_function.default[each.key].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "execution_time_critical" {
  for_each            = var.lambda_alarms_actions_enabled[var.environment]["critical"] ? local.lambda_merged : {}
  alarm_name          = format("%s-%s-MaxDurationCrit", local.base_name, local.lambda_merged[each.key]["name"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Maximum"
  threshold           = local.lambda_merged[each.key]["lambda_timeout"] * 1000.0 * local.lambda_merged[each.key]["max_duration_critical_threshold"]
  alarm_description = format("%s[SNOWDESC:CRITICAL %s] %s-%s Max Duration CRITICAL Threshold Reached.",
    local.alarm_description_base,
    local.lambda_merged[each.key]["snow_description"],
    local.base_name,
  each.key)
  treat_missing_data = local.lambda_merged[each.key]["execution_time_treat_missing_data"]
  # insufficient_data_actions = [
  #   "${aws_sns_topic.alarms.arn}",
  # ]
  actions_enabled = var.lambda_alarms_actions_enabled[var.environment]["critical"]
  alarm_actions = [
    data.aws_sns_topic.alarm_topic_p2.arn,
  ]

  ok_actions = [
    data.aws_sns_topic.alarm_topic_p2.arn,
  ]

  dimensions = {
    FunctionName = aws_lambda_function.default[each.key].function_name
    Resource     = aws_lambda_function.default[each.key].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "concurrent_execs_warning" {
  for_each = { for k, v in local.lambda_merged : k => v if var.lambda_alarms_actions_enabled[var.environment]["warning"] && lookup(v, "reserved_concurrent_executions", 0) > 0 }

  alarm_name          = format("%s-%s-ConcExecsWarn", local.base_name, local.lambda_merged[each.key]["name"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConcurrentExecutions"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Maximum"
  threshold           = local.lambda_merged[each.key]["reserved_concurrent_executions"] * local.lambda_merged[each.key]["max_concurrent_execs_warning_threshold"]
  alarm_description = format("%s[SNOWDESC:WARNING %s] %s-%s Max Concurrent Executions WARNING Threshold Reached.",
    local.alarm_description_base,
    local.lambda_merged[each.key]["snow_description"],
    local.base_name,
  each.key)
  treat_missing_data = local.lambda_merged[each.key]["concurrent_execs_treat_missing_data"]

  # insufficient_data_actions = [
  #   "${aws_sns_topic.alarms.arn}",
  # ]
  actions_enabled = var.lambda_alarms_actions_enabled[var.environment]["warning"]
  alarm_actions = [
    data.aws_sns_topic.alarm_topic_p4.arn,
  ]

  ok_actions = [
    data.aws_sns_topic.alarm_topic_p4.arn,
  ]

  dimensions = {
    FunctionName = aws_lambda_function.default[each.key].function_name
    Resource     = aws_lambda_function.default[each.key].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "concurrent_execs_high" {
  for_each = { for k, v in local.lambda_merged : k => v if var.lambda_alarms_actions_enabled[var.environment]["high"] && lookup(v, "reserved_concurrent_executions", 0) > 0 }

  alarm_name          = format("%s-%s-ConcExecsHigh", local.base_name, local.lambda_merged[each.key]["name"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConcurrentExecutions"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Maximum"
  threshold           = local.lambda_merged[each.key]["reserved_concurrent_executions"] * local.lambda_merged[each.key]["max_concurrent_execs_high_threshold"]
  alarm_description = format("%s[SNOWDESC:HIGH %s] %s-%s Max Concurrent Executions HIGH Threshold Reached.",
    local.alarm_description_base,
    local.lambda_merged[each.key]["snow_description"],
    local.base_name,
  each.key)
  treat_missing_data = local.lambda_merged[each.key]["concurrent_execs_treat_missing_data"]

  # insufficient_data_actions = [
  #   "${aws_sns_topic.alarms.arn}",
  # ]
  actions_enabled = var.lambda_alarms_actions_enabled[var.environment]["high"]
  alarm_actions = [
    data.aws_sns_topic.alarm_topic_p3.arn,
  ]

  ok_actions = [
    data.aws_sns_topic.alarm_topic_p3.arn,
  ]

  dimensions = {
    FunctionName = aws_lambda_function.default[each.key].function_name
    Resource     = aws_lambda_function.default[each.key].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "concurrent_execs_critical" {
  for_each = { for k, v in local.lambda_merged : k => v if var.lambda_alarms_actions_enabled[var.environment]["critical"] && lookup(v, "reserved_concurrent_executions", 0) > 0 }

  alarm_name          = format("%s-%s-ConcExecsCrit", local.base_name, local.lambda_merged[each.key]["name"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConcurrentExecutions"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Maximum"
  threshold           = local.lambda_merged[each.key]["reserved_concurrent_executions"] * local.lambda_merged[each.key]["max_concurrent_execs_critical_threshold"]
  alarm_description = format("%s[SNOWDESC:CRITICAL %s] %s-%s Max Concurrent Executions CRITICAL Threshold Reached.",
    local.alarm_description_base,
    local.lambda_merged[each.key]["snow_description"],
    local.base_name,
  each.key)
  treat_missing_data = local.lambda_merged[each.key]["concurrent_execs_treat_missing_data"]

  # insufficient_data_actions = [
  #   "${aws_sns_topic.alarms.arn}",
  # ]
  actions_enabled = var.lambda_alarms_actions_enabled[var.environment]["critical"]
  alarm_actions = [
    data.aws_sns_topic.alarm_topic_p2.arn,
  ]


  ok_actions = [
    data.aws_sns_topic.alarm_topic_p2.arn,
  ]

  dimensions = {
    FunctionName = aws_lambda_function.default[each.key].function_name
    Resource     = aws_lambda_function.default[each.key].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "throttles_warning" {
  for_each            = var.lambda_alarms_actions_enabled[var.environment]["warning"] ? local.lambda_merged : {}
  alarm_name          = format("%s-%s-ThrottlesWarn", local.base_name, local.lambda_merged[each.key]["name"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = local.lambda_merged[each.key]["throttles_warning_threshold"]
  alarm_description = format("%s[SNOWDESC:WARNING %s] %s-%s Throttles WARNING Threshold Reached.",
    local.alarm_description_base,
    local.lambda_merged[each.key]["snow_description"],
    local.base_name,
  each.key)
  treat_missing_data = local.lambda_merged[each.key]["throttles_treat_missing_data"]

  # insufficient_data_actions = [
  #   "${aws_sns_topic.alarms.arn}",
  # ]
  actions_enabled = var.lambda_alarms_actions_enabled[var.environment]["warning"]
  alarm_actions = [
    data.aws_sns_topic.alarm_topic_p4.arn,
  ]

  ok_actions = [
    data.aws_sns_topic.alarm_topic_p4.arn,
  ]

  dimensions = {
    FunctionName = aws_lambda_function.default[each.key].function_name
    Resource     = aws_lambda_function.default[each.key].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "throttles_high" {
  for_each            = var.lambda_alarms_actions_enabled[var.environment]["high"] ? local.lambda_merged : {}
  alarm_name          = format("%s-%s-ThrottlesHigh", local.base_name, local.lambda_merged[each.key]["name"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = local.lambda_merged[each.key]["throttles_high_threshold"]
  alarm_description = format("%s[SNOWDESC:HIGH %s] %s-%s Throttles HIGH Threshold Reached.",
    local.alarm_description_base,
    local.lambda_merged[each.key]["snow_description"],
    local.base_name,
  each.key)
  treat_missing_data = local.lambda_merged[each.key]["throttles_treat_missing_data"]

  # insufficient_data_actions = [
  #   "${aws_sns_topic.alarms.arn}",
  # ]
  actions_enabled = var.lambda_alarms_actions_enabled[var.environment]["high"]
  alarm_actions = [
    data.aws_sns_topic.alarm_topic_p3.arn,
  ]

  ok_actions = [
    data.aws_sns_topic.alarm_topic_p3.arn,
  ]

  dimensions = {
    FunctionName = aws_lambda_function.default[each.key].function_name
    Resource     = aws_lambda_function.default[each.key].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "throttles_critical" {
  for_each            = var.lambda_alarms_actions_enabled[var.environment]["critical"] ? local.lambda_merged : {}
  alarm_name          = format("%s-%s-ThrottlesCrit", local.base_name, local.lambda_merged[each.key]["name"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = local.lambda_merged[each.key]["throttles_critical_threshold"]
  alarm_description = format("%s[SNOWDESC:CRITICAL %s] %s-%s Throttles CRITICAL Threshold Reached.",
    local.alarm_description_base,
    local.lambda_merged[each.key]["snow_description"],
    local.base_name,
  each.key)
  treat_missing_data = local.lambda_merged[each.key]["throttles_treat_missing_data"]

  # insufficient_data_actions = [
  #   "${aws_sns_topic.alarms.arn}",
  # ]
  actions_enabled = var.lambda_alarms_actions_enabled[var.environment]["critical"]
  alarm_actions = [
    data.aws_sns_topic.alarm_topic_p2.arn,
  ]


  ok_actions = [
    data.aws_sns_topic.alarm_topic_p2.arn,
  ]

  dimensions = {
    FunctionName = aws_lambda_function.default[each.key].function_name
    Resource     = aws_lambda_function.default[each.key].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "errors_warning" {
  for_each            = var.lambda_alarms_actions_enabled[var.environment]["warning"] ? local.lambda_merged : {}
  alarm_name          = format("%s-%s-ErrorsWarn", local.base_name, local.lambda_merged[each.key]["name"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = local.lambda_merged[each.key]["errors_warning_threshold"]
  alarm_description = format("%s[SNOWDESC:WARNING %s] %s-%s Errors WARNING Threshold Reached.",
    local.alarm_description_base,
    local.lambda_merged[each.key]["snow_description"],
    local.base_name,
  each.key)
  treat_missing_data = local.lambda_merged[each.key]["errors_treat_missing_data"]

  # insufficient_data_actions = [
  #   "${aws_sns_topic.alarms.arn}",
  # ]
  actions_enabled = var.lambda_alarms_actions_enabled[var.environment]["warning"]
  alarm_actions = [
    data.aws_sns_topic.alarm_topic_p4.arn,
  ]

  ok_actions = [
    data.aws_sns_topic.alarm_topic_p4.arn,
  ]

  dimensions = {
    FunctionName = aws_lambda_function.default[each.key].function_name
    Resource     = aws_lambda_function.default[each.key].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "errors_high" {
  for_each            = var.lambda_alarms_actions_enabled[var.environment]["high"] ? local.lambda_merged : {}
  alarm_name          = format("%s-%s-ErrorsHigh", local.base_name, local.lambda_merged[each.key]["name"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = local.lambda_merged[each.key]["errors_high_threshold"]
  alarm_description = format("%s[SNOWDESC:HIGH %s] %s-%s Errors HIGH Threshold Reached.",
    local.alarm_description_base,
    local.lambda_merged[each.key]["snow_description"],
    local.base_name,
  each.key)
  treat_missing_data = local.lambda_merged[each.key]["errors_treat_missing_data"]

  # insufficient_data_actions = [
  #   "${aws_sns_topic.alarms.arn}",
  # ]
  actions_enabled = var.lambda_alarms_actions_enabled[var.environment]["high"]
  alarm_actions = [
    data.aws_sns_topic.alarm_topic_p3.arn,
  ]

  ok_actions = [
    data.aws_sns_topic.alarm_topic_p3.arn,
  ]

  dimensions = {
    FunctionName = aws_lambda_function.default[each.key].function_name
    Resource     = aws_lambda_function.default[each.key].function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "errors_critical" {
  for_each            = var.lambda_alarms_actions_enabled[var.environment]["critical"] ? local.lambda_merged : {}
  alarm_name          = format("%s-%s-ErrorsCrit", local.base_name, local.lambda_merged[each.key]["name"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = local.lambda_merged[each.key]["errors_critical_threshold"]
  alarm_description = format("%s[SNOWDESC:CRITICAL %s] %s-%s Errors CRITICAL Threshold Reached.",
    local.alarm_description_base,
    local.lambda_merged[each.key]["snow_description"],
    local.base_name,
  each.key)
  treat_missing_data = local.lambda_merged[each.key]["errors_treat_missing_data"]

  # insufficient_data_actions = [
  #   "${aws_sns_topic.alarms.arn}",
  # ]
  actions_enabled = var.lambda_alarms_actions_enabled[var.environment]["critical"]
  alarm_actions = [
    data.aws_sns_topic.alarm_topic_p2.arn,
  ]


  ok_actions = [
    data.aws_sns_topic.alarm_topic_p2.arn,
  ]

  dimensions = {
    FunctionName = aws_lambda_function.default[each.key].function_name
    Resource     = aws_lambda_function.default[each.key].function_name
  }
}
# 
# CUSTOM METRIC FILTER
# 
resource "aws_cloudwatch_log_metric_filter" "lambda_custom_filter_metrics_pattern" {
  for_each       = { for rule in var.lambda_alarms_custom_filter_metrics : "${rule.function_name}-${rule.metric_name}" => rule }
  name           = "${local.base_name}-${each.key}-filter"
  pattern        = each.value.metric_pattern
  log_group_name = aws_cloudwatch_log_group.default[each.value.function_name].name

  metric_transformation {
    name      = "custom-${each.value.metric_name}"
    namespace = "${local.base_name}-${each.value.function_name}-ns"
    value     = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_custom_filter_metrics_alarm" {
  depends_on = [
    aws_sns_topic.lambda_custom_filter_metrics_sns
  ]
  for_each                  = { for rule in var.lambda_alarms_custom_filter_metrics : "${rule.function_name}-${rule.metric_name}" => rule }
  alarm_name                = "${local.base_name}-${each.key}-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "custom-${each.value.metric_name}"
  namespace                 = "${local.base_name}-${each.value.function_name}-ns"
  period                    = each.value.alarm_period
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "${each.value.metric_name} - custom filter metric alarm"
  insufficient_data_actions = []
  actions_enabled           = "true"
  alarm_actions             = [aws_sns_topic.lambda_custom_filter_metrics_sns[each.key].arn]
}

resource "aws_sns_topic" "lambda_custom_filter_metrics_sns" {
  depends_on = [
    aws_cloudwatch_log_metric_filter.lambda_custom_filter_metrics_pattern
  ]
  for_each = { for rule in var.lambda_alarms_custom_filter_metrics : "${rule.function_name}-${rule.metric_name}" => rule }
  name     = "${local.base_name}-${each.key}-sns"
}
# 
# 
# 