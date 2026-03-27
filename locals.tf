#################################################
# LOCAL VARIABLES - LAMBDA ARTIFACT
#################################################
locals {
  default_lambda_deploy_bucket = format("%s-%s", data.external.lambda_workspace_defaults.result["deploy_bucket_base"], local.short_region)
  lambda_deploy_bucket         = var.package_source_location == "s3" ? (var.s3_existing_package != null ? (lookup(var.s3_existing_package, "bucket", null) == null ? local.default_lambda_deploy_bucket : lookup(var.s3_existing_package, "bucket", null)) : local.default_lambda_deploy_bucket) : null
  default_lambda_deploy_s3_key = format("%s/%s/%s/%s.%s", var.git_org, var.git_repo, local.derived_version, var.artifact_base_name, var.artifact_file_type)
  lambda_deploy_s3_key         = var.package_source_location == "s3" ? (var.s3_existing_package != null ? (lookup(var.s3_existing_package, "key", null) == null ? local.default_lambda_deploy_s3_key : lookup(var.s3_existing_package, "key", null)) : local.default_lambda_deploy_s3_key) : null
  s3_object_version            = var.package_source_location == "s3" ? (var.s3_existing_package != null ? (lookup(var.s3_existing_package, "version_id", null)) : null) : null

  latest_version  = var.override_consul_artifact_version == false ? lookup(data.external.lambda_workspace_config.result, "config/version", var.artifact_version) : var.artifact_version
  derived_version = local.latest_version == "" ? var.artifact_version : local.latest_version
}

################################################
# LOCAL VARIABLES - VPC Config
#################################################
locals {
  vpc_subnets_configured     = var.vpc_info["subnet_list"] == null ? false : length(var.vpc_info["subnet_list"]) == 0 ? false : true
  vpc_name_configured        = var.vpc_info["vpc_name"] == null || var.vpc_info["vpc_name"] == "" ? false : true
  vpc_and_subnets_configured = local.vpc_subnets_configured && local.vpc_name_configured ? true : false
}

#################################################
# LOCAL VARIABLES - SNS ALARM CONFIGS
#################################################
locals {
  mapped_environment         = module.global-config.general[format("vault/environments/%s", var.environment)]
  lower_environment_priority = lookup(module.global-config.general, format("snow/lower_env_priority/%s", var.environment), null)

  warning_priority_level  = local.mapped_environment == "prod" ? module.global-config.general[format("snow/prod_tier_urgencies_priority/%s-4", var.snow_tier)] : local.lower_environment_priority
  high_priority_level     = local.mapped_environment == "prod" ? module.global-config.general[format("snow/prod_tier_urgencies_priority/%s-3", var.snow_tier)] : local.lower_environment_priority
  critical_priority_level = local.mapped_environment == "prod" ? module.global-config.general[format("snow/prod_tier_urgencies_priority/%s-2", var.snow_tier)] : local.lower_environment_priority

  sns_name_account_base     = lookup(var.alarm_sns_topic_account_name, var.account, var.account)
  sns_name_account_parts    = split("-", local.sns_name_account_base)
  sns_name_account_combined = format("%s-%s-%s", local.sns_name_account_parts[0], local.sns_name_account_parts[1], var.alarm_sns_topic_account_suffix[local.sns_name_account_parts[2]])

  pri2_sns_name = format("%s-snow-pri%s", local.sns_name_account_combined, substr(local.critical_priority_level, 1, 1))
  pri3_sns_name = format("%s-snow-pri%s", local.sns_name_account_combined, substr(local.high_priority_level, 1, 1))
  pri4_sns_name = format("%s-snow-pri%s", local.sns_name_account_combined, substr(local.warning_priority_level, 1, 1))
}

#################################################
# LOCAL VARIABLES - Provider & Account Information
#################################################
locals {
  secrets_account          = var.secrets_account == "" ? var.account : var.secrets_account
  dr_account               = var.dr_account == "" ? var.account : var.dr_account
  initial_artifact_account = var.initial_artifact_account == "" ? var.account : var.initial_artifact_account
  external_trigger_account = var.external_trigger_account == "" ? var.account : var.external_trigger_account

  provider_account_id                  = module.global-config.general[format("aws/accounts/%s", var.account)]
  provider_secrets_account_id          = module.global-config.general[format("aws/accounts/%s", local.secrets_account)]
  provider_dr_account_id               = module.global-config.general[format("aws/accounts/%s", local.dr_account)]
  provider_initial_artifact_account_id = module.global-config.general[format("aws/accounts/%s", local.initial_artifact_account)]
  external_trigger_account_id          = module.global-config.general[format("aws/accounts/%s", local.external_trigger_account)]

  account_id = data.aws_caller_identity.current.account_id
}

