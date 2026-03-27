
################################################
# Custom Config Location (Segmentation - aka G4)
# TPM/Atlantis will update these at run time
################################################
variable "git_config_org" {
  description = "This will automatically be set to the git org of the config repo by TPM and is used for Tagging"
  type        = string
  default     = ""
}
variable "git_config_repo" {
  description = "This will automatically be set to the git repo by TPM and is used for Tagging"
  type        = string
  default     = ""
}
variable "git_config_dir" {
  description = "This will automatically be set to the folder within the repo git repo by TPM and is used for Tagging"
  type        = string
  default     = ""
}
variable "se_contact" {
  description = "This will automatically be set to the user running the terraform command by TPM and is used for Tagging "
  type        = string
  default     = ""
}
variable "code_version" {
  description = "This will automatically be set to the absolute workspace code version by TPM and is used for Tagging "
  type        = string
  default     = ""
}

################################################
# Custom Config Location (Segmentation - aka G4)
# Required for common_tags
################################################
variable "terraform" {
  description = "This will automatically be filled in by Terraform"
  type        = map(string)
  default     = {}
}
variable "terraform_workspace_type" {
  description = "This identifies the workspace and is used for Tagging"
  type        = string
  default     = "wdpr-lambda-workspaces"
}

variable "application_name" {
  description = "Name of the application"
  type        = string
  validation {
    condition     = var.application_name != ""
    error_message = "Please add the \"application_name =\" to your tfvars file.  It can not be blank."
  }
}
variable "developer_prefix" {
  description = "Developer prefix"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment for which infrastructure is being provisioned"
  type        = string
  validation {
    condition     = var.environment != ""
    error_message = "Please add the \"environment =\" to your tfvars file.  It can not be blank and must be a valid environment name."
  }
}
variable "region" {
  description = "AWS Region to provision the infrastructure"
  type        = string
  validation {
    condition     = var.region != ""
    error_message = "Please add the \"region =\" to your tfvars file.  It can not be blank and must be a valid AWS region name."
  }
}
variable "account" {
  description = "AWS Account Name to provision the infrastructure"
  type        = string
  validation {
    condition     = var.account != ""
    error_message = "Please add the \"account =\" to your tfvars file.  It can not be blank and must be a valid AWS account name."
  }
}

variable "dr_region" {
  description = "Used to identify a `DR` region for being able to place some specific resources in a different region than the main resources. Example is to create an out of region cloudwatch trigger to call this lambda. This ensures that not only is the trigger able to connect to the lambda, but that it can come from outside the region itself."
  type        = string
  default     = ""
}
variable "dr_account" {
  description = "Used to identify a Disaster Recovery account for being able to place some specific resources in a different account"
  type        = string
  default     = ""
}
variable "bag" {
  description = "Business Affinity group associated to the infrastructure"
  type        = string
  validation {
    condition     = var.bag != ""
    error_message = "Please add the \"bag =\" to your tfvars file.  It can not be blank and should be one of the standard Business Affinity Groups."
  }
}
variable "bapp_id" {
  description = "BAPP ID for which infrastructure is being provisioned"
  type        = string
  validation {
    condition     = var.bapp_id != ""
    error_message = "Please add the \"bapp_id =\" to your tfvars file.  It can not be blank and must be a valid Service Now BAPP ID."
  }
}
variable "bid" {
  description = "BID for which infrastructure is being provisioned"
  type        = string
  default     = ""
}
variable "name_node_id" {
  description = "Name_Node_ID for the Executive Owner for which infrastructure is being provisioned"
  type        = string
  validation {
    condition     = var.name_node_id != ""
    error_message = "Please add the \"name_node_id =\" to your tfvars file.  It can not be blank and must be a valid name_node_id."
  }
}
variable "ownerorg" {
  description = "Owner org for the infrastructure"
  type        = string
  validation {
    condition     = var.ownerorg != ""
    error_message = "Please add the \"ownerorg =\" to your tfvars file.  It can not be blank and should be one of the standard orgs."
  }
}

