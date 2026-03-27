#
# Create an SNS Topic. This topic will be named based on the function it is tied to. The standard naming convention is: org-bag-app_name-<lambda_short_name>-short_region-environment
# This maps exactly to the lambda function naming convention and therefore any SNS topic created for a lambda will essentially have the same name. The writes for cloudwatch successful
# and failed feedback log groups are all set to the lambda role that is created as part of this repository.
#
resource "aws_sns_topic" "sns_lambda_trigger" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if props.sns_trigger == true
  }
  name                                     = format("%s-%s", local.base_name, each.key)
  delivery_policy                          = data.template_file.sns_delivery_policy[each.key].rendered
  application_success_feedback_role_arn    = local.effective_lambda_role_arn
  application_success_feedback_sample_rate = each.value["sns_app_success_sample_rate"]
  application_failure_feedback_role_arn    = local.effective_lambda_role_arn

  http_success_feedback_role_arn    = local.effective_lambda_role_arn
  http_success_feedback_sample_rate = each.value["sns_http_success_sample_rate"]
  http_failure_feedback_role_arn    = local.effective_lambda_role_arn

  lambda_success_feedback_role_arn    = local.effective_lambda_role_arn
  lambda_success_feedback_sample_rate = each.value["sns_lambda_success_sample_rate"]
  lambda_failure_feedback_role_arn    = local.effective_lambda_role_arn

  sqs_success_feedback_role_arn    = local.effective_lambda_role_arn
  sqs_success_feedback_sample_rate = each.value["sns_sqs_success_sample_rate"]
  sqs_failure_feedback_role_arn    = local.effective_lambda_role_arn

  depends_on = [
    aws_lambda_function.default,
    aws_lambda_alias.alias
  ]
}

resource "aws_sns_topic_subscription" "sns_lambda_trigger_sub" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if props.sns_trigger == true
  }
  topic_arn = aws_sns_topic.sns_lambda_trigger[each.key].arn
  protocol  = each.value["sns_protocol"]

  #
  # The calculation of the endpoint here is a bit overloaded because we are allowing the abiltity for the topic subscription to be on a lambda function, or the SQS queue for a lambda function. 
  # This presented a challenge of having to do the lookup into the sqs lambda trigger list by way of name identifier. The index into the sqs queue is done via the local variable `sqs_short_name_to_index_mapping` This is fairly straightforward
  # but due to terraform's limitations, doing a lookup on that map is only valid for values defined in the map. so for example if function A has an SQS queue that map will be populated appropriately for functionA but if functionB does not have
  # an SQS queue then there will be no key for function B. In the case where the subscription for function B is being determined, it, by necessity must be a lambda subscription since there is no SQS defined. One would expect the false portion of
  # the ternary operation to be the piece that needs to be evaluated but Terraform must evaluate all pieces as if they were going to be exercised. So the lookup into the index mapping throws a not found error on the key for functionB. Thus we have to 
  # do a map merge with a dummy value for function B placed into that map. The merge is additive and overwriting so that the first map will hvae any values ovewritten by the second map. 
  #
  endpoint = each.value["sns_protocol"] == "sqs" ? aws_sqs_queue.sqs_lambda_trigger[each.key].arn : format(
    "%s:%s",
    local.lambda_short_name_to_arn_mapping[each.key],
  each.value["sns_trigger_alias"])
  depends_on = [
    aws_sns_topic.sns_lambda_trigger,
    aws_lambda_function.default,
    aws_lambda_alias.alias
  ]
}

resource "aws_cloudwatch_log_group" "sns_default" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if props.sns_trigger == true
  }
  name = format("sns/%s/%s/%s",
    var.region,
    data.aws_caller_identity.current.account_id,
  aws_sns_topic.sns_lambda_trigger[each.key].name)
  retention_in_days = each.value["sns_log_group_retention_in_days"]

  depends_on = [
    aws_sns_topic.sns_lambda_trigger,
    aws_lambda_function.default,
    aws_lambda_alias.alias
  ]
}

resource "aws_cloudwatch_log_group" "sns_default_failure" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if props.sns_trigger == true
  }
  name = format("sns/%s/%s/%s/Failure",
    var.region,
    data.aws_caller_identity.current.account_id,
  aws_sns_topic.sns_lambda_trigger[each.key].name)
  retention_in_days = each.value["sns_log_group_retention_in_days"]

  depends_on = [
    aws_sns_topic.sns_lambda_trigger,
    aws_lambda_function.default,
    aws_lambda_alias.alias
  ]
}

resource "aws_lambda_permission" "sns_lambda_permission" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if props.sns_trigger == true
  }
  statement_id  = format("AllowSNSInvocations_%s", each.key)
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_short_name_to_arn_mapping[each.key]
  qualifier     = each.value["sns_trigger_alias"]
  principal     = "sns.amazonaws.com"

  depends_on = [
    aws_sns_topic.sns_lambda_trigger,
    aws_lambda_function.default,
    aws_lambda_alias.alias
  ]
}