#################################################
# LOCAL VARIABLES - Non secret vault
#################################################
locals {
  global_general_result_map = module.global-config.general

  ###  INITIAL SETTINGS FOR VAULT WRITING PATH (MUST ADDED TO THE WORKSPACE THAT REQUIRES THIS FEATURE"
  vault_environment  = local.global_general_result_map[format("vault/environments/%s", var.environment)]
  vault_region       = local.global_general_result_map[format("vault/regions/%s", var.region)]
  vault_short_region = local.global_general_result_map[format("short_regions/%s", local.vault_region)]
  vault_url          = local.global_general_result_map[format("vault/%s/%s/kv_mount/url", local.vault_short_region, local.vault_environment)]

  use_non_secrets_tokens = var.environment == "sandbox" ? (var.use_real_consul_tokens_sandbox == true ? true : false) : (var.enable_write_values_consul == true ? true : false)

  # Get a list of account from invoke_permission_principal_map variable to be provided to aws_accounts_merged_list local
  principal_map = flatten([
    for k, v in var.invoke_permission_principal_map : [
      for ak, av in v : av
      if ak == "account"
    ]
  ])

  # Merge account variables into a list to be provided to non_secret_path_map
  aws_accounts_merged_list = concat(
    [var.account], [local.secrets_account], [local.dr_account], [local.initial_artifact_account], [local.external_trigger_account], var.allow_cross_account_access_from, local.principal_map
  )

  # Merge prod_tier_urgencies_priority levels into a list to be provided to non_secret_path_map
  prod_tier_urgencies_priority_list = concat(["${var.snow_tier}-4"], ["${var.snow_tier}-3"], ["${var.snow_tier}-2"])

  # Map of paths and keys (list) to be provided to global-config module to get general values
  global_general_request_map = {
    (var.aws_accounts_path)                 = local.aws_accounts_merged_list
    (var.account_environments_path)         = [var.environment]
    (var.lower_env_priority_path)           = [var.environment]
    (var.prod_tier_urgencies_priority_path) = local.prod_tier_urgencies_priority_list
    "vault"                                 = []
  }
}

#################################################
# LOCAL VARIABLES - IAM
#################################################
locals {
  create_iam_role               = var.lambda_iam_role_override == "" ? true : false
  created_iam_role              = element(concat(aws_iam_role.role[*].arn, tolist([""])), 0)
  created_invocation_iam_role   = element(concat(aws_iam_role.invocation_role[*].arn, tolist([""])), 0)
  effective_lambda_role_arn     = local.create_iam_role ? local.created_iam_role : var.lambda_iam_role_override
  effective_invocation_role_arn = local.create_iam_role ? local.created_invocation_iam_role : var.lambda_iam_role_override
}

#################################################
# LOCAL VARIABLES - Mappings
#################################################
locals {
  lambda_short_name_to_arn_mapping = { for key, value in local.lambda_merged :
    key => aws_lambda_function.default[key].arn
  }
  lambda_alias_short_name_to_invoke_arn_mapping = { for key, value in local.all_aliases :
    key => aws_lambda_alias.alias[key].invoke_arn
  }
}

# Use the rendered templates to create a map of lambda short name to lambda function ARN
locals {
  dev_prefix       = var.developer_prefix == "" ? var.developer_prefix : format("%s%s", var.developer_prefix, "-")
  app_name         = format("%s%s", local.dev_prefix, var.application_name)
  base_name        = module.global-config.full_context_name
  environment_code = module.global-config.environment_code
  short_region     = module.global-config.short_region
  snow_id          = module.global-config.snow_id
}

## SQS DLQ LOCALS
locals {
  dlq_configuration = { for key, value in var.dead_letter_queues :
    key => merge(var.dlq_defaults,
    value)
  }
}

## S3 LOCALS
locals {
  s3_bucket_ids = [for bucket in data.aws_s3_bucket.list : bucket.id]
}

## LAMBDA FUNCTION LOCALS
locals {
  lambda_merged = { for key, value in var.lambda_map :
    key => merge(var.lambda_definition_defaults,
      var.lambda_alarms_default_map,
      var.sns_defaults,
      var.sqs_defaults,
      var.sqs_report_batch_item_failures,
    value)
  }

  function_url_merged = merge(var.function_url_defaults, var.function_url)

  light_aliases = { for key, value in local.lambda_merged :
    format("%s:%s", key, value["light_alias"]) => {
      name        = value["light_alias"]
      lambda_name = key
      options     = value
    }
  }
  dark_aliases = { for key, value in local.lambda_merged :
    format("%s:%s", key, value["dark_alias"]) => {
      name        = value["dark_alias"]
      lambda_name = key
      options     = value
    }
  }
  all_aliases = merge(local.light_aliases, local.dark_aliases)
}