variable "vpc_info" {
  description = "A map which contains two properties: `vpc_name` and `subnet_list`. These are referenced by their common names as seen in the AWS console. See below for example"
  type = object({
    vpc_name    = optional(string)
    subnet_list = optional(list(string))
  })
  default = {}
}

variable "provider_assumed_role" {
  description = "By default the role that Terraform assumes in the destination account is `WDPR-cross-Atlantis` and can be overridden if necessary"
  type        = string
  default     = "WDPR-cross-Atlantis"
}

variable "user_tags" {
  description = "Additional tags if needed. #DO NOT REDEFINE STANDARD TAGS!!"
  type        = map(any)
  default     = {} # DO NOT REDEFINE STANDARD TAGS!!
}

variable "package_source_location" {
  description = "The type of package source to be used: `[s3, local, image]`"
  type        = string
  default     = "s3"
  validation {
    condition     = contains(["s3", "local", "image"], lower(var.package_source_location))
    error_message = "package_source_location must be one of: s3, local, image."
  }
}
variable "s3_existing_package" {
  description = "This defines the s3 source location information. By default, all values will be calculated based on other values, but explicit overrides can be provided here. `s3_existing_package` is a map variable with expected properties of `bucket`, `key` and `version_id`. Each of these can independently be `null` (default) and the calculate values will be used."
  type        = map(string)
  default     = null
}
variable "image_uri" {
  description = "If `package_source_location` is set to `image` then this will point at the ECR URI where the image resides"
  type        = string
  default     = null
}

variable "filename" {
  description = "If `package_source_location` is set to `local` then this will point to the local file which will be used for deployment."
  type        = string
  default     = null
}

variable "package_type" {
  description = "This value indicates whether the package is a `Zip` (s3/local) or `Image` (image) and informs AWS how to treat the deployment"
  type        = string
  default     = "Zip"
  validation {
    condition     = contains(["Zip", "Image"], var.package_type)
    error_message = "package_type must be either \"Zip\" or \"Image\"."
  }
}

variable "scheduled_lambda_triggers" {
  description = "If lambdas are called by scheduled triggers provide a list"
  type        = map(map(string))
  default     = {}
}

variable "event_lambda_triggers" {
  description = "If lambdas are to be called by event bridge rules, this will configure the rule and target to properly hit the lambda"
  type        = map(map(string))
  default     = {}
}

variable "lambdafunction_logfilters" {
  description = "Map of lambda cloudwatch log subscription filters"
  type        = map(map(string))
  default     = {}
}
variable "scheduled_lambda_triggers_dr" {
  description = "Lambda triggers to be placed in a `DR` region, separate from the main deployment of the lambda functions themselves. DR is used as a convenient descriptor."
  type        = map(map(string))
  default     = {}
}

variable "dead_letter_queues" {
  description = "A Dead Letter queue is a SQS queue that is utilized in case of an asynchronous lambda invocation that fails."
  type        = map(map(any))
  default = {
    "default_lambda" = {
      "name" = "default_lambda"
    }
    "default_sqs" = {
      "name" = "default_sqs"
    }
    "default_fifo_sqs" = {
      "name"                        = "default_fifo_sqs",
      "fifo_queue"                  = true,
      "content_based_deduplication" = true,
    }
  }
}

