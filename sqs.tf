resource "aws_sqs_queue" "sqs_lambda_trigger" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.sqs_trigger) == true
  }

  name = format("%s-%s%s",
    local.base_name,
    each.value["name"],
  each.value["sqs_fifo_queue"] ? ".fifo" : "")

  // aws recommends a multiplier of 6x for visbility timeout to allow for retries.
  visibility_timeout_seconds = each.value["lambda_timeout"]
  delay_seconds              = each.value["sqs_delay_seconds"]
  max_message_size           = each.value["sqs_max_msg_size"]
  message_retention_seconds  = each.value["sqs_msg_retention_seconds"]
  receive_wait_time_seconds  = each.value["sqs_receive_wait_time_seconds"]

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.value["sqs_redrive_queue_name"]].arn
    maxReceiveCount     = tonumber(each.value["sqs_redrive_max_recv_count"])
  })

  policy                      = data.template_file.sqs_write_policy[each.key].rendered
  fifo_queue                  = each.value["sqs_fifo_queue"]
  content_based_deduplication = each.value["sqs_content_based_deduplication"]
  sqs_managed_sse_enabled     = each.value["sqs_managed_sse_enabled"]

  tags = merge(jsondecode(data.template_file.global_tags_map.rendered),
  jsondecode(data.template_file.tag_maps[each.key].rendered))
}

resource "aws_lambda_event_source_mapping" "sqs_lambda_event_source" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.sqs_trigger) == true
  }
  event_source_arn                   = aws_sqs_queue.sqs_lambda_trigger[each.key].arn
  function_name                      = format("%s:%s", aws_lambda_function.default[each.key].arn, each.value["sqs_trigger_alias"])
  batch_size                         = each.value["sqs_batch_size"]
  function_response_types            = each.value["sqs_function_response_types"]
  maximum_batching_window_in_seconds = strcontains(aws_sqs_queue.sqs_lambda_trigger[each.key].arn, ".fifo") ? null : each.value["sqs_max_batching_window_in_seconds"]

  dynamic "filter_criteria" {
    for_each = lookup(var.sqs_filtering_pattern, each.key, null) == null ? [] : [true]
    content {
      filter {
        pattern = jsonencode(var.sqs_filtering_pattern[each.key])
      }
    }
  }

}

data "template_file" "sqs_write_policy" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.sqs_trigger) == true
  }
  template = var.custom_sqs_write_policy == true ? file(format("custom/sqs_write_policy_%s.json", local.base_name)) : file("templates/sqs_policy.json.tmpl")

  vars = {
    dev_prefix   = local.dev_prefix
    app_name     = local.app_name
    org          = var.ownerorg
    bag          = var.bag
    environment  = local.environment_code
    region       = var.region
    short_region = local.short_region
    base_name    = local.base_name
    queue_name = format("%s-%s%s",
      local.base_name,
      each.value["name"],
    each.value["sqs_fifo_queue"] ? ".fifo" : "")
    account = local.account_id
    sid     = local.snow_id
  }
}

################################################################################
#
#   
#   External SQS Trigger resources
#    
#
################################################################################
data "aws_sqs_queue" "ext_sqs_queue" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.ext_sqs_trigger) == true
  }
  name = each.value["ext_sqs_trigger_name"]

  provider = aws.external_trigger
}

resource "aws_lambda_event_source_mapping" "ext_sqs_lambda_event_source" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.ext_sqs_trigger) == true
  }
  event_source_arn                   = data.aws_sqs_queue.ext_sqs_queue[each.key].arn
  function_name                      = format("%s:%s", aws_lambda_function.default[each.key].arn, each.value["ext_sqs_trigger_alias"])
  batch_size                         = each.value["ext_sqs_trigger_batch_size"]
  function_response_types            = each.value["ext_sqs_function_response_types"]
  maximum_batching_window_in_seconds = strcontains(data.aws_sqs_queue.ext_sqs_queue[each.key].arn, ".fifo") ? null : each.value["ext_sqs_max_batching_window_in_seconds"]

  dynamic "filter_criteria" {
    for_each = lookup(var.ext_sqs_filtering_pattern, each.key, null) == null ? [] : [true]
    content {
      filter {
        pattern = jsonencode(var.ext_sqs_filtering_pattern[each.key])
      }
    }
  }

  depends_on = [
    null_resource.ext_sqs_set_permissions,
    data.aws_sqs_queue.ext_sqs_queue,
    aws_iam_role.role
  ]
}

resource "null_resource" "ext_sqs_set_permissions" {
  for_each = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.ext_sqs_trigger) == true
  }
  provisioner "local-exec" {
    command     = "sh ${path.module}/scripts/sqs_permissions.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      ROLE           = format("arn:aws:iam::%s:role/%s", local.external_trigger_account_id, var.provider_assumed_role)
      SESSION        = format("%s-%s", each.key, uuid())
      QUEUE_URL      = data.aws_sqs_queue.ext_sqs_queue[each.key].url
      NAME           = each.key
      LAMBDA_ACCOUNT = local.provider_account_id
      REGION         = var.region
    }
  }

  depends_on = [
    data.aws_sqs_queue.ext_sqs_queue
  ]
}

resource "aws_iam_policy" "ext_sqs_policy" {
  for_each = length(keys(data.aws_sqs_queue.ext_sqs_queue)) > 0 ? { "create" : true } : {}

  name        = var.ext_sqs_policy_name
  description = "SQS access policy for lambda"

  policy = templatefile(format("%s/templates/ext-sqs-policy.json.tmpl", path.module),
    {
      sqsArns   = jsonencode([for queue in data.aws_sqs_queue.ext_sqs_queue : queue.arn])
      region    = var.region,
      account   = local.provider_account_id
      base_name = local.base_name
  })

  depends_on = [
    data.aws_sqs_queue.ext_sqs_queue
  ]
}

resource "aws_iam_role_policy_attachment" "ext_sqs_policy_attachment" {
  for_each   = length(keys(data.aws_sqs_queue.ext_sqs_queue)) > 0 ? { "create" : true } : {}
  role       = aws_iam_role.role[0].name
  policy_arn = aws_iam_policy.ext_sqs_policy[each.key].arn

}