## LAMBDA SG LOCALS
locals {
  egress_default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Default Value"
      cidr_blocks = ["10.0.0.0/8",
        "172.16.0.0/12",
      "192.168.0.0/16"]
    },
    {
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      description = "DNS Enpoint"
      cidr_blocks = var.dns_egress_cidr
    },
    {
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      description = "DNS Enpoint"
      cidr_blocks = var.dns_egress_cidr
    },
    {
      from_port   = 88
      to_port     = 88
      protocol    = "udp"
      description = "Kerberose"
      cidr_blocks = var.basic_egress_cidr
    },
    {
      from_port   = 80
      to_port     = 88
      protocol    = "tcp"
      description = "Web Traffic & Kerberose"
      cidr_blocks = var.basic_egress_cidr
    },
    {
      from_port   = 443
      to_port     = 464
      protocol    = "tcp"
      description = "SSL & SMB/CIFS & Kerberos password"
      cidr_blocks = var.basic_egress_cidr
    },
    {
      from_port   = 445
      to_port     = 464
      protocol    = "udp"
      description = "SMB/CIFS & Kerberos password"
      cidr_blocks = var.basic_egress_cidr
    },
    {
      from_port   = 587
      to_port     = 587
      protocol    = "tcp"
      description = "Simple Email Service"
      cidr_blocks = var.basic_egress_cidr
    },
    {
      from_port   = 389
      to_port     = 389
      protocol    = "tcp"
      description = "LDAP Non-SSL"
      cidr_blocks = var.basic_egress_cidr
    },
    {
      from_port   = 389
      to_port     = 389
      protocol    = "udp"
      description = "LDAP Non-SSL UDPO"
      cidr_blocks = var.basic_egress_cidr
    },
    {
      from_port   = 636
      to_port     = 636
      protocol    = "tcp"
      description = "LDAP SSL"
      cidr_blocks = var.basic_egress_cidr
    },
    {
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      description = "Common Outbound Connection"
      cidr_blocks = var.basic_egress_cidr
    }
  ]
}

## KINESIS LOCALS
locals {
  sns_topics = {
    for lambda, props in local.lambda_merged :
    lambda => props if tobool(props.sns_trigger) == true
  }
  existing_kinesis_stream_name = var.kinesis_stream_name
}

## INVOKE PERMISSION LOCALS
locals {
  # This method uses set product to create the cross product combinations. Since the map of invoke permissions
  # is a series of principals and we need each principal to be mapped to each function or each alias, we need
  # the cross product of those two different sets.
  # https://www.terraform.io/docs/language/functions/setproduct.html#finding-combinations-for-for_each
  # setproduct works with sets and lists, but our variables are both maps
  # so we'll need to convert them first.
  principal_aliases = [
    for key, alias in local.all_aliases : {
      key        = key
      alias_info = alias
    }
  ]

  principal_functions = [
    for key, function in local.lambda_merged : {
      key         = key
      lambda_info = function
    }
  ]

  principals = [
    for key, principal in var.invoke_permission_principal_map : {
      key            = key
      principal_info = principal
    }
  ]

  principal_to_aliases = [
    for pair in setproduct(local.principals, local.principal_aliases) : {
      principal      = pair[0].key
      principal_info = pair[0].principal_info
      alias_key      = pair[1].key
      alias_info     = pair[1].alias_info
    }
  ]

  principal_to_functions = [
    for pair in setproduct(local.principals, local.principal_functions) : {
      principal      = pair[0].key
      principal_info = pair[0].principal_info
      lambda_key     = pair[1].key
      lambda_info    = pair[1].lambda_info
    }
  ]

  principal_list_with_account_id = {
    for key, values in var.invoke_permission_principal_map : key => {
      principal  = key
      type       = values["type"]
      value      = values["value"]
      account    = values["account"]
      account_id = module.global-config.general[format("aws/accounts/%s", values["account"])]
    }
  }
}

// Create locals for the cross account sizes. 
// First the number of accounts they want to grant access from
// Second the number of lambda functions being created
// Third the cross product of these previous two numbers giving the toal number of permissions that must be added
locals {


  cross_aliases = [
    for key, value in local.all_aliases : {
      key        = key
      lambda_arn = aws_lambda_alias.alias[key].function_name
      qualifier  = aws_lambda_alias.alias[key].name
    }
  ]
  cross_accounts = [
    for val in var.allow_cross_account_access_from : {
      key        = val
      account_id = module.global-config.general[format("aws/accounts/%s", val)]
    }
  ]

  account_cross_product = [
    for pair in setproduct(local.cross_accounts, local.cross_aliases) : {
      account_name = pair[0].key
      account_id   = pair[0].account_id
      alias_name   = pair[1].key
      lambda_arn   = pair[1].lambda_arn
      qualifier    = pair[1].qualifier
    }
  ]
}

## CLOUDWATCH ALARMS LOCALS
locals {
  alarm_description_base = format("[SNOWAG:%s][SNOWCI:%s]", var.snow_assignment_group, var.snow_configuration_item)
}