variable "lambda_definition_defaults" {
  description = "Lambda definitions defaults"
  type        = map(any)
  default = {
    "lambda_runtime"                                 = "nodejs20.x"
    "lambda_memory_size"                             = 128
    "lambda_timeout"                                 = 10
    "lambda_publish"                                 = true
    "light_alias"                                    = "LIGHT"
    "dark_alias"                                     = "DARK"
    "reserved_concurrent_executions"                 = 10
    "retention_in_days"                              = 90
    "use_vpc"                                        = false
    "dlq_name"                                       = "default_lambda"
    "tracing_config"                                 = null
    "ephemeral_storage"                              = 512
    "sqs_trigger"                                    = false
    "sqs_trigger_alias"                              = "LIGHT"
    "sqs_redrive_queue_name"                         = "default_sqs"
    "sns_trigger"                                    = false
    "sns_trigger_alias"                              = "LIGHT"
    "sns_protocol"                                   = "lambda"
    "ddb_trigger"                                    = false
    "ddb_trigger_table_name"                         = null
    "ddb_trigger_alias"                              = "LIGHT"
    "ddb_trigger_start_pos"                          = "LATEST"
    "ddb_trigger_batch_size"                         = 100
    "ddb_trigger_maximum_batching_window_in_seconds" = 5
    "ddb_trigger_parallelization_factor"             = 1
    "ddb_trigger_maximum_retry_attempts"             = 10000
    "ddb_trigger_maximum_record_age_in_seconds"      = 604800
    "ddb_trigger_bisect_batch_on_function_error"     = false
    "s3_trigger"                                     = false
    "s3_trigger_alias"                               = "LIGHT"
    "s3_trigger_bucket"                              = null
    "s3_trigger_event"                               = "s3:ObjectCreated:*"
    "s3_trigger_prefix"                              = null
    "s3_trigger_suffix"                              = null
    "ext_sqs_trigger"                                = false
    "ext_sqs_trigger_name"                           = null
    "ext_sqs_trigger_batch_size"                     = 10
    "ext_sqs_max_batching_window_in_seconds"         = 5
    "ext_sqs_trigger_alias"                          = "LIGHT"
    "ext_sns_trigger"                                = null
    "ext_sns_trigger_name"                           = null
    "ext_sns_trigger_alias"                          = "LIGHT"
    "image_config_entry_point"                       = null
    "image_config_command"                           = null
    "image_config_working_directory"                 = null
    "efs_file_system_arn"                            = null
    "efs_local_mount_path"                           = null
    "iot_policy"                                     = null
    "enable_provisioned_concurrency"                 = false
    "provisioned_concurrency"                        = 0
    "kinesis_trigger"                                = false
    "kinesis_trigger_stream_name"                    = null
    "kinesis_trigger_alias"                          = "LIGHT"
    "kinesis_trigger_batch_size"                     = 100
    "kinesis_trigger_max_batching_window_in_seconds" = null
    "kinesis_trigger_max_record_age_in_seconds"      = 86400
    "kinesis_trigger_max_retry_attempts"             = 2
    "kafka_trigger"                                  = false
    "kafka_topics"                                   = null
    "kafka_bootstrap_servers"                        = null
    "kafka_source_access"                            = null
    "kafka_starting_position"                        = null
  }
}

variable "dlq_defaults" {
  description = "Dead Letter Queue defaults"
  type        = map(any)
  default = {
    "visibility_timeout_seconds"  = 30
    "message_retention_seconds"   = 1209600
    "max_message_size"            = 262144
    "delay_seconds"               = 0
    "receive_wait_time_seconds"   = 0
    "policy"                      = ""
    "redrive_policy"              = ""
    "fifo_queue"                  = false
    "content_based_deduplication" = false
    "sqs_managed_sse_enabled"     = true
  }
}

variable "sqs_defaults" {
  description = "Map of default sqs trigger settings"
  type        = map(any)
  default = {
    "sqs_msg_retention_seconds"          = 1209600
    "sqs_max_msg_size"                   = 262144
    "sqs_delay_seconds"                  = 0
    "sqs_receive_wait_time_seconds"      = 0
    "sqs_redrive_queue_name"             = "default_sqs"
    "sqs_redrive_max_recv_count"         = 3
    "sqs_batch_size"                     = 10
    "sqs_max_batching_window_in_seconds" = 5
    "sqs_fifo_queue"                     = false
    "sqs_content_based_deduplication"    = false
    "sqs_managed_sse_enabled"            = true
  }
}

