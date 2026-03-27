output "lambda_function_invoke_arn" {
  description = "lambda_function_invoke_arn"
  value       = [for lambda in aws_lambda_function.default : lambda.invoke_arn]
}

output "lambda_function_arn" {
  description = "lambda_function_arn"
  value       = [for lambda in aws_lambda_function.default : lambda.arn]
}

output "lambda_function_qualified_arn" {
  description = "lambda_function_qualified_arn"
  value       = [for lambda in aws_lambda_function.default : lambda.qualified_arn]
}

output "lambda_aliases" {
  description = "lambda_aliases"
  value       = [for alias in aws_lambda_alias.alias : alias.arn]
}

output "lambda_alias_names" {
  description = "lambda_alias_names"
  value       = [for alias in aws_lambda_alias.alias : alias.name]
}

output "lambda_alias_function_names" {
  description = "lambda_alias_function_names"
  value       = [for alias in aws_lambda_alias.alias : alias.function_name]
}

# output "lambda_alias_name_to_invoke_arn_map" {
#   value = zipmap(aws_lambda_alias.alias.*.arn, formatlist( "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/%s/invocations", aws_lambda_alias.alias.*.arn))
# }

output "lambda_alias_short_name_list" {
  description = "lambda_alias_short_name_list"
  value       = local.lambda_short_name_to_arn_mapping
}

output "lambda_alias_short_name_to_invoke_arn_mapping" {
  description = "lambda_alias_short_name_to_invoke_arn_mapping"
  value       = local.lambda_alias_short_name_to_invoke_arn_mapping
}

output "lambda_function_short_name_to_arn_mapping" {
  description = "lambda_function_short_name_to_arn_mapping"
  value       = local.lambda_short_name_to_arn_mapping
}

output "lambda_invocation_role_arn" {
  description = "lambda_invocation_role_arn"
  value       = local.effective_invocation_role_arn
}

output "lambda_dlq_arns" {
  description = "lambda_dlq_arns"
  value = { for key, value in aws_sqs_queue.dlq :
    key => value.arn
  }
}

output "lambda_cross_account_allow_invoke_from" {
  description = "lambda_cross_account_allow_invoke_from"
  value       = local.account_cross_product
}

output "lambda_sqs_trigger_arns" {
  description = "lambda_sqs_trigger_arns"
  value = { for key, value in aws_sqs_queue.sqs_lambda_trigger :
    key => value.arn
  }
}

output "lambda_sqs_trigger_ids" {
  description = "lambda_sqs_trigger_ids"
  value = { for key, value in aws_sqs_queue.sqs_lambda_trigger :
    key => value.id
  }
}

output "lambda_sns_trigger_success_log_groups" {
  description = "lambda_sns_trigger_success_log_groups"
  value       = { for key, value in aws_cloudwatch_log_group.sns_default : key => value.arn }
}
output "lambda_sns_trigger_failure_log_groups" {
  description = "lambda_sns_trigger_failure_log_groups"
  value       = { for key, value in aws_cloudwatch_log_group.sns_default_failure : key => value.arn }
}

output "lambda_sns_trigger_arns" {
  description = "lambda_sns_trigger_arns"
  value = { for key, value in aws_sns_topic.sns_lambda_trigger :
    key => value.arn
  }
}

output "lambda_sns_trigger_ids" {
  description = "lambda_sns_trigger_ids"
  value = { for key, value in aws_sns_topic.sns_lambda_trigger :
    key => value.id
  }
}

output "lambda_cloudwatch_trigger_arns" {
  description = "lambda_cloudwatch_trigger_arns"
  value       = [for trigger in aws_cloudwatch_event_rule.scheduled_lambda_trigger : trigger.arn]
}

output "lambda_cloudwatch_dr_trigger_arns" {
  description = "lambda_cloudwatch_dr_trigger_arns"
  value       = [for dr_trigger in aws_cloudwatch_event_rule.scheduled_lambda_trigger_dr : dr_trigger.arn]
}

output "derived_version" {
  description = "Derived version"
  value       = local.derived_version
}

output "kinesis_stream_names" {
  value = [for lambda, props in local.lambda_merged : props.kinesis_trigger_stream_name if tobool(props.kinesis_trigger) == true]
}
