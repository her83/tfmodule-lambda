resource "aws_lambda_function" "default" {
  for_each = local.lambda_merged

  function_name                  = format("%s-%s", local.base_name, each.key)
  description                    = "Lambda function for ${var.bag}-${local.app_name} application in ${local.environment_code}."
  role                           = local.effective_lambda_role_arn
  handler                        = var.package_type == "Image" ? null : each.value["function_handler"]
  memory_size                    = each.value["lambda_memory_size"]
  reserved_concurrent_executions = each.value["reserved_concurrent_executions"]
  runtime                        = var.package_type == "Image" ? null : each.value["lambda_runtime"]
  timeout                        = each.value["lambda_timeout"]
  publish                        = var.snap_start && contains(var.ss_supported_version, each.value["lambda_runtime"]) ? true : tobool(each.value["lambda_publish"])
  layers                         = var.package_type == "Image" ? null : var.lambda_layers
  kms_key_arn                    = var.kms_key_arn
  image_uri                      = var.image_uri
  package_type                   = var.package_type

  s3_bucket         = local.lambda_deploy_bucket
  s3_key            = local.lambda_deploy_s3_key
  s3_object_version = local.s3_object_version

  filename = var.filename

  dynamic "dead_letter_config" {
    for_each = each.value["dlq_name"] == null ? [] : [true]
    content {
      target_arn = aws_sqs_queue.dlq[each.value["dlq_name"]].arn
    }
  }

  dynamic "tracing_config" {
    for_each = each.value["tracing_config"] == null ? [] : [true]
    content {
      mode = each.value["tracing_config"]
    }
  }

  dynamic "ephemeral_storage" {
    for_each = length(each.value["ephemeral_storage"]) == 0 ? [] : [true]
    content {
      size = each.value["ephemeral_storage"]
    }
  }

  dynamic "vpc_config" {
    for_each = (local.vpc_and_subnets_configured && tobool(each.value["use_vpc"]) == true) ? [true] : []
    content {
      security_group_ids = aws_security_group.lambda_egress[*].id
      subnet_ids         = [for subnet in data.aws_subnet.subnets : subnet.id]
    }
  }

  dynamic "environment" {
    for_each = length(keys(merge(jsondecode(data.template_file.global_vars_map.rendered),
      jsondecode(data.template_file.var_maps[each.key].rendered),
    var.developer_override_var_map))) == 0 ? [] : [each.key]
    content {
      variables = merge(jsondecode(data.template_file.global_vars_map.rendered),
        jsondecode(data.template_file.var_maps[each.key].rendered),
      var.developer_override_var_map)
    }
  }

  tags = merge(module.global-config.common_tags,
    jsondecode(data.template_file.global_tags_map.rendered),
  jsondecode(data.template_file.tag_maps[each.key].rendered))

  dynamic "image_config" {
    for_each = each.value["image_config_entry_point"] != null || each.value["image_config_command"] != null || each.value["image_config_working_directory"] != null ? [true] : []
    content {
      entry_point       = each.value["image_config_entry_point"]
      command           = each.value["image_config_command"]
      working_directory = each.value["image_config_working_directory"]
    }
  }

  dynamic "file_system_config" {
    for_each = each.value["efs_file_system_arn"] != null && each.value["efs_local_mount_path"] != null ? [true] : []
    content {
      local_mount_path = each.value["efs_local_mount_path"]
      arn              = each.value["efs_file_system_arn"]
    }
  }

  code_signing_config_arn = var.code_signing_config_arn != null ? var.code_signing_config_arn : null

  dynamic "snap_start" {
    for_each = var.snap_start && contains(var.ss_supported_version, each.value["lambda_runtime"]) ? [true] : []

    content {
      apply_on = "PublishedVersions"
    }
  }

  depends_on = [
    aws_s3_object.initial_artifact,
    aws_security_group.lambda_egress
  ]
}

data "template_file" "var_maps" {
  for_each = local.lambda_merged
  template = tostring(each.value["var_map"])

  vars = {
    dev_prefix       = local.dev_prefix
    app_name         = local.app_name
    org              = var.ownerorg
    bag              = var.bag
    environment      = var.environment
    environment_code = local.environment_code
    region           = var.region
    short_region     = local.short_region
    base_name        = local.base_name
    version          = local.derived_version
    sid              = local.snow_id
    account_id       = local.account_id
    vault_addr       = local.vault_url
  }
}

data "template_file" "tag_maps" {
  for_each = local.lambda_merged
  template = tostring(each.value["tag_map"])

  vars = {
    dev_prefix       = local.dev_prefix
    app_name         = local.app_name
    org              = var.ownerorg
    bag              = var.bag
    environment      = var.environment
    environment_code = local.environment_code
    region           = var.region
    short_region     = local.short_region
    base_name        = local.base_name
    version          = local.derived_version
    sid              = local.snow_id
    account_id       = local.account_id
    vault_addr       = local.vault_url
  }
}

data "template_file" "global_vars_map" {
  template = var.lambda_global_vars_map

  vars = {
    dev_prefix       = local.dev_prefix
    app_name         = local.app_name
    org              = var.ownerorg
    bag              = var.bag
    environment      = var.environment
    environment_code = local.environment_code
    region           = var.region
    short_region     = local.short_region
    base_name        = local.base_name
    version          = local.derived_version
    sid              = local.snow_id
    account_id       = local.account_id
    vault_addr       = local.vault_url
  }
}