variable "sqs_report_batch_item_failures" {
  description = "To control whether the Lambda function should report batch item failures when processing events from SQS event sources. Allowed values are and empty list ([]) or a list containing only [\"ReportBatchItemFailures\"]."
  type        = map(any)
  default = {
    sqs_function_response_types     = []
    ext_sqs_function_response_types = []
  }
  validation {
    condition     = alltrue([for v in [var.sqs_report_batch_item_failures.sqs_function_response_types, var.sqs_report_batch_item_failures.ext_sqs_function_response_types] : (can(v) ? (length(v) == 0 || (length(v) == 1 && v[0] == "ReportBatchItemFailures")) : true)])
    error_message = "Each list must be [] or [\"ReportBatchItemFailures\"]."
  }
}

variable "sns_defaults" {
  description = "Map of default sns trigger settings"
  type        = map(any)
  default = {
    "sns_delivery_min_delay_target"        = 10
    "sns_delivery_max_delay_target"        = 30
    "sns_delivery_num_no_delays_retry"     = 1
    "sns_delivery_num_min_delays_retry"    = 3
    "sns_delivery_num_max_delays_retry"    = 3
    "sns_delivery_num_retry"               = 100
    "sns_delivery_backoff_function"        = "exponential"
    "sns_throttle_max_receives_per_second" = 1
    "sns_disable_subscription_overrides"   = false
    "sns_log_group_retention_in_days"      = 90
    "sns_app_success_sample_rate"          = 100
    "sns_http_success_sample_rate"         = 100
    "sns_lambda_success_sample_rate"       = 100
    "sns_sqs_success_sample_rate"          = 100
    "sns_protocol"                         = "lambda"
  }
}

variable "git_org" {
  description = "The name of the git org where the code resides."
  type        = string
  validation {
    condition     = var.git_org != ""
    error_message = "git_org cannot be empty."
  }
}
variable "git_repo" {
  description = "The name of the git repo where the code resides."
  type        = string
  validation {
    condition     = var.git_repo != ""
    error_message = "git_repo cannot be empty."
  }
}
variable "artifact_version" {
  description = "The version of the artifact including build number to be deployed. This may be overridden by values in Consul driven by the Nimbus runs. Value would be found at `/terraform/wdpr-lambda-workspaces/<workspace_name>/config/version`"
  type        = string
  validation {
    condition     = var.artifact_version != ""
    error_message = "artifact_version cannot be empty."
  }
}

# Non secrets vault variables
variable "non_secret_vault_url" {
  description = "non secret vault url"
  type        = string
  default     = "https://vault-use1.wdprapps.disney.com"
}

variable "non_secret_vault_role" {
  description = "non secret vault role"
  type        = string
  default     = "ee-atlantis-tokengen"
}

variable "aws_accounts_path" {
  description = "Non secrets AWS accounts path"
  type        = string
  default     = "aws/accounts"
}

variable "account_environments_path" {
  description = "Non secrets account environments path"
  type        = string
  default     = "account_environments"
}

variable "prod_tier_urgencies_priority_path" {
  description = "Non secrets Prod tier urgencies priority path"
  type        = string
  default     = "snow/prod_tier_urgencies_priority"
}

variable "lower_env_priority_path" {
  description = "Non secrets Prod tier urgencies priority path"
  type        = string
  default     = "snow/lower_env_priority"
}

# Artifact variables
variable "override_consul_artifact_version" {
  description = "Flag that will force the `artifact_version` variable to be used instead of one pulled from non_secrets (as set by the Nimbus deployment)"
  type        = bool
  default     = false
  validation {
    condition     = var.override_consul_artifact_version == true || var.override_consul_artifact_version == false
    error_message = "override_consul_artifact_version must be a boolean."
  }
}
variable "artifact_base_name" {
  description = "The base name of the artifact without the extension. Typically the name of the git repo."
  type        = string
  validation {
    condition     = var.artifact_base_name != ""
    error_message = "artifact_base_name cannot be empty."
  }
}

variable "artifact_file_type" {
  description = "The file type of the artifact."
  type        = string
  default     = "zip"
  validation {
    condition     = contains(["zip", "jar", "tgz"], lower(var.artifact_file_type))
    error_message = "artifact_file_type must be one of: zip, jar, tgz."
  }
}

