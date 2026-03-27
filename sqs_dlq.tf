resource "aws_sqs_queue" "dlq" {
  for_each                    = local.dlq_configuration
  name                        = each.value["fifo_queue"] ? format("%s-%s.fifo", local.base_name, each.key) : format("%s-%s-dlq", local.base_name, each.key)
  delay_seconds               = each.value["delay_seconds"]
  max_message_size            = each.value["max_message_size"]
  message_retention_seconds   = each.value["message_retention_seconds"]
  receive_wait_time_seconds   = each.value["receive_wait_time_seconds"]
  redrive_policy              = each.value["redrive_policy"]
  visibility_timeout_seconds  = each.value["visibility_timeout_seconds"]
  policy                      = each.value["policy"] == null || each.value["policy"] == "" ? data.template_file.sqs_dlq_write_policy[each.key].rendered : each.value["policy"]
  fifo_queue                  = each.value["fifo_queue"]
  content_based_deduplication = each.value["content_based_deduplication"]
  sqs_managed_sse_enabled     = each.value["sqs_managed_sse_enabled"]
  tags                        = merge(jsondecode(data.template_file.global_tags_map.rendered))
  redrive_allow_policy = jsonencode(
    {
      redrivePermission = "allowAll"
    }
  )
}

data "template_file" "sqs_dlq_write_policy" {
  for_each = local.dlq_configuration
  template = file("templates/sqs_policy.json.tmpl")

  vars = {
    dev_prefix   = local.dev_prefix
    app_name     = local.app_name
    org          = var.ownerorg
    bag          = var.bag
    environment  = local.environment_code
    region       = var.region
    short_region = local.short_region
    base_name    = local.base_name
    queue_name   = each.value["fifo_queue"] ? format("%s-%s.fifo", local.base_name, each.key) : format("%s-%s-dlq", local.base_name, each.key)
    account      = local.account_id
    sid          = local.snow_id
  }
}