data "template_file" "global_tags_map" {
  template = var.lambda_global_tags_map

  vars = {
    dev_prefix       = local.dev_prefix
    app_name         = local.app_name
    org              = var.ownerorg
    bag              = var.bag
    environment      = var.environment
    environment_code = local.environment_code
    region           = var.region
    short_region     = local.short_region
    base_name        = local.base_name
    version          = local.derived_version
    sid              = local.snow_id
    account_id       = local.account_id
    vault_addr       = local.vault_url
  }
}

# data "template_file" "lambda_function_names" {
#   count    = length(local.aliases_list)
#   template = format("%s:%s", lookup(local.aliases_list[count.index], "name"), lookup(local.aliases_list[count.index], "alias"))
# }

resource "aws_cloudwatch_log_group" "default" {
  for_each          = local.lambda_merged
  name              = format("/aws/lambda/%s", aws_lambda_function.default[each.key].function_name)
  retention_in_days = local.lambda_merged[each.key]["retention_in_days"]
  tags              = merge(jsondecode(data.template_file.tag_maps[each.key].rendered))
}

resource "aws_lambda_alias" "alias" {
  for_each    = local.all_aliases
  name        = each.value["name"]
  description = each.key

  # Use the `lambda_short_name_to_arn_mapping` to be able to reference which lambda function this alias refers to by name (not index)
  function_name = aws_lambda_function.default[each.value["lambda_name"]].function_name

  function_version = tobool(each.value.options.enable_provisioned_concurrency) ? aws_lambda_function.default[each.value["lambda_name"]].version : "$LATEST"
  lifecycle {
    # Again this is ignored so that Nimbus deployments can easily update the
    # function version that an alias points at without having to modify the
    # terraform configuration to reflect this change. Nimbus will be performing
    # traffic sharing etc during a deployment too.
    ignore_changes = [function_version]
  }
  depends_on = [
    data.template_file.lambda_function_short_name
  ]
}

resource "vault_kv_secret_v2" "lambda_functions" {
  provider            = vault.non_secret
  for_each            = local.use_non_secrets_tokens ? local.lambda_merged : {}
  mount               = "non_secret"
  name                = format("%s/%s/functions/%s/", var.consul_functions_base, local.base_name, each.key)
  delete_all_versions = true

  data_json = jsonencode({
    function_name                  = aws_lambda_function.default[each.key].function_name,
    handler                        = local.lambda_merged[each.key]["function_handler"],
    runtime                        = local.lambda_merged[each.key]["lambda_runtime"],
    memory_size                    = local.lambda_merged[each.key]["lambda_memory_size"],
    timeout                        = local.lambda_merged[each.key]["lambda_timeout"],
    reserved_concurrent_executions = local.lambda_merged[each.key]["reserved_concurrent_executions"]
  })
}

resource "vault_kv_secret_v2" "lambda_function_conf" {
  provider            = vault.non_secret
  for_each            = local.use_non_secrets_tokens ? { "tokens" = true } : {}
  mount               = "non_secret"
  name                = format("%s/%s/config/", var.consul_config_base, local.base_name)
  delete_all_versions = true

  data_json = jsonencode({
    version            = local.derived_version,
    git_repo           = var.git_repo,
    git_org            = var.git_org,
    artifact_base_name = var.artifact_base_name,
    artifact_file_type = var.artifact_file_type
  })
}

resource "aws_lambda_function_url" "default_function_url" {
  for_each           = local.function_url_merged.use_function_url ? local.lambda_merged : {}
  function_name      = aws_lambda_function.default[each.key].function_name
  authorization_type = "AWS_IAM"

  dynamic "cors" {
    for_each = local.function_url_merged.enable_cors ? [true] : []
    content {
      allow_credentials = local.function_url_merged.allow_credentials
      allow_origins     = local.function_url_merged.allow_origins
      allow_methods     = local.function_url_merged.allow_methods
      allow_headers     = local.function_url_merged.allow_headers
      expose_headers    = local.function_url_merged.expose_headers
      max_age           = local.function_url_merged.max_age
    }
  }
}

resource "aws_lambda_function_url" "alias_function_url" {
  for_each           = local.function_url_merged.use_function_url ? local.all_aliases : {}
  function_name      = aws_lambda_function.default[each.value["lambda_name"]].arn
  qualifier          = each.value["name"]
  authorization_type = "AWS_IAM"

  dynamic "cors" {
    for_each = local.function_url_merged.enable_cors ? [true] : []
    content {
      allow_credentials = local.function_url_merged.allow_credentials
      allow_origins     = local.function_url_merged.allow_origins
      allow_methods     = local.function_url_merged.allow_methods
      allow_headers     = local.function_url_merged.allow_headers
      expose_headers    = local.function_url_merged.expose_headers
      max_age           = local.function_url_merged.max_age
    }
  }
}

resource "aws_lambda_provisioned_concurrency_config" "provisioned_concurrency" {
  for_each                          = { for k, v in local.lambda_merged : k => v if tobool(v.enable_provisioned_concurrency) && v.provisioned_concurrency > 0 }
  function_name                     = aws_lambda_function.default[each.key].function_name
  provisioned_concurrent_executions = each.value.provisioned_concurrency
  qualifier                         = aws_lambda_function.default[each.key].version
}