##############################
# Lambda Function Definitions
##############################

variable "lambda_map" {
  description = "(REQUIRED) Map of Maps which define the lambda functions and associated variables. See [Lambda Configuration](#lambda-configuration)"
  type        = map(any)
}


##############################
# Lambda Layer References
##############################
variable "lambda_layers" {
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function. See [Lambda Layers](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html)"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.lambda_layers) <= 5
    error_message = "You can attach at most 5 Lambda Layers."
  }
}

##############################
# Lambda Core
##############################

# If the below override variable is set to a non-empty value then this terraform won't create an IAM role for the lambda
# and instead will use the value of 'lambda_iam_role_override' as the role to be used. Make the sure the value is set
# to full ARN of role existing in the same account as your Lambda. This meant to be facilitate developmemnt needs in
# sandbox accounts.
# Below are two generic roles that can be used for generic use case
# ra-sandbox: 633112549318:role/DevelopmentTrustRole
# wdpr-sandbox: 141854384972:role/DevelopmentTrustRole
# if those role doesn't meet your development requirements, you need to contact CloudSE to create a custom role for you
variable "lambda_iam_role_override" {
  description = "If this is set than terraform wont create IAM role for lambda and use this role instead, (Primarily for sandbox)"
  type        = string
  default     = ""
}

variable "kinesis_stream_name" {
  description = "The common name of an existing Kinesis Stream. The Terraform will find this stream and attach the cloudwatch log groups to it."
  type        = string
  default     = ""
}

variable "use_kinesis_stream" {
  description = "Flag to enable the use of a Kinesis stream. When enabled, you can either create or use a preexistent one. To create, don't set kinesis_stream_name,  you can either customize the prefix using kinesis_stream_suffix_custom.  To use a preexistent kinesis stream, set the variable kinesis_stream_name"
  type        = bool
  default     = false
  validation {
    condition     = var.use_kinesis_stream == true || var.use_kinesis_stream == false
    error_message = "use_kinesis_stream must be a boolean."
  }
}

variable "kinesis_stream_suffix_custom" {
  description = "provide a custom suffix"
  type        = string
  default     = ""
}

variable "kinesis_stream_mode" {
  description = "Kinesis stream mode, either `PROVISIONED` or `ON_DEMAND`"
  type        = string
  default     = "PROVISIONED"
  validation {
    condition     = contains(["PROVISIONED", "ON_DEMAND"], upper(var.kinesis_stream_mode))
    error_message = "kinesis_stream_mode must be PROVISIONED or ON_DEMAND."
  }
}

variable "kinesis_shard_count" {
  description = "The number of shards that the stream will use."
  type        = number
  default     = 1
  validation {
    condition     = var.kinesis_shard_count >= 1
    error_message = "kinesis_shard_count must be >= 1."
  }
}

variable "app_policy" {
  description = "This indicates that your lambdas utilize a secondary IAM policy defined in the `templates` folder named `$app_policy.json.tmpl`. Extra permissions, beyond those that are defined in the `lambda_policy.json.tmpl` need to be added here. For example, if your lambda function needs access to an S3 bucket outside of the default then it should be added here. Note that certain permissions for lambdas are added where there is a specific integration."
  type        = string
  default     = ""
}

variable "iot_policy" {
  description = "(Optional) Set to the name of your template file without the extension if your lambda needs a trust relationship to iot.amazonaws.com. If the Lambda needs rights to anything iot:*, then this is likely needed."
  type        = string
  default     = ""
}

variable "lambda_global_vars_map" {
  description = "Global variable map, will be applied to all lambdas (environment, region, etc)"
  type        = string
  default     = <<DOC
  {
    "environment": "override environment"
  }
DOC
}

variable "lambda_global_tags_map" {
  description = "Map of global tags that will be applied to all lambdas."
  type        = string
  default     = <<DOC
  {
    "environment": "override environment"
  }
DOC
}