data "template_file" "sns_delivery_policy" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if props.sns_trigger == true
  }
  template = file("templates/sns_delivery_policy.json.tmpl")

  vars = {
    min_delay_target               = each.value["sns_delivery_min_delay_target"]
    max_delay_target               = each.value["sns_delivery_max_delay_target"]
    num_retry                      = each.value["sns_delivery_num_retry"]
    no_delay_retry                 = each.value["sns_delivery_num_no_delays_retry"]
    min_delay_retry                = each.value["sns_delivery_num_min_delays_retry"]
    max_delay_retry                = each.value["sns_delivery_num_max_delays_retry"]
    backoff_function               = each.value["sns_delivery_backoff_function"]
    max_receives_per_second        = each.value["sns_throttle_max_receives_per_second"]
    disable_subscription_overrides = each.value["sns_disable_subscription_overrides"]

  }
}


resource "aws_sns_topic_policy" "sns_lambda_trigger_topic_policy" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if props.sns_trigger == true
  }
  arn    = aws_sns_topic.sns_lambda_trigger[each.key].arn
  policy = data.template_file.sns_policy[each.key].rendered

  depends_on = [
    aws_sns_topic.sns_lambda_trigger,
    aws_lambda_function.default,
    aws_lambda_alias.alias
  ]
}

data "template_file" "sns_policy" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if props.sns_trigger == true
  }
  template = var.sns_custom_access_policy == true ? file(format("custom/sns_policy_%s.json", local.base_name)) : file("templates/sns_policy.json.tmpl")

  vars = {
    dev_prefix   = local.dev_prefix
    app_name     = local.app_name
    org          = var.ownerorg
    bag          = var.bag
    environment  = local.environment_code
    region       = var.region
    short_region = local.short_region
    base_name    = local.base_name
    topic_name   = format("%s-%s", local.base_name, each.key)
    account      = data.aws_caller_identity.current.account_id
    sid          = local.snow_id
  }
}

data "aws_sns_topic" "ext_sns_topic" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if props.ext_sns_trigger == true
  }
  name = each.value["ext_sns_trigger_name"]

  provider = aws.external_trigger
}

resource "aws_sns_topic_subscription" "ext_sns_lambda_trigger_sub" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if props.ext_sns_trigger == true
  }
  topic_arn = data.aws_sns_topic.ext_sns_topic[each.key].arn
  protocol  = each.value["sns_protocol"]
  endpoint  = format("%s:%s", aws_lambda_function.default[each.key].arn, each.value["ext_sns_trigger_alias"])
  depends_on = [
    data.aws_sns_topic.ext_sns_topic,
    null_resource.ext_sns_add_permissions,
    aws_lambda_function.default,
    aws_lambda_alias.alias
  ]

  provider = aws.external_sns_trigger
}

resource "aws_lambda_permission" "ext_sns_lambda_permission" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if props.ext_sns_trigger == true
  }
  statement_id  = format("AllowSNSInvocations_%s", each.key)
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.default[each.key].arn
  qualifier     = each.value["ext_sns_trigger_alias"]
  principal     = "sns.amazonaws.com"

  depends_on = [
    data.aws_sns_topic.ext_sns_topic,
    null_resource.ext_sns_add_permissions,
    aws_lambda_function.default,
    aws_lambda_alias.alias
  ]
}

resource "null_resource" "ext_sns_add_permissions" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if props.ext_sns_trigger == true
  }
  provisioner "local-exec" {
    command     = "sh ${path.module}/scripts/sns_permissions.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      ROLE           = format("arn:aws:iam::%s:role/%s", local.external_trigger_account_id, var.provider_assumed_role)
      SESSION        = format("%s-%s", each.key, uuid())
      TOPIC_ARN      = data.aws_sns_topic.ext_sns_topic[each.key].arn
      NAME           = each.key
      LAMBDA_ACCOUNT = local.provider_account_id
      OPERATION      = "ADD"
      REGION         = var.external_trigger_region != "" ? var.external_trigger_region : var.region
    }
  }

  depends_on = [
    data.aws_sns_topic.ext_sns_topic,
  ]
}

resource "null_resource" "ext_sns_removepermissions" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if props.ext_sns_trigger == true
  }
  provisioner "local-exec" {
    command     = "sh ${path.module}/scripts/sns_permissions.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      ROLE           = format("arn:aws:iam::%s:role/%s", local.external_trigger_account_id, var.provider_assumed_role)
      SESSION        = format("%s-%s", each.key, uuid())
      TOPIC_ARN      = data.aws_sns_topic.ext_sns_topic[each.key].arn
      NAME           = each.key
      LAMBDA_ACCOUNT = local.provider_account_id
      OPERATION      = "REMOVE"
      REGION         = var.external_trigger_region != "" ? var.external_trigger_region : var.region
    }
  }

  depends_on = [
    data.aws_sns_topic.ext_sns_topic,
    null_resource.ext_sns_add_permissions,
    aws_sns_topic_subscription.ext_sns_lambda_trigger_sub,
    aws_lambda_permission.ext_sns_lambda_permission
  ]
}