variable "developer_override_var_map" {
  description = "For develop purposes only. Override lambda environment variables."
  type        = map(string)
  default     = {}
}

variable "allow_cross_account_access_from" {
  description = "List of account names to allow calling of these functions from a cross account perspective. Specifically this will grant these accounts the appropriate capability to call the functions defined."
  type        = list(string)
  default     = []
}

variable "invoke_permission_principal_map" {
  description = "Map of principals to allow calling of these functions from. Specifically this will grant these accounts the appropriate capability to call the functions defined."
  type        = map(map(string))
  default     = {}
}

variable "consul_defaults_path" {
  description = "Full Non Secret path to workspace defaults"
  type        = string
  default     = "terraform/wdpr-lambda-workspaces/defaults"
}

variable "consul_config_base" {
  description = "Consul base path for configurations"
  type        = string
  default     = "terraform/wdpr-lambda-workspaces"
}

variable "consul_functions_base" {
  description = "Consul base path for functions"
  type        = string
  default     = "terraform/wdpr-lambda-workspaces"
}

variable "consul_nimbus_base" {
  description = "Non Secret base path for nimbus configurations"
  type        = string
  default     = "terraform/wdpr-lambda-workspaces"
}

variable "lambda_alarms_default_map" {
  description = "A map of alarm thresholds, that is applied to each lambda to trigger warning/high/critical alarms that create Incidents in Service Now"
  type        = map(any)
  default = {
    "max_duration_warning_threshold"          = 0.90
    "max_duration_high_threshold"             = 0.95
    "max_duration_critical_threshold"         = 0.99
    "max_concurrent_execs_warning_threshold"  = 0.92
    "max_concurrent_execs_high_threshold"     = 0.95
    "max_concurrent_execs_critical_threshold" = 0.99
    "throttles_warning_threshold"             = 3
    "throttles_high_threshold"                = 10
    "throttles_critical_threshold"            = 15
    "errors_warning_threshold"                = 3
    "errors_high_threshold"                   = 10
    "errors_critical_threshold"               = 15
    "concurrent_execs_treat_missing_data"     = "notBreaching"
    "execution_time_treat_missing_data"       = "notBreaching"
    "throttles_treat_missing_data"            = "notBreaching"
    "errors_treat_missing_data"               = "notBreaching"
  }
}

variable "alarm_sns_topic_account_name" {
  description = "Map to define the account name for alarm SNS topic"
  type        = map(string)
  default = {
    "wdpr-sandbox" = "dpep-wdpr-sbx"
    "ra-sandbox"   = "wdpr-ra-sbx"
  }
}

variable "alarm_sns_topic_account_suffix" {
  description = "Map to define account suffix for alarm SNS topic"
  type        = map(string)
  default = {
    "dev"  = "dev"
    "test" = "tst"
    "prod" = "prd"
    "sbx"  = "sbx"
  }
}

variable "lambda_alarms_actions_enabled" {
  description = "Map of maps to enable or disable the alarm creation for a specific environment and alarm level. This can be used to cut down on alarm duplication by disabling one or more alarm levels (ie. disable warning & high but leave critical enabled)"
  type        = map(map(bool))
  default = {
    "sandbox" = {
      "warning"  = false
      "high"     = false
      "critical" = false
    }
    "devtrue" = {
      "warning"  = false
      "high"     = false
      "critical" = false
    }
    "dev2" = {
      "warning"  = false
      "high"     = false
      "critical" = false
    }
    "latest" = {
      "warning"  = true
      "high"     = true
      "critical" = true
    }
    "stage" = {
      "warning"  = true
      "high"     = true
      "critical" = true
    }
    "load" = {
      "warning"  = true
      "high"     = true
      "critical" = true
    }
    "load-dr" = {
      "warning"  = true
      "high"     = true
      "critical" = true
    }
    "loaddr" = {
      "warning"  = true
      "high"     = true
      "critical" = true
    }
    "shadow" = {
      "warning"  = true
      "high"     = true
      "critical" = true
    }
    "training" = {
      "warning"  = true
      "high"     = true
      "critical" = true
    }
    "prod" = {
      "warning"  = true
      "high"     = true
      "critical" = true
    }
    "prod-dr" = {
      "warning"  = true
      "high"     = true
      "critical" = true
    }
    "proddr" = {
      "warning"  = true
      "high"     = true
      "critical" = true
    }
  }
}

variable "snow_assignment_group" {
  description = "This is the name of the assignment group in service now where incidents should be assigned."
  type        = string
  validation {
    condition     = var.snow_assignment_group != ""
    error_message = "snow_assignment_group cannot be empty."
  }
}

variable "snow_configuration_item" {
  description = "This is the name of the configuration item which your workspace is a part of."
  type        = string
  validation {
    condition     = var.snow_configuration_item != ""
    error_message = "snow_configuration_item cannot be empty."
  }
}

variable "snow_tier" {
  description = "Application tier for routing alarm levels to specific priority levels."
  type        = number
  default     = 3
}

variable "secrets_region" {
  description = "Secrets Region"
  type        = string
  default     = "us-east-1"
}

variable "secrets_account" {
  description = "Secrets account"
  type        = string
  default     = "wdpr-apps"
}

variable "initial_artifact_region" {
  description = "Initial artifact region"
  type        = string
  default     = "us-east-1"
}

variable "initial_artifact_account" {
  description = "Initial artifact account"
  type        = string
  default     = "wdpr-apps"
}

variable "initial_artifact_enable" {
  description = "Whether or not to create an initial artifact for latest environment"
  type        = string
  default     = "enable"
  validation {
    condition     = contains(["enable", "disable"], lower(var.initial_artifact_enable))
    error_message = "initial_artifact_enable must be 'enable' or 'disable'."
  }
}

variable "external_trigger_account" {
  description = "Name of account for an external trigger"
  type        = string
  default     = ""
}

variable "external_trigger_region" {
  description = "Name of region for external trigger"
  type        = string
  default     = ""
}

variable "use_real_consul_tokens_sandbox" {
  description = "For sandbox only, whether or not to use real consul tokens"
  type        = bool
  default     = false
  validation {
    condition     = var.use_real_consul_tokens_sandbox == true || var.use_real_consul_tokens_sandbox == false
    error_message = "use_real_consul_tokens_sandbox must be a boolean."
  }
}

variable "enable_write_values_consul" {
  description = "Flag that will disable the upload of keys into consul for the metadata around the functions"
  type        = bool
  default     = true
  validation {
    condition     = var.enable_write_values_consul == true || var.enable_write_values_consul == false
    error_message = "enable_write_values_consul must be a boolean."
  }
}

variable "basic_egress_cidr" {
  description = "Basic egress CIDR"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  validation {
    condition     = alltrue([for c in var.basic_egress_cidr : can(cidrhost(c, 0))])
    error_message = "basic_egress_cidr must contain valid CIDRs IPv4, p. ej. 10.0.0.0/16."
  }
}

variable "dns_egress_cidr" {
  description = "DNS egress CIDR"
  type        = list(string)
  default     = ["192.168.20.0/30"]
  validation {
    condition     = alltrue([for c in var.dns_egress_cidr : can(cidrhost(c, 0))])
    error_message = "dns_egress_cidr must contain valid CIDRs IPv4, p. ej. 192.168.20.0/30."
  }
}

variable "egress_custom_rules" {
  description = "Custom Egress Rules for Lambda"
  type        = list(any)
  default     = []
}

variable "app_policy_directory" {
  description = "This indicates the directory where the above `app_policy` resides. For Gen4 support, the only value that can be used is `custom`."
  type        = string
  default     = "templates"
}

variable "app_policy_extension" {
  description = "This indicates the file extension for the above `app_policy`."
  type        = string
  default     = ".json.tmpl"
}

variable "iot_policy_directory" {
  description = "(Optional) specifies the directory of the IOT policy file"
  type        = string
  default     = "templates"
}

variable "iot_policy_extension" {
  description = "(Optional) override the default value for an IOT policy file extension"
  type        = string
  default     = ".json.tmpl"
}

variable "kms_key_arn" {
  description = "If set the KMS key provided will be used to encrypt the environment variables for the lambda function. If not using environment variables, ensure this is not set."
  type        = string
  default     = null
}

variable "custom_role_policy" {
  description = "Set to true to customize the role policy."
  type        = bool
  default     = false
  validation {
    condition     = var.custom_role_policy == true || var.custom_role_policy == false
    error_message = "custom_role_policy must be a boolean."
  }
}

variable "custom_role_file" {
  description = "This indicates the filename that contains the custom role policy."
  type        = string
  default     = ""
}

variable "custom_role_extension" {
  description = "This indicates the file extension for the above `custom_role_file`."
  type        = string
  default     = ""
}

variable "sns_custom_access_policy" {
  description = "Set to true to customize the SNS policy"
  default     = false
  type        = bool
  validation {
    condition     = var.sns_custom_access_policy == true || var.sns_custom_access_policy == false
    error_message = "sns_custom_access_policy must be a boolean."
  }
}

variable "ext_sqs_policy_name" {
  description = "Default policy name for external SQS resource. It was default to `SQS-lambda-trigger-policy` to keep back compatibility"
  type        = string
  default     = "SQS-lambda-trigger-policy"
}

variable "custom_sqs_write_policy" {
  description = "Set to true to customize the SQS write policy"
  type        = bool
  default     = false
  validation {
    condition     = var.custom_sqs_write_policy == true || var.custom_sqs_write_policy == false
    error_message = "custom_sqs_write_policy must be a boolean."
  }
}

variable "sqs_filtering_pattern" {
  description = "Allows Lambda functions to get events from SQS with a specified filter pattern"
  type        = map(any)
  default     = {}
}

variable "ext_sqs_filtering_pattern" {
  description = "Allows Lambda functions to get events from external SQS with a specified filter pattern"
  type        = map(any)
  default     = {}
}

variable "ddb_filtering_pattern" {
  description = "Allows Lambda functions to get events from DynamoDB with a specified filter pattern"
  type        = map(any)
  default     = {}
}

variable "lambda_alarms_custom_filter_metrics" {
  description = "List of maps with keys to configure filter metrics, alarms, sns topics, attach it to cloudwatch log group"
  type        = list(map(string))
  default     = []
}

variable "code_signing_config_arn" {
  description = "ARN of the Code Signing configuration to be used for the Lambda functions"
  type        = string
  default     = null
}

// no type since it is a map of bool, int, and list
variable "function_url" {
  description = "Creates a Lambda function URL resource"
  type        = map(any)
  default     = {}
}

variable "function_url_defaults" {
  description = "Default values for Lambda function URL. Do not change, use function_url instead"
  type = object({
    use_function_url  = bool
    enable_cors       = bool
    allow_credentials = bool
    allow_origins     = list(string)
    allow_methods     = list(string)
    allow_headers     = list(string)
    expose_headers    = list(string)
    max_age           = number
  })
  default = {
    "use_function_url"  = false
    "enable_cors"       = false
    "allow_credentials" = false
    "allow_origins"     = []
    "allow_methods"     = []
    "allow_headers"     = []
    "expose_headers"    = []
    "max_age"           = 0
  }
}

variable "snap_start" {
  description = "Snap start settings for low-latency startups for Java (Currently Supported)"
  type        = bool
  default     = false
  validation {
    condition     = var.snap_start == true || var.snap_start == false
    error_message = "snap_start must be a boolean."
  }
}

variable "ss_supported_version" {
  description = "Currently SnapStart supports the Java 11 and Java 17 (java11 and java17) managed runtimes Only. In future, if the snapshot support more runtimes. we shall override this variable."
  type        = list(any)
  default     = ["java11", "java17"]
  validation {
    condition     = alltrue([for v in var.ss_supported_version : contains(["java11", "java17"], tostring(v))])
    error_message = "ss_supported_version only allows: java11, java17."
  }
}
