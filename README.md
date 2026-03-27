# WDPR Lambda Workspaces v4.x
Infrastructure as a code (IaC) is a prerequisite for our common DevOps practices to deliver stable environments rapidly, reliably and at scale, avoiding manual configuration of multi-environments and enforcing consistency.

## Table of Contents

   1. [Workspace Overview](#1-workspace-overview)
   2. [General Information](#2-general-information)
   3. [Variables](#3-variables)
   4. [Resource](#4-resource)
   5. [Lambda Usage Details](#5-lambda-usage-details)

## 1. Workspace Overview
This repository provisions AWS Lambda functions, a serverless, event-driven compute service that lets you run code without provisioning or managing servers.

> **NOTICE**
>
> For Lambda Workspaces v3.x and above, you MUST reference terraform 14 in your atlantis.yaml
> The Variables defined here reference Lambda Workspaces **v4** and above.
>
> Please see [Readme for v4](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/blob/develop/READMEv2.md) if you are still using v2.x.
>
> There are breaking changes to the configuration that were introduced in **v4**
>
> Kinesis Changes: Prior to **v4** Kinesis streams were provided as part of this workspace but that is no longer the case. A Kinesis Stream **must** be provided to properly connect cloudwatch for ingestion into logging services such as Splunk.

Workspace Links:
- [Lambda Functions Overview](https://confluence.disney.com/display/DPEPRA/Lambda+Functions)
- [Lambda v2 to v3 Migration](https://confluence.disney.com/display/DPEPRA/Lambda+v2+to+v3+Migration)
- [Lambda v2 to v3 Migration Troubleshooting](https://confluence.disney.com/display/DPEPRA/Lambda+v2+to+v3+Migration#Lambdav2tov3Migration-Troubleshooting)
- [AWS Lambda - Java](https://confluence.disney.com/display/DPEPRA/AWS+Lambda+-+Java)
- [AWS Lambda - Node.js](https://confluence.disney.com/display/DPEPRA/AWS+Lambda+-+Node.js)
- [Custom Runtimes](https://confluence.disney.com/display/DPEPRA/Custom+Runtimes)
- [Lambda deployment using container images](https://confluence.disney.com/display/DPEPRA/Lambda+deployment+using+container+images)
- [Lambda Function URLs](https://confluence.disney.com/display/DPEPRA/Lambda+Function+URLs)

## 2. General Information

The **#terraform-worksapces** Slack channel is a good place to start if you have questions.  There are a number of linked references in the header and there is a history of common problems that can be searched.

General Workspace Links:
- [Workspace Listing](https://confluence.disney.com/display/DPEPRA/Infrastructure+Components) has support information, additional documentation, version history and more
- [Workspace Code Update/Promotion Process](https://confluence.disney.com/pages/viewpage.action?pageId=501287083) has information on how to contribute features and fixes
- [Troubleshooting Guide](https://confluence.disney.com/display/DPEPRA/Troubleshooting+Guide+-+Atlantis+and+Terraform) has common issues and solutions
- [Usage and Warnings](https://confluence.disney.com/display/DPEPRA/Terraform+Usage+and+Warnings)
- [Atlantis Locking Page](https://atlantis-engineer.wdprapps.disney.com/) has information on inprogress plans and Atlantis locks

<!-- BEGIN_TF_DOCS -->
### 3. Variables
This workspace requires certain variables to be filled out in order for it to function. Any variables that do not have a default value must be set in order for Atlantis/Terraform to run properly. These variables should be placed in the `env` directory, named using the following naming convention: `org-bag-snowid-reg-env-app.tfvars`

### One-Time Initial Configuration

This workspace has a special set of resources that allow the first time terraform run to properly succeed without any prior external interactions in regards to the zip/jar file for lambdas to be created. The below is all that needs to be set up.

* Initial Version: `artifact_version = 0.0.0`
* Initial Version only gets run on `latest` environment.
* That's it.
* The version `0.0.0` will automatically be created and uploaded to the proper S3 bucket as if CICD had deployed it

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account"></a> [account](#input\_account) | AWS Account Name to provision the infrastructure | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application | `string` | n/a | yes |
| <a name="input_artifact_base_name"></a> [artifact\_base\_name](#input\_artifact\_base\_name) | The base name of the artifact without the extension. Typically the name of the git repo. | `string` | n/a | yes |
| <a name="input_artifact_version"></a> [artifact\_version](#input\_artifact\_version) | The version of the artifact including build number to be deployed. This may be overridden by values in Consul driven by the Nimbus runs. Value would be found at `/terraform/wdpr-lambda-workspaces/<workspace_name>/config/version` | `string` | n/a | yes |
| <a name="input_bag"></a> [bag](#input\_bag) | Business Affinity group associated to the infrastructure | `string` | n/a | yes |
| <a name="input_bapp_id"></a> [bapp\_id](#input\_bapp\_id) | BAPP ID for which infrastructure is being provisioned | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for which infrastructure is being provisioned | `string` | n/a | yes |
| <a name="input_git_org"></a> [git\_org](#input\_git\_org) | The name of the git org where the code resides. | `string` | n/a | yes |
| <a name="input_git_repo"></a> [git\_repo](#input\_git\_repo) | The name of the git repo where the code resides. | `string` | n/a | yes |
| <a name="input_lambda_map"></a> [lambda\_map](#input\_lambda\_map) | (REQUIRED) Map of Maps which define the lambda functions and associated variables. See [Lambda Configuration](#lambda-configuration) | `map(any)` | n/a | yes |
| <a name="input_name_node_id"></a> [name\_node\_id](#input\_name\_node\_id) | Name\_Node\_ID for the Executive Owner for which infrastructure is being provisioned | `string` | n/a | yes |
| <a name="input_ownerorg"></a> [ownerorg](#input\_ownerorg) | Owner org for the infrastructure | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to provision the infrastructure | `string` | n/a | yes |
| <a name="input_snow_assignment_group"></a> [snow\_assignment\_group](#input\_snow\_assignment\_group) | This is the name of the assignment group in service now where incidents should be assigned. | `string` | n/a | yes |
| <a name="input_snow_configuration_item"></a> [snow\_configuration\_item](#input\_snow\_configuration\_item) | This is the name of the configuration item which your workspace is a part of. | `string` | n/a | yes |
| <a name="input_account_environments_path"></a> [account\_environments\_path](#input\_account\_environments\_path) | Non secrets account environments path | `string` | `"account_environments"` | no |
| <a name="input_alarm_sns_topic_account_name"></a> [alarm\_sns\_topic\_account\_name](#input\_alarm\_sns\_topic\_account\_name) | Map to define the account name for alarm SNS topic | `map(string)` | <pre>{<br>  "ra-sandbox": "wdpr-ra-sbx",<br>  "wdpr-sandbox": "dpep-wdpr-sbx"<br>}</pre> | no |
| <a name="input_alarm_sns_topic_account_suffix"></a> [alarm\_sns\_topic\_account\_suffix](#input\_alarm\_sns\_topic\_account\_suffix) | Map to define account suffix for alarm SNS topic | `map(string)` | <pre>{<br>  "dev": "dev",<br>  "prod": "prd",<br>  "sbx": "sbx",<br>  "test": "tst"<br>}</pre> | no |
| <a name="input_allow_cross_account_access_from"></a> [allow\_cross\_account\_access\_from](#input\_allow\_cross\_account\_access\_from) | List of account names to allow calling of these functions from a cross account perspective. Specifically this will grant these accounts the appropriate capability to call the functions defined. | `list(string)` | `[]` | no |
| <a name="input_app_policy"></a> [app\_policy](#input\_app\_policy) | This indicates that your lambdas utilize a secondary IAM policy defined in the `templates` folder named `$app_policy.json.tmpl`. Extra permissions, beyond those that are defined in the `lambda_policy.json.tmpl` need to be added here. For example, if your lambda function needs access to an S3 bucket outside of the default then it should be added here. Note that certain permissions for lambdas are added where there is a specific integration. | `string` | `""` | no |
| <a name="input_app_policy_directory"></a> [app\_policy\_directory](#input\_app\_policy\_directory) | This indicates the directory where the above `app_policy` resides. For Gen4 support, the only value that can be used is `custom`. | `string` | `"templates"` | no |
| <a name="input_app_policy_extension"></a> [app\_policy\_extension](#input\_app\_policy\_extension) | This indicates the file extension for the above `app_policy`. | `string` | `".json.tmpl"` | no |
| <a name="input_artifact_file_type"></a> [artifact\_file\_type](#input\_artifact\_file\_type) | The file type of the artifact. | `string` | `"zip"` | no |
| <a name="input_aws_accounts_path"></a> [aws\_accounts\_path](#input\_aws\_accounts\_path) | Non secrets AWS accounts path | `string` | `"aws/accounts"` | no |
| <a name="input_basic_egress_cidr"></a> [basic\_egress\_cidr](#input\_basic\_egress\_cidr) | Basic egress CIDR | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_bid"></a> [bid](#input\_bid) | BID for which infrastructure is being provisioned | `string` | `""` | no |
| <a name="input_code_signing_config_arn"></a> [code\_signing\_config\_arn](#input\_code\_signing\_config\_arn) | ARN of the Code Signing configuration to be used for the Lambda functions | `string` | `null` | no |
| <a name="input_code_version"></a> [code\_version](#input\_code\_version) | This will automatically be set to the absolute workspace code version by TPM and is used for Tagging | `string` | `""` | no |
| <a name="input_consul_config_base"></a> [consul\_config\_base](#input\_consul\_config\_base) | Consul base path for configurations | `string` | `"terraform/wdpr-lambda-workspaces"` | no |
| <a name="input_consul_defaults_path"></a> [consul\_defaults\_path](#input\_consul\_defaults\_path) | Full Non Secret path to workspace defaults | `string` | `"terraform/wdpr-lambda-workspaces/defaults"` | no |
| <a name="input_consul_functions_base"></a> [consul\_functions\_base](#input\_consul\_functions\_base) | Consul base path for functions | `string` | `"terraform/wdpr-lambda-workspaces"` | no |
| <a name="input_consul_nimbus_base"></a> [consul\_nimbus\_base](#input\_consul\_nimbus\_base) | Non Secret base path for nimbus configurations | `string` | `"terraform/wdpr-lambda-workspaces"` | no |
| <a name="input_custom_role_extension"></a> [custom\_role\_extension](#input\_custom\_role\_extension) | This indicates the file extension for the above `custom_role_file`. | `string` | `""` | no |
| <a name="input_custom_role_file"></a> [custom\_role\_file](#input\_custom\_role\_file) | This indicates the filename that contains the custom role policy. | `string` | `""` | no |
| <a name="input_custom_role_policy"></a> [custom\_role\_policy](#input\_custom\_role\_policy) | Set to true to customize the role policy. | `bool` | `false` | no |
| <a name="input_custom_sqs_write_policy"></a> [custom\_sqs\_write\_policy](#input\_custom\_sqs\_write\_policy) | Set to true to customize the SQS write policy | `bool` | `false` | no |
| <a name="input_ddb_filtering_pattern"></a> [ddb\_filtering\_pattern](#input\_ddb\_filtering\_pattern) | Allows Lambda functions to get events from DynamoDB with a specified filter pattern | `map(any)` | `{}` | no |
| <a name="input_dead_letter_queues"></a> [dead\_letter\_queues](#input\_dead\_letter\_queues) | A Dead Letter queue is a SQS queue that is utilized in case of an asynchronous lambda invocation that fails. | `map(map(any))` | <pre>{<br>  "default_fifo_sqs": {<br>    "content_based_deduplication": true,<br>    "fifo_queue": true,<br>    "name": "default_fifo_sqs"<br>  },<br>  "default_lambda": {<br>    "name": "default_lambda"<br>  },<br>  "default_sqs": {<br>    "name": "default_sqs"<br>  }<br>}</pre> | no |
| <a name="input_developer_override_var_map"></a> [developer\_override\_var\_map](#input\_developer\_override\_var\_map) | For develop purposes only. Override lambda environment variables. | `map(string)` | `{}` | no |
| <a name="input_developer_prefix"></a> [developer\_prefix](#input\_developer\_prefix) | Developer prefix | `string` | `""` | no |
| <a name="input_dlq_defaults"></a> [dlq\_defaults](#input\_dlq\_defaults) | Dead Letter Queue defaults | `map(any)` | <pre>{<br>  "content_based_deduplication": false,<br>  "delay_seconds": 0,<br>  "fifo_queue": false,<br>  "max_message_size": 262144,<br>  "message_retention_seconds": 1209600,<br>  "policy": "",<br>  "receive_wait_time_seconds": 0,<br>  "redrive_policy": "",<br>  "sqs_managed_sse_enabled": true,<br>  "visibility_timeout_seconds": 30<br>}</pre> | no |
| <a name="input_dns_egress_cidr"></a> [dns\_egress\_cidr](#input\_dns\_egress\_cidr) | DNS egress CIDR | `list(string)` | <pre>[<br>  "192.168.20.0/30"<br>]</pre> | no |
| <a name="input_dr_account"></a> [dr\_account](#input\_dr\_account) | Used to identify a Disaster Recovery account for being able to place some specific resources in a different account | `string` | `""` | no |
| <a name="input_dr_region"></a> [dr\_region](#input\_dr\_region) | Used to identify a `DR` region for being able to place some specific resources in a different region than the main resources. Example is to create an out of region cloudwatch trigger to call this lambda. This ensures that not only is the trigger able to connect to the lambda, but that it can come from outside the region itself. | `string` | `""` | no |
| <a name="input_egress_custom_rules"></a> [egress\_custom\_rules](#input\_egress\_custom\_rules) | Custom Egress Rules for Lambda | `list(any)` | `[]` | no |
| <a name="input_enable_write_values_consul"></a> [enable\_write\_values\_consul](#input\_enable\_write\_values\_consul) | Flag that will disable the upload of keys into consul for the metadata around the functions | `bool` | `true` | no |
| <a name="input_event_lambda_triggers"></a> [event\_lambda\_triggers](#input\_event\_lambda\_triggers) | If lambdas are to be called by event bridge rules, this will configure the rule and target to properly hit the lambda | `map(map(string))` | `{}` | no |
| <a name="input_ext_sqs_filtering_pattern"></a> [ext\_sqs\_filtering\_pattern](#input\_ext\_sqs\_filtering\_pattern) | Allows Lambda functions to get events from external SQS with a specified filter pattern | `map(any)` | `{}` | no |
| <a name="input_ext_sqs_policy_name"></a> [ext\_sqs\_policy\_name](#input\_ext\_sqs\_policy\_name) | Default policy name for external SQS resource. It was default to `SQS-lambda-trigger-policy` to keep back compatibility | `string` | `"SQS-lambda-trigger-policy"` | no |
| <a name="input_external_trigger_account"></a> [external\_trigger\_account](#input\_external\_trigger\_account) | Name of account for an external trigger | `string` | `""` | no |
| <a name="input_external_trigger_region"></a> [external\_trigger\_region](#input\_external\_trigger\_region) | Name of region for external trigger | `string` | `""` | no |
| <a name="input_filename"></a> [filename](#input\_filename) | If `package_source_location` is set to `local` then this will point to the local file which will be used for deployment. | `string` | `null` | no |
| <a name="input_function_url"></a> [function\_url](#input\_function\_url) | Creates a Lambda function URL resource | `map(any)` | `{}` | no |
| <a name="input_function_url_defaults"></a> [function\_url\_defaults](#input\_function\_url\_defaults) | Default values for Lambda function URL. Do not change, use function\_url instead | <pre>object({<br>    use_function_url  = bool<br>    enable_cors       = bool<br>    allow_credentials = bool<br>    allow_origins     = list(string)<br>    allow_methods     = list(string)<br>    allow_headers     = list(string)<br>    expose_headers    = list(string)<br>    max_age           = number<br>  })</pre> | <pre>{<br>  "allow_credentials": false,<br>  "allow_headers": [],<br>  "allow_methods": [],<br>  "allow_origins": [],<br>  "enable_cors": false,<br>  "expose_headers": [],<br>  "max_age": 0,<br>  "use_function_url": false<br>}</pre> | no |
| <a name="input_git_config_dir"></a> [git\_config\_dir](#input\_git\_config\_dir) | This will automatically be set to the folder within the repo git repo by TPM and is used for Tagging | `string` | `""` | no |
| <a name="input_git_config_org"></a> [git\_config\_org](#input\_git\_config\_org) | This will automatically be set to the git org of the config repo by TPM and is used for Tagging | `string` | `""` | no |
| <a name="input_git_config_repo"></a> [git\_config\_repo](#input\_git\_config\_repo) | This will automatically be set to the git repo by TPM and is used for Tagging | `string` | `""` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | If `package_source_location` is set to `image` then this will point at the ECR URI where the image resides | `string` | `null` | no |
| <a name="input_initial_artifact_account"></a> [initial\_artifact\_account](#input\_initial\_artifact\_account) | Initial artifact account | `string` | `"wdpr-apps"` | no |
| <a name="input_initial_artifact_enable"></a> [initial\_artifact\_enable](#input\_initial\_artifact\_enable) | Whether or not to create an initial artifact for latest environment | `string` | `"enable"` | no |
| <a name="input_initial_artifact_region"></a> [initial\_artifact\_region](#input\_initial\_artifact\_region) | Initial artifact region | `string` | `"us-east-1"` | no |
| <a name="input_invoke_permission_principal_map"></a> [invoke\_permission\_principal\_map](#input\_invoke\_permission\_principal\_map) | Map of principals to allow calling of these functions from. Specifically this will grant these accounts the appropriate capability to call the functions defined. | `map(map(string))` | `{}` | no |
| <a name="input_iot_policy"></a> [iot\_policy](#input\_iot\_policy) | (Optional) Set to the name of your template file without the extension if your lambda needs a trust relationship to iot.amazonaws.com. If the Lambda needs rights to anything iot:*, then this is likely needed. | `string` | `""` | no |
| <a name="input_iot_policy_directory"></a> [iot\_policy\_directory](#input\_iot\_policy\_directory) | (Optional) specifies the directory of the IOT policy file | `string` | `"templates"` | no |
| <a name="input_iot_policy_extension"></a> [iot\_policy\_extension](#input\_iot\_policy\_extension) | (Optional) override the default value for an IOT policy file extension | `string` | `".json.tmpl"` | no |
| <a name="input_kinesis_shard_count"></a> [kinesis\_shard\_count](#input\_kinesis\_shard\_count) | The number of shards that the stream will use. | `number` | `1` | no |
| <a name="input_kinesis_stream_mode"></a> [kinesis\_stream\_mode](#input\_kinesis\_stream\_mode) | Kinesis stream mode, either `PROVISIONED` or `ON_DEMAND` | `string` | `"PROVISIONED"` | no |
| <a name="input_kinesis_stream_name"></a> [kinesis\_stream\_name](#input\_kinesis\_stream\_name) | The common name of an existing Kinesis Stream. The Terraform will find this stream and attach the cloudwatch log groups to it. | `string` | `""` | no |
| <a name="input_kinesis_stream_suffix_custom"></a> [kinesis\_stream\_suffix\_custom](#input\_kinesis\_stream\_suffix\_custom) | provide a custom suffix | `string` | `""` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | If set the KMS key provided will be used to encrypt the environment variables for the lambda function. If not using environment variables, ensure this is not set. | `string` | `null` | no |
| <a name="input_lambda_alarms_actions_enabled"></a> [lambda\_alarms\_actions\_enabled](#input\_lambda\_alarms\_actions\_enabled) | Map of maps to enable or disable the alarm creation for a specific environment and alarm level. This can be used to cut down on alarm duplication by disabling one or more alarm levels (ie. disable warning & high but leave critical enabled) | `map(map(bool))` | <pre>{<br>  "dev2": {<br>    "critical": false,<br>    "high": false,<br>    "warning": false<br>  },<br>  "devtrue": {<br>    "critical": false,<br>    "high": false,<br>    "warning": false<br>  },<br>  "latest": {<br>    "critical": true,<br>    "high": true,<br>    "warning": true<br>  },<br>  "load": {<br>    "critical": true,<br>    "high": true,<br>    "warning": true<br>  },<br>  "load-dr": {<br>    "critical": true,<br>    "high": true,<br>    "warning": true<br>  },<br>  "loaddr": {<br>    "critical": true,<br>    "high": true,<br>    "warning": true<br>  },<br>  "prod": {<br>    "critical": true,<br>    "high": true,<br>    "warning": true<br>  },<br>  "prod-dr": {<br>    "critical": true,<br>    "high": true,<br>    "warning": true<br>  },<br>  "proddr": {<br>    "critical": true,<br>    "high": true,<br>    "warning": true<br>  },<br>  "sandbox": {<br>    "critical": false,<br>    "high": false,<br>    "warning": false<br>  },<br>  "shadow": {<br>    "critical": true,<br>    "high": true,<br>    "warning": true<br>  },<br>  "stage": {<br>    "critical": true,<br>    "high": true,<br>    "warning": true<br>  },<br>  "training": {<br>    "critical": true,<br>    "high": true,<br>    "warning": true<br>  }<br>}</pre> | no |
| <a name="input_lambda_alarms_custom_filter_metrics"></a> [lambda\_alarms\_custom\_filter\_metrics](#input\_lambda\_alarms\_custom\_filter\_metrics) | List of maps with keys to configure filter metrics, alarms, sns topics, attach it to cloudwatch log group | `list(map(string))` | `[]` | no |
| <a name="input_lambda_alarms_default_map"></a> [lambda\_alarms\_default\_map](#input\_lambda\_alarms\_default\_map) | A map of alarm thresholds, that is applied to each lambda to trigger warning/high/critical alarms that create Incidents in Service Now | `map(any)` | <pre>{<br>  "concurrent_execs_treat_missing_data": "notBreaching",<br>  "errors_critical_threshold": 15,<br>  "errors_high_threshold": 10,<br>  "errors_treat_missing_data": "notBreaching",<br>  "errors_warning_threshold": 3,<br>  "execution_time_treat_missing_data": "notBreaching",<br>  "max_concurrent_execs_critical_threshold": 0.99,<br>  "max_concurrent_execs_high_threshold": 0.95,<br>  "max_concurrent_execs_warning_threshold": 0.92,<br>  "max_duration_critical_threshold": 0.99,<br>  "max_duration_high_threshold": 0.95,<br>  "max_duration_warning_threshold": 0.9,<br>  "throttles_critical_threshold": 15,<br>  "throttles_high_threshold": 10,<br>  "throttles_treat_missing_data": "notBreaching",<br>  "throttles_warning_threshold": 3<br>}</pre> | no |
| <a name="input_lambda_definition_defaults"></a> [lambda\_definition\_defaults](#input\_lambda\_definition\_defaults) | Lambda definitions defaults | `map(any)` | <pre>{<br>  "dark_alias": "DARK",<br>  "ddb_trigger": false,<br>  "ddb_trigger_alias": "LIGHT",<br>  "ddb_trigger_batch_size": 100,<br>  "ddb_trigger_bisect_batch_on_function_error": false,<br>  "ddb_trigger_maximum_batching_window_in_seconds": 5,<br>  "ddb_trigger_maximum_record_age_in_seconds": 604800,<br>  "ddb_trigger_maximum_retry_attempts": 10000,<br>  "ddb_trigger_parallelization_factor": 1,<br>  "ddb_trigger_start_pos": "LATEST",<br>  "ddb_trigger_table_name": null,<br>  "dlq_name": "default_lambda",<br>  "efs_file_system_arn": null,<br>  "efs_local_mount_path": null,<br>  "enable_provisioned_concurrency": false,<br>  "ephemeral_storage": 512,<br>  "ext_sns_trigger": null,<br>  "ext_sns_trigger_alias": "LIGHT",<br>  "ext_sns_trigger_name": null,<br>  "ext_sqs_max_batching_window_in_seconds": 5,<br>  "ext_sqs_trigger": false,<br>  "ext_sqs_trigger_alias": "LIGHT",<br>  "ext_sqs_trigger_batch_size": 10,<br>  "ext_sqs_trigger_name": null,<br>  "image_config_command": null,<br>  "image_config_entry_point": null,<br>  "image_config_working_directory": null,<br>  "iot_policy": null,<br>  "kafka_bootstrap_servers": null,<br>  "kafka_source_access": null,<br>  "kafka_starting_position": null,<br>  "kafka_topics": null,<br>  "kafka_trigger": false,<br>  "kinesis_trigger": false,<br>  "kinesis_trigger_alias": "LIGHT",<br>  "kinesis_trigger_batch_size": 100,<br>  "kinesis_trigger_max_batching_window_in_seconds": null,<br>  "kinesis_trigger_max_record_age_in_seconds": 86400,<br>  "kinesis_trigger_max_retry_attempts": 2,<br>  "kinesis_trigger_stream_name": null,<br>  "lambda_memory_size": 128,<br>  "lambda_publish": true,<br>  "lambda_runtime": "nodejs20.x",<br>  "lambda_timeout": 10,<br>  "light_alias": "LIGHT",<br>  "provisioned_concurrency": 0,<br>  "reserved_concurrent_executions": 10,<br>  "retention_in_days": 90,<br>  "s3_trigger": false,<br>  "s3_trigger_alias": "LIGHT",<br>  "s3_trigger_bucket": null,<br>  "s3_trigger_event": "s3:ObjectCreated:*",<br>  "s3_trigger_prefix": null,<br>  "s3_trigger_suffix": null,<br>  "sns_protocol": "lambda",<br>  "sns_trigger": false,<br>  "sns_trigger_alias": "LIGHT",<br>  "sqs_redrive_queue_name": "default_sqs",<br>  "sqs_trigger": false,<br>  "sqs_trigger_alias": "LIGHT",<br>  "tracing_config": null,<br>  "use_vpc": false<br>}</pre> | no |
| <a name="input_lambda_global_tags_map"></a> [lambda\_global\_tags\_map](#input\_lambda\_global\_tags\_map) | Map of global tags that will be applied to all lambdas. | `string` | `"  {\n    \"environment\": \"override environment\"\n  }\n"` | no |
| <a name="input_lambda_global_vars_map"></a> [lambda\_global\_vars\_map](#input\_lambda\_global\_vars\_map) | Global variable map, will be applied to all lambdas (environment, region, etc) | `string` | `"  {\n    \"environment\": \"override environment\"\n  }\n"` | no |
| <a name="input_lambda_iam_role_override"></a> [lambda\_iam\_role\_override](#input\_lambda\_iam\_role\_override) | If this is set than terraform wont create IAM role for lambda and use this role instead, (Primarily for sandbox) | `string` | `""` | no |
| <a name="input_lambda_layers"></a> [lambda\_layers](#input\_lambda\_layers) | List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function. See [Lambda Layers](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html) | `list(string)` | `[]` | no |
| <a name="input_lambdafunction_logfilters"></a> [lambdafunction\_logfilters](#input\_lambdafunction\_logfilters) | Map of lambda cloudwatch log subscription filters | `map(map(string))` | `{}` | no |
| <a name="input_lower_env_priority_path"></a> [lower\_env\_priority\_path](#input\_lower\_env\_priority\_path) | Non secrets Prod tier urgencies priority path | `string` | `"snow/lower_env_priority"` | no |
| <a name="input_non_secret_vault_role"></a> [non\_secret\_vault\_role](#input\_non\_secret\_vault\_role) | non secret vault role | `string` | `"ee-atlantis-tokengen"` | no |
| <a name="input_non_secret_vault_url"></a> [non\_secret\_vault\_url](#input\_non\_secret\_vault\_url) | non secret vault url | `string` | `"https://vault-use1.wdprapps.disney.com"` | no |
| <a name="input_override_consul_artifact_version"></a> [override\_consul\_artifact\_version](#input\_override\_consul\_artifact\_version) | Flag that will force the `artifact_version` variable to be used instead of one pulled from non\_secrets (as set by the Nimbus deployment) | `bool` | `false` | no |
| <a name="input_package_source_location"></a> [package\_source\_location](#input\_package\_source\_location) | The type of package source to be used: `[s3, local, image]` | `string` | `"s3"` | no |
| <a name="input_package_type"></a> [package\_type](#input\_package\_type) | This value indicates whether the package is a `Zip` (s3/local) or `Image` (image) and informs AWS how to treat the deployment | `string` | `"Zip"` | no |
| <a name="input_prod_tier_urgencies_priority_path"></a> [prod\_tier\_urgencies\_priority\_path](#input\_prod\_tier\_urgencies\_priority\_path) | Non secrets Prod tier urgencies priority path | `string` | `"snow/prod_tier_urgencies_priority"` | no |
| <a name="input_provider_assumed_role"></a> [provider\_assumed\_role](#input\_provider\_assumed\_role) | By default the role that Terraform assumes in the destination account is `WDPR-cross-Atlantis` and can be overridden if necessary | `string` | `"WDPR-cross-Atlantis"` | no |
| <a name="input_s3_existing_package"></a> [s3\_existing\_package](#input\_s3\_existing\_package) | This defines the s3 source location information. By default, all values will be calculated based on other values, but explicit overrides can be provided here. `s3_existing_package` is a map variable with expected properties of `bucket`, `key` and `version_id`. Each of these can independently be `null` (default) and the calculate values will be used. | `map(string)` | `null` | no |
| <a name="input_scheduled_lambda_triggers"></a> [scheduled\_lambda\_triggers](#input\_scheduled\_lambda\_triggers) | If lambdas are called by scheduled triggers provide a list | `map(map(string))` | `{}` | no |
| <a name="input_scheduled_lambda_triggers_dr"></a> [scheduled\_lambda\_triggers\_dr](#input\_scheduled\_lambda\_triggers\_dr) | Lambda triggers to be placed in a `DR` region, separate from the main deployment of the lambda functions themselves. DR is used as a convenient descriptor. | `map(map(string))` | `{}` | no |
| <a name="input_se_contact"></a> [se\_contact](#input\_se\_contact) | This will automatically be set to the user running the terraform command by TPM and is used for Tagging | `string` | `""` | no |
| <a name="input_secrets_account"></a> [secrets\_account](#input\_secrets\_account) | Secrets account | `string` | `"wdpr-apps"` | no |
| <a name="input_secrets_region"></a> [secrets\_region](#input\_secrets\_region) | Secrets Region | `string` | `"us-east-1"` | no |
| <a name="input_snap_start"></a> [snap\_start](#input\_snap\_start) | Snap start settings for low-latency startups for Java (Currently Supported) | `bool` | `false` | no |
| <a name="input_snow_tier"></a> [snow\_tier](#input\_snow\_tier) | Application tier for routing alarm levels to specific priority levels. | `number` | `3` | no |
| <a name="input_sns_custom_access_policy"></a> [sns\_custom\_access\_policy](#input\_sns\_custom\_access\_policy) | Set to true to customize the SNS policy | `bool` | `false` | no |
| <a name="input_sns_defaults"></a> [sns\_defaults](#input\_sns\_defaults) | Map of default sns trigger settings | `map(any)` | <pre>{<br>  "sns_app_success_sample_rate": 100,<br>  "sns_delivery_backoff_function": "exponential",<br>  "sns_delivery_max_delay_target": 30,<br>  "sns_delivery_min_delay_target": 10,<br>  "sns_delivery_num_max_delays_retry": 3,<br>  "sns_delivery_num_min_delays_retry": 3,<br>  "sns_delivery_num_no_delays_retry": 1,<br>  "sns_delivery_num_retry": 100,<br>  "sns_disable_subscription_overrides": false,<br>  "sns_http_success_sample_rate": 100,<br>  "sns_lambda_success_sample_rate": 100,<br>  "sns_log_group_retention_in_days": 90,<br>  "sns_protocol": "lambda",<br>  "sns_sqs_success_sample_rate": 100,<br>  "sns_throttle_max_receives_per_second": 1<br>}</pre> | no |
| <a name="input_sqs_defaults"></a> [sqs\_defaults](#input\_sqs\_defaults) | Map of default sqs trigger settings | `map(any)` | <pre>{<br>  "sqs_batch_size": 10,<br>  "sqs_content_based_deduplication": false,<br>  "sqs_delay_seconds": 0,<br>  "sqs_fifo_queue": false,<br>  "sqs_managed_sse_enabled": true,<br>  "sqs_max_batching_window_in_seconds": 5,<br>  "sqs_max_msg_size": 262144,<br>  "sqs_msg_retention_seconds": 1209600,<br>  "sqs_receive_wait_time_seconds": 0,<br>  "sqs_redrive_max_recv_count": 3,<br>  "sqs_redrive_queue_name": "default_sqs"<br>}</pre> | no |
| <a name="input_sqs_filtering_pattern"></a> [sqs\_filtering\_pattern](#input\_sqs\_filtering\_pattern) | Allows Lambda functions to get events from SQS with a specified filter pattern | `map(any)` | `{}` | no |
| <a name="input_sqs_report_batch_item_failures"></a> [sqs\_report\_batch\_item\_failures](#input\_sqs\_report\_batch\_item\_failures) | To control whether the Lambda function should report batch item failures when processing events from SQS event sources. Allowed values are and empty list ([]) or a list containing only ["ReportBatchItemFailures"]. | `map(any)` | <pre>{<br>  "ext_sqs_function_response_types": [],<br>  "sqs_function_response_types": []<br>}</pre> | no |
| <a name="input_ss_supported_version"></a> [ss\_supported\_version](#input\_ss\_supported\_version) | Currently SnapStart supports the Java 11 and Java 17 (java11 and java17) managed runtimes Only. In future, if the snapshot support more runtimes. we shall override this variable. | `list(any)` | <pre>[<br>  "java11",<br>  "java17"<br>]</pre> | no |
| <a name="input_terraform"></a> [terraform](#input\_terraform) | This will automatically be filled in by Terraform | `map(string)` | `{}` | no |
| <a name="input_terraform_workspace_type"></a> [terraform\_workspace\_type](#input\_terraform\_workspace\_type) | This identifies the workspace and is used for Tagging | `string` | `"wdpr-lambda-workspaces"` | no |
| <a name="input_use_kinesis_stream"></a> [use\_kinesis\_stream](#input\_use\_kinesis\_stream) | Flag to enable the use of a Kinesis stream. When enabled, you can either create or use a preexistent one. To create, don't set kinesis\_stream\_name,  you can either customize the prefix using kinesis\_stream\_suffix\_custom.  To use a preexistent kinesis stream, set the variable kinesis\_stream\_name | `bool` | `false` | no |
| <a name="input_use_real_consul_tokens_sandbox"></a> [use\_real\_consul\_tokens\_sandbox](#input\_use\_real\_consul\_tokens\_sandbox) | For sandbox only, whether or not to use real consul tokens | `bool` | `false` | no |
| <a name="input_user_tags"></a> [user\_tags](#input\_user\_tags) | Additional tags if needed. #DO NOT REDEFINE STANDARD TAGS!! | `map(any)` | `{}` | no |
| <a name="input_vpc_info"></a> [vpc\_info](#input\_vpc\_info) | A map which contains two properties: `vpc_name` and `subnet_list`. These are referenced by their common names as seen in the AWS console. See below for example | <pre>object({<br>    vpc_name    = optional(string)<br>    subnet_list = optional(list(string))<br>  })</pre> | `{}` | no |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_derived_version"></a> [derived\_version](#output\_derived\_version) | Derived version |
| <a name="output_kinesis_stream_names"></a> [kinesis\_stream\_names](#output\_kinesis\_stream\_names) | n/a |
| <a name="output_lambda_alias_function_names"></a> [lambda\_alias\_function\_names](#output\_lambda\_alias\_function\_names) | lambda\_alias\_function\_names |
| <a name="output_lambda_alias_names"></a> [lambda\_alias\_names](#output\_lambda\_alias\_names) | lambda\_alias\_names |
| <a name="output_lambda_alias_short_name_list"></a> [lambda\_alias\_short\_name\_list](#output\_lambda\_alias\_short\_name\_list) | lambda\_alias\_short\_name\_list |
| <a name="output_lambda_alias_short_name_to_invoke_arn_mapping"></a> [lambda\_alias\_short\_name\_to\_invoke\_arn\_mapping](#output\_lambda\_alias\_short\_name\_to\_invoke\_arn\_mapping) | lambda\_alias\_short\_name\_to\_invoke\_arn\_mapping |
| <a name="output_lambda_aliases"></a> [lambda\_aliases](#output\_lambda\_aliases) | lambda\_aliases |
| <a name="output_lambda_cloudwatch_dr_trigger_arns"></a> [lambda\_cloudwatch\_dr\_trigger\_arns](#output\_lambda\_cloudwatch\_dr\_trigger\_arns) | lambda\_cloudwatch\_dr\_trigger\_arns |
| <a name="output_lambda_cloudwatch_trigger_arns"></a> [lambda\_cloudwatch\_trigger\_arns](#output\_lambda\_cloudwatch\_trigger\_arns) | lambda\_cloudwatch\_trigger\_arns |
| <a name="output_lambda_cross_account_allow_invoke_from"></a> [lambda\_cross\_account\_allow\_invoke\_from](#output\_lambda\_cross\_account\_allow\_invoke\_from) | lambda\_cross\_account\_allow\_invoke\_from |
| <a name="output_lambda_dlq_arns"></a> [lambda\_dlq\_arns](#output\_lambda\_dlq\_arns) | lambda\_dlq\_arns |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | lambda\_function\_arn |
| <a name="output_lambda_function_invoke_arn"></a> [lambda\_function\_invoke\_arn](#output\_lambda\_function\_invoke\_arn) | lambda\_function\_invoke\_arn |
| <a name="output_lambda_function_qualified_arn"></a> [lambda\_function\_qualified\_arn](#output\_lambda\_function\_qualified\_arn) | lambda\_function\_qualified\_arn |
| <a name="output_lambda_function_short_name_to_arn_mapping"></a> [lambda\_function\_short\_name\_to\_arn\_mapping](#output\_lambda\_function\_short\_name\_to\_arn\_mapping) | lambda\_function\_short\_name\_to\_arn\_mapping |
| <a name="output_lambda_invocation_role_arn"></a> [lambda\_invocation\_role\_arn](#output\_lambda\_invocation\_role\_arn) | lambda\_invocation\_role\_arn |
| <a name="output_lambda_sns_trigger_arns"></a> [lambda\_sns\_trigger\_arns](#output\_lambda\_sns\_trigger\_arns) | lambda\_sns\_trigger\_arns |
| <a name="output_lambda_sns_trigger_failure_log_groups"></a> [lambda\_sns\_trigger\_failure\_log\_groups](#output\_lambda\_sns\_trigger\_failure\_log\_groups) | lambda\_sns\_trigger\_failure\_log\_groups |
| <a name="output_lambda_sns_trigger_ids"></a> [lambda\_sns\_trigger\_ids](#output\_lambda\_sns\_trigger\_ids) | lambda\_sns\_trigger\_ids |
| <a name="output_lambda_sns_trigger_success_log_groups"></a> [lambda\_sns\_trigger\_success\_log\_groups](#output\_lambda\_sns\_trigger\_success\_log\_groups) | lambda\_sns\_trigger\_success\_log\_groups |
| <a name="output_lambda_sqs_trigger_arns"></a> [lambda\_sqs\_trigger\_arns](#output\_lambda\_sqs\_trigger\_arns) | lambda\_sqs\_trigger\_arns |
| <a name="output_lambda_sqs_trigger_ids"></a> [lambda\_sqs\_trigger\_ids](#output\_lambda\_sqs\_trigger\_ids) | lambda\_sqs\_trigger\_ids |

### 4. Resource

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.10.0 |
| <a name="provider_aws.dr"></a> [aws.dr](#provider\_aws.dr) | ~> 6.10.0 |
| <a name="provider_aws.external_sns_trigger"></a> [aws.external\_sns\_trigger](#provider\_aws.external\_sns\_trigger) | ~> 6.10.0 |
| <a name="provider_aws.external_trigger"></a> [aws.external\_trigger](#provider\_aws.external\_trigger) | ~> 6.10.0 |
| <a name="provider_aws.init_artifact"></a> [aws.init\_artifact](#provider\_aws.init\_artifact) | ~> 6.10.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.5 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |
| <a name="provider_vault.non_secret"></a> [vault.non\_secret](#provider\_vault.non\_secret) | ~> 5.2.1 |

#### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_global-config"></a> [global-config](#module\_global-config) | git::ssh://git@github.disney.com/dpep-terraform-modules/global-config.git | v4.x |

#### Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.event_lambda_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.scheduled_lambda_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.scheduled_lambda_trigger_dr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.event_lambda_trigger_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.scheduled_lambda_trigger_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.scheduled_lambda_trigger_target_dr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.sns_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.sns_default_failure](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_metric_filter.lambda_custom_filter_metrics_pattern](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_subscription_filter.lambdafunction_logfilter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_cloudwatch_log_subscription_filter.logfilter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_cloudwatch_log_subscription_filter.logfilter_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | resource |
| [aws_cloudwatch_metric_alarm.concurrent_execs_critical](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.concurrent_execs_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.concurrent_execs_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.errors_critical](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.errors_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.errors_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.execution_time_critical](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.execution_time_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.execution_time_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.lambda_custom_filter_metrics_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.throttles_critical](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.throttles_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.throttles_warning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_policy.ddb_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ext_sqs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.invocation_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.lambda_iot_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.app_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.invocation_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.lambda_iot_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ddb_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ext_sqs_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_stream.stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream) | resource |
| [aws_lambda_alias.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_alias) | resource |
| [aws_lambda_event_source_mapping.dynamodb_stream_source_mapping](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.ext_sqs_lambda_event_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.kafka_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.kinesis_event_source_mapping](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_event_source_mapping.sqs_lambda_event_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_url.alias_function_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url) | resource |
| [aws_lambda_function_url.default_function_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url) | resource |
| [aws_lambda_permission.allow_cloudwatch_to_lambdafunction_logfilter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.cross_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.cross_account_add_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.cross_account_allow_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.event_lambda_trigger_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.ext_sns_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.invoke_permission_qualified](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.invoke_permission_unqualified](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.s3_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.scheduled_lambda_trigger_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.scheduled_lambda_trigger_permission_dr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.sns_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_provisioned_concurrency_config.provisioned_concurrency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_provisioned_concurrency_config) | resource |
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_object.initial_artifact](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_security_group.lambda_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress_custom_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_sns_topic.lambda_custom_filter_metrics_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic.sns_lambda_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.sns_lambda_trigger_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.ext_sns_lambda_trigger_sub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.sns_lambda_trigger_sub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sqs_queue.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.sqs_lambda_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [null_resource.ext_sns_add_permissions](https://registry.terraform.io/providers/hashicorp/null/3.2.4/docs/resources/resource) | resource |
| [null_resource.ext_sns_removepermissions](https://registry.terraform.io/providers/hashicorp/null/3.2.4/docs/resources/resource) | resource |
| [null_resource.ext_sqs_set_permissions](https://registry.terraform.io/providers/hashicorp/null/3.2.4/docs/resources/resource) | resource |
| [vault_kv_secret_v2.lambda_function_conf](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |
| [vault_kv_secret_v2.lambda_functions](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |
<!-- END_TF_DOCS -->

### vpc_info variable

 The vpc_info variable defines the vpc configuration to be used and should be defined as below:

 ```hcl
    vpc_info = {
      vpc_name = "wdpr-ee-nb-use1-latest"
      subnet_list = ["wdpr-ee-nb-use1-latest-private-0","wdpr-ee-nb-use1-latest-private-1","wdpr-ee-nb-use1-latest-private-2"]
    }
 ```
 
### invoke_permission_principal_list variables

The invoke_permission_principal_list variable define a list of principals that should be defined as shown:  

```hcl
  invoke_permission_principal_map = {
      "permission1" = {
        type = "role" 
        account = "wdpr-ee-dev"
        value = "WDPR-DEVELOPER"
      }
  }
 ```

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `type` | Principal type defined as [user,role,account,root,service] | None | `string` |
| `account` | AWS Account Name i.e. wdpr-apps | None | `string` |
| `value` | Define the principal resource name i.e for a type role its value would be WDPR-DEVELOPER | None | `string` |

for each principal the /scripts/renderPrincipal.sh gives back the AWS Principal as follow

| types| Description |
| -----| ----------- |
|user|arn:aws:iam::633112549318:user/user-name |
|role|arn:aws:iam::633112549318:role/WDPR-DEVELOPER |
|account|123456789012 |
|root|arn:aws:iam::123456789012:root |
|CanonicalUser|79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be |
|Federated|arn:aws:iam::123456789012:saml-provider/provider-name |
|Federated|accounts.google.com |
|Services|elasticmapreduce.amazonaws.com |

---

## 5. Lambda Usage Details

### Configuration Format

In order to properly utilize this workspace you must understand the configuration structure, the variable definitions and their capabilities and limitations. The overall tfvars file structure will broken down below.

### Basic Configuration Variables

These values should be standard and self explanatory. Be aware of their importance though as they drive the naming convention of the infrastructure components.

```yaml
account          = "ra-sandbox"
application_name = "gwauth"
environment      = "sandbox"
region           = "us-east-1"
bag              = "ra"
bapp_id          = "TBD"
node_name_id     = "TBD"
ownerorg         = "wdpr"
```

### Artifact Configuration

These variables define the location of where the lambda artifact will be sourced from. The git repository and the artifact base name will most always match, but there may be exceptions. The bucket name will always be a base value of `wdpr-lambda-deploy` and going forward will be suffixed with the region in short form: ie. `use1` for a bucket value of `wdpr-lambda-deploy-use1`

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `package_source_location` | The type of package source to be used: `[s3, local, image]` | `s3` | `string` |
| `s3_existing_package` | This defines the s3 source location information. By default, all values will be calculated based on other values, but explicit overrides can be provided here. `s3_existing_package` is a map variable with expected properties of `bucket`, `key` and `version_id`. Each of these can independently be `null` (default) and the calculate values will be used. | `null` | `map` |
| `image_uri` | if `package_source_location` is set to `image` then this will point at the ECR URI where the image resides | `null` | `string` |
| `filename` | if `package_source_location` is set to `local` then this will point to the local file which will be used for deployment. | `null` | `string` |
| `package_type` | This value indicates whether the package is a `Zip` (s3/local) or `Image` (image) and informs AWS how to treat the deployment | `Zip` | `string` |
| `git_org` | The name of the git org where the code resides. | None | `string` |
| `git_repo` | The name of the git repo where the code resides. | None | `string` |
| `artifact_version` | The version of the artifact including build number to be deployed. This may be overridden by values in Consul driven by the Nimbus runs. Value would be found at `/terraform/wdpr-lambda-workspaces/<workspace_name>/config/version` | None | `string` |
| `artifact_base_name` | The base name of the artifact without the extension. Typically the name of the git repo. | None | `string` |
| `artifact_file_type` | The file type of the artifact. | `zip` | `string` |

#### S3 location calculation

There are several variables that are utilized to build the location of the artifact in the s3 bucket. The bucket is automatically determined based on the `region` and will be one of the default lambda artifact buckets `wdpr-lambda-deploy-[use1|usw2|euw1]` but any bucket can be used. The `s3_existing_package` can specify the bucket via the `bucket` property on that map.

The path in s3 is calculated in the following manner:
`default_lambda_deploy_s3_key                  = format("%s/%s/%s/%s.%s", var.git_org, var.git_repo, local.derived_version, var.artifact_base_name, var.artifact_file_type)`

```yaml
##############################
# Lambda Code Artifact Deployment Location
##############################
git_org                    = "wdpr-ra"
git_repo                   = "wdpr-ra-node-lambda-authorizer"
artifact_version           = "0.0.7-15.0.0.0"
artifact_base_name         = "wdpr-ra-node-lambda-authorizer"
```

### Global Configuration

These variables relate to all your lambdas defined in a single workspace at the 'global' level. They can be applied to each lambda without repeating specifically for every one.

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `app_policy`| This indicates that your lambdas utilize a secondary IAM policy defined in the `templates` folder named `$app_policy.json.tmpl`. Extra permissions, beyond those that are defined in the `lambda_policy.json.tmpl` need to be added here. For example, if your lambda function needs access to an S3 bucket outside of the default then it should be added here. Note that certain permissions for lambdas are added where there is a specific integration.| None | `string` |
| `app_policy_directory` | This indicates the directory where the above `app_policy` resides. For Gen4 support, the only value that can be used is `custom`. | `templates` | `string` |
| `app_policy_extension` | This indicates the file extension for the above `app_policy`. | `.json.tmpl` | `string` |
| `snow_assignment_group`| This is the name of the assignment group in service now where incidents should be assigned.| None | `string` |
| `snow_configuration_item`| This is the name of the configuration item which your workspace is a part of.| None | `string` |
| `snow_tier` | This is the Service Now Application tier designation. | `3` | `number` |
| `lambda_global_vars_map`| Utilize this variable to define global environment variables that each lambda defined in your workspace will have access to. No need to repeat the variable for each function. These can be overridden at the lambda level. | None | `string` (encoded json via [HEREDOC](https://en.wikipedia.org/wiki/Here_document) format) |
| `lambda_global_tags_map` | Utilize this variable to define global tags that each lambda defined in your workspace will be tagged with. These can be overridden at the lambda level | None | `string` (encoded json via [HEREDOC](https://en.wikipedia.org/wiki/Here_document) format) |
| `allow_cross_account_access_from` | A list of account names which are then granted rights to invoke the lambda functions defined in this workspace. | None| `string` |
| `lambda_alarms_default_map` | A map of alarm thresholds, that is applied to each lambda to trigger warning/high/critical alarms that create Incidents in Service Now | See the variables.tf | `map` |
| `enable_write_values_consul` | Flag that will disable the upload of keys into consul for the metadata around the functions | `true` | `string` (boolean value) |
| `override_consul_artifact_version` | Flag that will force the `artifact_version` variable to be used instead of one pulled from consul (as set by the Nimbus deployment) | `false` | `string` (boolean value) |
| `lambda_alarms_actions_enabled` | Map of maps to enable or disable the alarm creation for a specific environment and alarm level. This can be used to cut down on alarm duplication by disabling one or more alarm levels (ie. disable warning & high but leave critical enabled) | enabled for all but sandbox | `map(map(bool))` example see below |
| `kms_key_arn` | If set the KMS key provided will be used to encrypt the environment variables for the lambda function. If not using environment variables, ensure this is not set. | `null` | `string` |
| `use_kinesis_stream` | Flag to enable the use of a Kinesis stream. If set to false, you should also pass an empty string for `kinesis_stream_name` | `false` | `bool` |
| `kinesis_stream_name` | The common name of an existing Kinesis Stream. The Terraform will find this stream and attach the cloudwatch log groups to it. | `None` | `string` |
| `kinesis_stream_suffix_custom` | Provide a custom suffix for naming the Kinesis stream resource. | `""` | `string` |
| `kinesis_stream_mode` | Kinesis stream mode, either `PROVISIONED` or `ON_DEMAND` | `PROVISIONED` | `string` |
| `kinesis_shard_count` | The number of shards that the stream will use | `1` | `string` |
|  `ext_sqs_policy_name`| Default policy name for external SQS resource. It was default to `SQS-lambda-trigger-policy` to keep back compatibility  | `SQS-lambda-trigger-policy` | `string` |
|  `sns_custom_access_policy`| Set to true to customize the SNS policy  | `false` | `bool` |
|  `custom_sqs_write_policy`| Set to true to customize the SQS write policy  | `false` | `bool` |

```yaml
app_policy                     = "my-custom-app-policy"
app_policy_directory           = "custom"
app_policy_extension           = ".json.tmpl"

snow_assignment_group   = "ops-global-wdpr-ra"
snow_configuration_item = "WDPRT AWS Gateway Authorizer"

lambda_global_vars_map = <<DOC
{
  "environment": "$${environment}",
  "region": "$${region}"
}
DOC

lambda_alarms_actions_enabled = {
  "latest" = {
    "warning"  = false
    "high"     = false
    "critical" = true
  }
}
```

### Lambda Configuration

The `lambda_map` variable contains the definition of all of your lambda functions in a single workspace. This is an map of maps. Some of these are fairly self explanatory but they are all detailed here. Note that all but required values have a default value and therefore do not need to be defined in your tfvars file. The exception to that rule is `name`, `function_handler`, `snow_description`, `var_map` and `tag_map` (these last two can simply be `"{}"` empty maps).

| Variable | Description | Default | Type | Required |
|----------|-------------|-------- | ---- |----------|
|  `name`| (Required) The base name of a lambda function. This is the reference name for the function and must be unique. The actual lambda function name will be constructed of several more variables that identify it more clearly.| `null` | `string` | Y        |
|  `function_handler`|  (Required) this indicates where your function handler lives and the name of the handler. Typically this will be at the root of your zip file and also be named the same of your function. Recommendation is `handler` be the implementation method.| `None` | `string` | Y        |
|  `lambda_runtime`|  (Required) The AWS lambda runtime for your function.| `nodejs20.x` | `string` | Y        |
|  `lambda_memory_size`|  (Required) The size in MB of memory your lambda will be allocated| `128` | `string` | Y        |
|  `lambda_timeout`|  (Required) The number of seconds that your lambda function may run, this is a hard stop limit.| `10` | `string` | Y        |
|  `lambda_publish`|  (Required) Whether or not to actively publish this lambda function (most times it should be true)| `true` | `string` | Y        |
|  `light_alias` | (Required) The name of the light alias. | `LIGHT` | `string` | Y        |
|  `dark_alias` | (Required) The name of the dark alias. | `DARK` | `string` | Y        |
|  `reserved_concurrent_executions` |  (Required) The number of concurrent executions of your function that are allowed, this is a required value.| `10` | `string` | Y        |
|  `retention_in_days`|  (Required) The number of days the log group for this function will hold onto logs (90 is the standard value but lower can be set)| `90` | `string` | Y        |
|  `use_vpc`|  (Required) Triggers whether this lambda function will be allowed access to the vpc parameters above.| `false` | `bool` | Y        |
|  `dlq_name`|  (Required) Sets up the connection of this lambda to a dead letter queue (see below for [Dead Letter Queue Configuration](#dead-letter-queue-configuration))| `default_lambda` | `string` | Y        |
|  `tracing_config`|  (Required) Can be either PassThrough or Active.  If PassThrough, only trace the request from an upstream service if it contains a tracing header with "sampled=1" If Active, Lambda will respect any tracing header it receives from an upstream service. If no tracing header is received, Lambda will call X-Ray for a tracing decision. | `null` | `string` | Y        |
| `ephemeral_storage` | (Optional) The amount of Ephemeral storage(/tmp) to allocate for the Lambda Function in MB. This parameter is used to expand the total amount of Ephemeral storage available, beyond the default amount of 512MB. | `512` | `string` | Y        |
|  `snow_description` | (Required) A textual description that will be used when service now alerts are created for this Lambda function. Ensure this is descriptive enough to be useful | `null` | `string` | Y        |
|  `var_map`|  (Required) This is a map of environment variables that will be applied to your lambda function. You can utilize variable replacement via the notation `${}`. The variables that are allowed to be used as replacement are limited. See below for [SQS configuration](#sqs-lambda-event-sources).| `null` | `string` | Y        |
|  `tag_map`|  (Required) This is a map of tags to apply to your function. There are default tags that will be added to each function automatically such as bapp_id. You can utilize the same variable replacement that the `var_map` uses.| `null` | `string` | Y        |
| Image Configuration |
| `image_config_entry_point` | If `package_source_location` is set to `image`, the entrypoint configuration for the Image that is used as the artifact for this lambda. | `null` | `string` |
| `image_config_command` | If `package_source_location` is set to `image`, the command configuration for the Image that is used as the artifact for this lambda. | `null` | `string` |
| `image_config_working_directory` | If `package_source_location` is set to `image`, the working directory for the Image that is used as the artifact for this lambda. | `null` | `string` |
| EFS File System Configuration |
| `efs_file_system_arn` | If configuring an EFS file system for lambda shared storage this is the ARN of the EFS mount. This feature is untested | `null` | `string` |
| `efs_local_mount_path` | If configuring an EFS file system for lambda shared storage this is the mount point of the EFS mount. This feature is untested. | `null` | `string` |
| IOT Configuration |
|  `iot_policy`|  (Optional) Set to the name of your template file without the extension if your lambda needs a trust relationship to iot.amazonaws.com. If the Lambda needs rights to anything iot:*, then this is likely needed. | `null` | `string` | N        |
| SQS Triggers |
| `iot_policy_extension` | (Optional) override the default value for an IOT policy file extension | `.json.tmpl` | `string` |
| `iot_policy_directory` | (Optional) specifies the directory of the IOT policy file | `templates` | `string` |  
|  `sqs_trigger`|  (Required) [SQS configuration](#sqs-lambda-event-sources) Set to `true` to enable an SQS queue to be an event source trigger for this lambda function. This will initiate the creation of an SQS queue and set up the proper connection for the lambda function to call this sqs queue to retrieve the data.| `false` | `bool` | Y        |
|  `sqs_trigger_alias`|  If `sqs_trigger` is `true` this value needs to be specified so that the SQS queue is properly connected to the alias you desire.| `LIGHT` | `string` | N        |
|  `sqs_redrive_queue_name`|  This indicates the sqs redrive (dead letter queue) that will be used for the sqs queue being configured here (see below for [Dead Letter Queue Configuration](#dead-letter-queue-configuration))| `default_sqs` | `string` | N        |
|  `sqs_<parameter>`|  There are a number of extra sqs parameters that can be configured when creating an sqs trigger for your lambda, see below for [SQS configuration](#sqs-lambda-event-sources).| `null` | `string` | N        |
| External/Existing SQS Triggers |
|  `ext_sqs_trigger`| Set to `true` to enable an External SQS queue to be an event source trigger for this lambda function. This will connect an already existent SQS queue to this lambda as a trigger. | `false` | `bool` | Y        |
|  `ext_sqs_trigger_name`|  If `ext_sqs_trigger` is Set to `true` then this must be specified. This is the general name of the SQS queue as seen in the aws console, it is not the full ARN. | `""` | `string` | Y        |
|  `ext_sqs_trigger_batch_size`| If `ext_sqs_trigger` is Set to `true` then this is used for the message batch size that will be used when the lambda function that this triggers pulls messages off the queue. | `10` | `int` | Y        |
|  `ext_sqs_trigger_max_batching_window_in_seconds`| If `ext_sqs_trigger` is Set to `true` then this is used for the message batch time that will be used when the lambda function that this triggers pulls messages off the queue. | `5` | `int` | Y        |
|  `ext_sqs_trigger_alias`| If `ext_sqs_trigger` is Set to `true` this can be used to select which alias of the lambda function will be invoked with this trigger. | `LIGHT` | `string` | Y        |
| SNS Triggers |
|  `sns_trigger`|  (Required) [SNS Configuration](#sns-lambda-triggers) Set to `true` to enable an SNS topic to be a trigger for calling this lambda function. This will initiate the creation of an SNS topic and set up the proper subscriptions for the SNS topic to lambda.| `false` | `bool` | Y        |
|  `sns_trigger_alias`|  If `sns_trigger` is `true` this value needs to be specified so that the SNS topic is properly connecting to the lambda alias for the topic subscription.| `LIGHT` | `string` | N        |
|  `sns_protocol` |  This setting allows you to create an SNS topic but have the subscription be sent to the configured `SQS` queue for the lambda in question so you end up with `SNS -> SQS -> Lambda`. In most cases this this will not be necessary but the capability is there if the need arises.| `lambda` | `string` | N        |
|  `sns_<parameter>`|  There are a number of SNS parameters that can be configured when creating an SNS trigger for your lambda. See below for [SNS Configuration](#sns-lambda-triggers).| `null` | `string` | N        |
| External/Existing SNS Triggers |
| `ext_sns_trigger` | Set to `true` to enable External SNS topic to be an event source trigger to this lambda function. This will connect an already existent SNS topic to this lambda as a trigger | `false` | `bool` |
| `ext_sns_trigger_name` | If `ext_sns_trigger` is `true` you MUST set this value to the common name of the SNS topic (NOT the ARN) | `null` | `string` |
| `ext_sns_trigger_alias` | If `ext_sns_trigger` is `true` this will be used to identify which alias the trigger will be attached. | `LIGHT` | `string` |
| Dynamo DB Triggers |
| `ddb_trigger` | Set to `true` to enable a dynamo db stream as a trigger for this lambda function. See below for [DynamoDB Streams Lambda Event Sources](#dynamodb-streams-lambda-event-sources)| `false` | `bool` |
|`ddb_trigger_table_name`| Required if `ddb_trigger` is set to `true`. The name of the dynamo table (Must be configured with a stream) which will be used as the stream source | `null` | `string` |
| `ddb_trigger_alias`| The alias which will be used as the trigger destination for the dynamo stream | `LIGHT` | `string` |
| `ddb_trigger_<parameter>` | There are a number of DDB parameters that can be configured when creating a DDB trigger for your lambda. [DynamoDB Streams Lambda Event Sources](#dynamodb-streams-lambda-event-sources) | `various` | `various` |
| S3 Triggers |
| `s3_trigger`|  (Required)  Set to `true` to enable an S3 Bucket Notification to be a trigger for calling this lambda function. Learn more [AWS Lambda with S3](https://docs.aws.amazon.com/lambda/latest/dg/with-s3.html) | `false` | `bool` | Y        |
| `s3_trigger_alias`|  If `s3_trigger` is `true` this value needs to be specified so that the S3 Bucket Notification is properly connecting to the lambda alias for the S3 Event.| `LIGHT` | `string` | N        |
| `s3_trigger_bucket`|  Required If `s3_trigger` is `true` this value needs to be specified. It defines the S3 bucket name that will be configured to send notification to this Lambda.| `null` | `string` | N        |
| `s3_trigger_event`|  If `s3_trigger` is `true`  It defines a comma separated list of event types for the configuration notification.  Learn more [Event Type](https://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html#notification-how-to-event-types-and-destinations)  | `s3:ObjectCreated:*` | `string` | N        |
| `s3_trigger_prefix`|  If `s3_trigger` is `true`  You can configure notifications to be filtered by the prefix of the key name of objects. i.e: images  | `null` | `string` | N        |
| `s3_trigger_suffix`|  If `s3_trigger` is `true`  You can configure notifications to be filtered by the suffix of the key name of objects. i.e: .jpg  | `null` | `string` | N        |

```yaml
##############################
# Lambda Function Definitions
##############################
lambda_map = {
  "hello-world" = {
    "name"                           = "hello-world"
    "function_handler"               = "com.wdpr.example.handler.HelloWorldRequestHandler"
    "lambda_runtime"                 = "java11"
    "lambda_memory_size"             = "1024"
    "lambda_timeout"                 = "30"
    "reserved_concurrent_executions" = -1
    "snow_description"               = "Hello World Example"
    "sqs_trigger"                    = true
    "s3_trigger"                     = true
    "s3_trigger_bucket"              = "ra-sandbox-lambda-deploy"
    "var_map"                        = "{}"
    "tag_map"                        = "{}"
  }
}
```

* Variable replacements available for the `var_map` are limited to the following

```yaml
vars = {
    "dev_prefix"       = local.dev_prefix
    "app_name"         = local.app_name
    "org"              = var.ownerorg
    "bag"              = var.bag
    "environment"      = var.environment
    "environment_code" = local.environment_code
    "region"           = var.region
    "short_region"     = local.short_region
    "base_name"        = local.base_name
    "version"          = local.derived_version
    "sid"              = var.sid
    "account_id"       = local.account_id
    "vault_addr"       = local.vault_addr
  }
```

### Alias Configuration

The alias configuration has been moved to be part of the Lambda list configuration. only two aliases are now supported, a `light` alias with a default value of `LIGHT` and a `dark` alias with a default value of `DARK`. No overrides are needed to accept these as the two alias values for each lambda function.

### Dead Letter Queue Configuration

A Dead Letter queue is a SQS queue that is utilized in case of an asynchronous lambda invocation that fails. The async invoke will retry a certain number of times (configurable) and if the lambda function still fails to process the message it is placed on a Dead Letter Queue if configured. By default a single dead letter queue for all the lambdas in your workspace is created. This can be overridden by specifying more queues inside the variable `dead_letter_queues`.

Below is the DLQ default configuration. You can see that the variable is a list of maps. Each map gets merged with the `dlq_defaults` map so any variable you define in an individual `dead_letter_queues` map will override the value found in `dlq_defaults`. If you choose to override the `dead_letter_queues` list of maps you must ensure that the `default_lambda` and the `default_sqs` are properly defined in your overridden code so that they are still available for use.

```yaml
variable "dead_letter_queues" {
  "type" = "list"
  default = [
    {
      "name" = "default_lambda"
    },
    {
      "name" = "default_sqs"
    }
  ]
}
variable "dlq_defaults" {
  type = "map"
  default = {
    "visibility_timeout_seconds"  = "30"
    "message_retention_seconds"   = "1209600"
    "max_message_size"            = "262144"
    "delay_seconds"               = "0"
    "receive_wait_time_seconds"   = "0"
    "policy"                      = ""
    "redrive_policy"              = ""
    "fifo_queue"                  = false
    "content_based_deduplication" = false
  }
}
```

Below is a simple example of how to override the DLQ configuration. As you can see, the `default_lambda` and the `default_sqs` queues are preserved and a new `example_queue` is added and overrides the `visibility_timeout_seconds` value from 30 seconds to 120 seconds.

```yaml
dead_letter_queues = [
    {
      "name" = "default_lambda"
    },
    {
      "name" = "default_sqs"
    },
    {
      "name" = "example_queue"
      "visibility_timeout_seconds" = "120"
    }
  ]
```

### SQS Lambda Event Sources

Lambda has the ability to be configured as a destination for different event sources. SQS is one of those sources. This section describes how to set up a lambda function to utilize an SQS queue as an event source.

As seen in the [Lambda Configuration](#lambda-configuration) section you add a few key configuration items to a lambda configuration to enable SQS as event sources. At a minimum you need to:

* set `sqs_trigger` to `true` instead of `false`
* set `sqs_trigger_alias` to the name of the alias you want to receive the queue.

The trigger in the console will be seen in the alias that has been configured (i.e., if you configured it with LIGHT, the trigger in the console will be seen on the LIGHT alias and not on the main lambda).

To configure a FIFO queue as trigger, you need to include the following variables:

```yaml
"sqs_trigger"                    = true
"sqs_fifo_queue"                 = true
"sqs_redrive_queue_name"         = "default_fifo_sqs"
"sqs_trigger_alias"              = "LIGHT"
```

There are other options that can be set and all of them are prefixed with `sqs_`. Below is a list of these options.

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `sqs_delay_seconds`| This sets up a delay from when a message arrives in the queue until a function can see it and process it.| `0` | `string` |
| `sqs_max_msg_size`| This sets the maximum size a message can be| None | `string` |
| `sqs_batch_size`| For an sqs triggering a lambda, this will indicate how many messages will be batched together (in coordination with sqs_max_batching_window_in_seconds) | `10` | `int` |
| `sqs_max_batching_window_in_seconds`| For an sqs triggering a lambda, this will indicate how many seconds the trigger will be delayed if `sqs_batch_size` has not been reached | `5`   | `int` |
| `sqs_msg_retention_seconds`| This sets how long a message can be in the queue before being deleted.| None | `string` |
| `sqs_receive_wait_time_seconds`| This indicates how long a call to `ReceiveMessage` on the queue will wait before returning if no message arrives.| `0` | `string` |
| `sqs_redrive_queue_name`| This sets the name of the SQS queue that is utilized as the Dead Letter Queue for this SQS. By default there is one called `default_sqs` but others can be created, see [Dead Letter Queue Configuration](#dead-letter-queue-configuration) for details.| None | `string` |
| `sqs_redrive_max_recv_count`| This indicates the number of times a message will be delivered from the source queue before being placed into the dead letter queue.| `3` | `int` |
| `sqs_fifo_queue` | Determines whether the queue will be a standard queue or a FIFO queue | `false` | `bool` |
| `sqs_content_based_deduplication` | If `sqs_fifo_queue` is set to `true` then this will determine if the queue will perform content-based deduplication [AWS Docs for SQS](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/FIFO-queues.html#FIFO-queues-exactly-once-processing) | `false` | `bool` |
| `sqs_managed_sse_enabled` | This enable server-side encryption (SSE) of message content with SQS-owned encryption keys by default | `true` | `bool` |


***Setting up a custom SNS Policy*** 

For use cases that requires a custom SNS Policy follow the steps: 

1) from your tfvars file set the variable `sns_custom_access_policy = true`
2) From same location of tfvars file, create the folder `custom`
3) Create a file `custom/sns_policy_{workspace_name}.json`
4) Copy the content of templates/sns_policy.json.tmpl into your new file
5) Modify the policy as needed. Make sure to let it be in compliance with recommendation of CAAS Team. 


***Setting up a custom SQS Policy*** 

For use cases that requires a custom SQS Policy follow the steps: 

1) from your tfvars file set the variable `custom_sqs_write_policy = true`
2) From same location of tfvars file, create the folder `custom`
3) Create a file `custom/sqs_write_policy_{workspace_name}.json`
4) Copy the content of templates/sqs_policy.json.tmpl into your new file
5) Modify the policy as needed. Make sure to let it be in compliance with recommendation of CAAS Team. 


***Setting up a SQS Filter Pattern *** 
 This allows Lambda functions to get events from SQS with a specified filter pattern: 

```
sqs_filtering_pattern = { 
  "<function_name>" = {
     json pattern  
  }
}
```

Example
```
sqs_filtering_pattern = { 
  "hello" = {
     body = {
            Temperature : [{ numeric : [">", 0, "<=", 100] }]
            Location : ["New York"]
      }
  }
}
```
Use `sqs_filtering_pattern` for sqs provisioned by this workspace and `ext_sqs_filtering_pattern` for external SQS 


### DynamoDB Streams Lambda Event Sources

Lambda has the ability to be configured as a destination for different event sources. DynamoDB Streams is one of those sources. This section describes how to set up a lambda function to utilize a DynamoDB Stream as an event source.

As seen in the [Lambda Configuration](#lambda-configuration) section you need to add a few key configuration items to a lambda configuration to enable DynamoDB event sources. At a minimum you need to set:

* `ddb_trigger` to `true` instead of `false`
* `ddb_trigger_table_name` to the name of the dynamo db table you want to attach a stream to.

Below is the full list of DynamoDB streams options that you can set and their defaults

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `ddb_trigger` | Determines if this lambda will have an event source created from a ddb stream | `false` | `bool` |
| `ddb_trigger_table_name` | The name of the DynamoDB Table that will be used as the source for the events | NA | `string` |
| `ddb_trigger_alias` | The alias that this trigger will be attached to | `LIGHT` | `string` |
| `ddb_trigger_start_pos` | The starting position where the lambda function will start receiving updates from the DynamoDB Stream ([GetShardIterator position types](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_GetShardIterator.html#API_GetShardIterator_RequestSyntax)) | `LATEST` | `string` |
| `ddb_trigger_batch_size` | The max number of records the lambda will retrieve during a single invocation | `100` | `integer` |
| `ddb_trigger_maximum_batching_window_in_seconds` | The max number of seconds the lambda will wait before being invokes | `5` | `integer`|
| `ddb_trigger_maximum_retry_attempts` | The max number of retries that will be attempted when the function returns an error | `10000` | `integer`|
| `ddb_trigger_maximum_record_age_in_seconds` | The max number of seconds a record will be before being automatically sent to the lambda function (Range: 0-604800) | `604800` | `integer`|
| `ddb_trigger_bisect_batch_on_function_error` |  If the function returns an error, split the batch in two and retry | `false` | `boolean` |

***Setting up a DynamoDB Stream Filter Pattern*** 

This allows Lambda functions to get events from DynamoDB with a specified filter pattern: 

```
ddb_filtering_pattern = { 
  "<function_name>" = {
     json pattern  
  }
}
```

Example:
```
ddb_filtering_pattern = { 
  "hello" = {
     body = {
            Temperature : [{ numeric : [">", 0, "<=", 100] }]
            Location : ["New York"]
      }
  }
}
```
### Kafka Lambda Triggers
Lambda has the capability to subscribe to a Kafka topic as a trigger, listening to each event sent to the Kafka topic, whether it is a managed SaaS offering by AWS or a self-hosted Kafka deployment provisioned and maintained in Kubernetes environments.

As seen in the [Lambda Configuration](#lambda-configuration) section you need to add a few key configuration items to a lambda configuration to enable Kafka as a trigger. At a minimum you need to:

* set `kafka_trigger` to `true` instead of `false`
* set `use_vpc` if your kafka was deployed as self managed mode.

If you have configured the VPC deployment, you must provide the necessary information for Lambda to discover the VPC and the subnets it will use for deployment.

This is a example:
```

vpc_info = {
  subnet_list = [
    "wdpr-ra-nb-usw2-sandbox-private-2",
    "wdpr-ra-nb-usw2-sandbox-private-0",
    "wdpr-ra-nb-usw2-sandbox-private-1"
  ]
  vpc_name = "wdpr-ra-nb-usw2-sandbox"
}

```

This would be the complete configuration to deploy a Kafka trigger and associate it with a Lambda function.

```
{
    "use_vpc"                        = true
    "kafka_trigger"                  = true
    "kafka_topics"                   = ["topic01"]
    "kafka_bootstrap_servers"        = "latest.dpe-kafka.wdprapps.disney.com:443"
    "kafka_source_access" = [
      {
        type = "SASL_SCRAM_512_AUTH"
        uri  = "arn:aws:secretsmanager:us-west-2:633112549318:secret:test/rojasc079/kafka-credentails-xs8UNq"
      },
      {
        type = "SERVER_ROOT_CA_CERTIFICATE"
        uri  = "arn:aws:secretsmanager:us-west-2:633112549318:secret:test/rojasc079/root-certifcate-uEaHRt"
      },
      {
        type = "VPC_SUBNET",
        uri  = "subnet-9d63f8c7"
      },
      {
        type = "VPC_SUBNET",
        uri  = "subnet-9360c6d8"
      },
      {
        type = "VPC_SUBNET",
        uri  = "subnet-2d75f154"
      },
      {
        type = "VPC_SECURITY_GROUP",
        uri  = "sg-0d3488f3857730993"
      } 
    ]
    "kafka_starting_position" = "TRIM_HORIZON"
}

```

Kafka trigger Options:

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `kafka_trigger`| bool to deploy and activate the kafka trigger| None | `bool` |
| `kafka_topics`| The required topics or the topics that the trigger will connect to or listen from in Kafka.| None | `array(string)` |
| `kafka_bootstrap_servers`| This input is a comma-separated string of each domain with the port of the Kafka cluster. | None | `string` |
| `kafka_source_access`| This configuration includes the authentication methods, encryption certificates, subnets, and security groups required to deploy the trigger. For authentication, it must be from a Secret Manager. The certificates must also be sourced from a Secret Manager. For subnets and security groups, resource IDs can be used. If you would like to see the types of authentication methods available and their usage, you can refer to this documentation. | None | `array(map)` |
| `kafka_starting_position`| Parameter determines where Lambda starts processing messages from a Kafka stream | None | `string` |


Also, this type of trigger needed a custom policy as this:
```json
{
    "Version":"2012-10-17",
    "Statement":[
        {
           "Effect":"Allow",
           "Action":[
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeVpcs",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "secretsmanager:GetSecretValue"
            ],
            "Resource":"*"
      }
  ]
}
```

Additionally, it is important to note that the `SASL_SCRAM_512_AUTH` must be a reference from Secret Manager, which must be deployed and available in the same region where the Lambda is being deployed. It must have the following configuration.

```json
{
  "username":"test",
  "password":"xxsxsxsxsxsxsxsxsx"
}
```

Additionally, the configuration for `SERVER_ROOT_CA_CERTIFICATE` must be added from a Secret Manager, which must be deployed and available in the same region where the Lambda is deployed. It must have the following structure.

```json
{
  "certificate":"-----BEGIN CERTIFICATE-----
MIIDfTCCAmWgAwIBAgIUGINLpm2+nPwiFc9QLcBJ6H8ZkVMwDQYJKoZIhvcNAQELBQAwHjEcMBoGA1UEAxMTd2
RwcmFwcHMuZGlzbmV5LmNvbTAeFw0xODA0MTAxODU5NTJaFw0yODA0MDcxOTAwMjJaMDUxMzAxBgNVp6x2pvTj
0GEAR84X17TUdreb1Vk3tdfnD1HVPhNj4LSOBZQjIs9K7p6oHOslmiYrDUnyejD3fypLdliBU0liQXsUUu1vL6
OZv5lwGrbEsOpzHmbDReSYgwb7eXCrOTpp3bUIKtvKjx7Wra/96PPxjlXRbgO6AEb0JAFs/uTro+n/YD6PQBupMkiLOrUCAwEAAaOBmzCBmDAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/
-----END CERTIFICATE-----"
}
```



### SNS Lambda Triggers

Lambda has the ability to be configured as a subscriber for a SNS Topic. This section describes how to set up a lambda function to utilize an SNS Topic as an trigger.

As seen in the [Lambda Configuration](#lambda-configuration) section you need to add a few key configuration items to a lambda configuration to enable SNS as a trigger. At a minimum you need to:

* set `sns_trigger` to `true` instead of `false`
* set `sns_trigger_alias` to the name of the alias you want to receive the queue.

There are other options that can be set and all of them are prefixed with `sns_`. Below is a list of these options

* `sns_protocol`: Determines which protocol the subscription for this topic is for. `lambda` and `sqs` are currently the only supported options.

Cloudwatch Logging Options:

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `sns_log_group_retention_in_days`| The number of days to keep log messages for this SNS topic.| None | `string` |
| `sns_lambda_success_sample_rate`| For Lambda subscriptions, what % sample rate (0-100) (of successful deliveries) should be logged to the cloudwatch log group for this SNS topic         | None | `string` |
| `sns_sqs_success_sample_rate`| For SQS subscriptions, what % sample rate (0-100) (of successful deliveries) should be logged to the cloudwatch log group for this SNS topic         | None | `string` |
| `sns_app_success_sample_rate`| For SNS Application subscriptions, what % sample rate (0-100) (of successful deliveries)  should be logged to the cloudwatch log group for this SNS topic| None | `string` |
| `sns_http_success_sample_rate`| For HTTP subscriptions, what % sample rate (0-100) (of successful deliveries)  should be logged to the cloudwatch log group for this SNS topic| None | `string` |

HTTP Delivery Policy Options:
These options are purely for HTTP based delivery mechanisms and would not specifically apply to SNS configured to go to Lambda or SQS but are described here for completeness:
Please see [SNS Delivery Policies](https://docs.aws.amazon.com/sns/latest/dg/DeliveryPolicies.html) for an explanation on these options.  

* `sns_delivery_min_delay_target`
* `sns_delivery_max_delay_target`
* `sns_delivery_num_no_delays_retry`
* `sns_delivery_num_min_delays_retry`
* `sns_delivery_num_max_delays_retry`
* `sns_delivery_num_retry`
* `sns_delivery_backoff_function`
* `sns_throttle_max_receives_per_second`
* `sns_disable_subscription_overrides`

### SNS Delivery Guarantees

Depending on the subscription type, AWS has a different delivery guarantee and behavior. Below is the current standard mechanism for guaranteeing delivery to Lambda functions and SQS queues

[Delivery Policies](https://aws.amazon.com/sns/faqs/) (Reliability section)

```yaml
* SQS: If a SQS queue is not available, SNS will retry 10 times immediately, then 100,000 times every 20 seconds for a total of 100,010 attempts over more than 23 days before the message is discarded from SNS.
* Lambda: If Lambda is not available, SNS will retry 2 times at 1 seconds apart, then 10 times exponentially backing off from 1 seconds to 20 minutes and finally 38 times every 20 minutes for a total 50 attempts over more than 13 hours before the message is discarded from SNS.
```

### S3 Lambda Triggers

Lambda has the ability to be configured as a destination for a S3 Bucket Notification. This section describes how to set up a lambda function to utilize an S3 Bucket as a trigger.

As seen in the [Lambda Configuration](#lambda-configuration) section you need to add a few key configuration items to a lambda configuration to enable S3 Bucket as a trigger. At a minimum you need to:

* set `s3_trigger` to `true` instead of `false`
* set `s3_trigger_bucket` to the name of the S3 Bucket you want to use to trigger the lambda.

There are other options that can be set and all of them are prefixed with `s3_`. Below is a list of these options

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
|  `s3_trigger`|  (Required)  Set to `true` to enable an S3 Bucket Notification to be a trigger for calling this lambda function. Learn more [AWS Lambda with S3](https://docs.aws.amazon.com/lambda/latest/dg/with-s3.html) | `false` | `bool` |
|  `s3_trigger_alias`|  If `s3_trigger` is `true` this value needs to be specified so that the S3 Bucket Notification is properly connecting to the lambda alias for the S3 Event.| `LIGHT` | `string` |
|  `s3_trigger_bucket`|  (Require) If `s3_trigger` is `true` this value needs to be specified. It defines the S3 bucket name that will be configured to send notification to this Lambda.| None | `string` |
|  `s3_trigger_event`|  If `s3_trigger` is `true`  It defines a comma separated list of event types for the configuration notification.  Learn more [Event Type](https://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html#notification-how-to-event-types-and-destinations)  | `s3:ObjectCreated:*` | `string` |
|  `s3_trigger_prefix`|  If `s3_trigger` is `true`  You can configure notifications to be filtered by the prefix of the key name of objects. i.e: images  | None | `string` |
|  `s3_trigger_suffix`|  If `s3_trigger` is `true`  You can configure notifications to be filtered by the suffix of the key name of objects. i.e: .jpg  | None | `string` |

### Cloudwatch Lambda Triggers

Lambda can be configured so that a cloudwatch event is the trigger for the lambda invocation. This has several purposes that will not be covered here. To set up a configuration there is a `scheduled_lambda_triggers` variable that is utilized to accomplish the creation and configuration of the Cloudwatch Trigger. Below is an example configuration. As you can see this variable is a list of maps where each map in the list is a single Cloudwatch trigger configuration

```yaml
scheduled_lambda_triggers = {
  "hello-world" = {
    "lambda_function_base_name" = "hello-world"
    "name" = "1-minute-trigger"
    "sched_type" = "rate"
    "sched_expression" = "1 minute"
    "enabled" = true
    "input" = <<DOC
{
  "name": "cloudwatch trigger"
}
DOC
  }
}
```

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `lambda_function_base_name`| this references the Lambda function name as defined by the `name` attribute in the lambda list. This ties the trigger to a specific lambda function.| None | `string` |
| `name`| A hyphen-separated name for the trigger. This should be short and descriptive (ie. `1min`)| None | `string` |
| `sched_type`| The type of schedule for this event, either `rate` or `cron`| None | `string` |
| `sched_expression`| Either the rate expression (ie. `1-minute`) or the cron expression for this schedule| None | `string` |
| `enabled`| Whether to enable this trigger or not.| None | `string` |
| `input`| This is the input format for your trigger (ie. what it will send to your lambda function) This needs to be well formed JSON in HereDoc format.| None | `string` |

### Event Bridge Triggers

Lambda can be configured so that it is a target for a Event Bridge rule. To set up a configuration utilize the `event_lambda_triggers` map of maps to configure the event bridge rules and targets.

```yaml
event_lambda_triggers = {
  "hello-world" = {
    "lambda_function_base_name" = "hello-world"
    "description" = "Capture each AWS Console Sign In"
    "name" = "eb-trig"
    "enabled" = true
    "event_pattern" = <<DOC
{
  "detail-type": [
    "AWS Console Sign In via CloudTrail"
  ]
}
DOC
  }
}
```
### CloudWatch Metric Filters

[optional] Lambda functions can be configured to alarm for detecting specific log patterns in CloudWatch log outputs. An empty SNS topic will be created to deliver matching alarms.
Keys: 
* `function_name` - name of lambda function from previous steps. 
* `metric_name` - desired AWS CloudWatch Metric name. 
* `metric_pattern` - parsing string. 
* `alarm_period` - threshold period, seconds. 

```yaml
lambda_alarms_custom_filter_metrics = [
  {
    "function_name"  = "hello-world"
    "metric_name"    = "metric-timeout"
    "metric_pattern" = "timed out"
    "alarm_period"   = 300
  },
  {
    "function_name"  = "another-function-name"
    "metric_name"    = "metric-error"
    "metric_pattern" = "\"[ERROR]\""
    "alarm_period"   = 600
  }
]
```

### Lambda Function URLs
A function URL is a dedicated HTTP(S) endpoint for your Lambda function. After you configure a function URL for your function, you can invoke your function through its HTTP(S) endpoint via a web browser, curl, Postman, or any HTTP client.

> **Note**
> You can access your function URL through the public Internet only.

Lambda function URLs use resource-based policies for security and access control. Function URLs also support cross-origin resource sharing (CORS) configuration options to define how different origins can access your function URL. It is recommended to configure CORS if you intend to call your function URL from a different domain. 

For more documentation refer to [Lambda Function URLs](https://confluence.disney.com/display/DPEPRA/Lambda+Function+URLs).

Parameters within `function_url`:
| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `use_function_url`| Whether or not to create a Function URL| `false` | `bool` |
| `enable_cors`| Whether or not to enable CORS settings for the function URL. Documented in the variables below. | `false` | `bool` |
| `allow_credentials`| Whether to allow cookies or other credentials in requests to the function URL. | `false` | `bool` |
| `allow_origins`| The origins that can access the function URL. Must be provided when CORS is enabled. You can list any number of specific origins (or the wildcard character (`["*"]`)), separated by a comma. For example: `["https://www.example.com", "http://localhost:60905"]`. | None | `list(string)` |
| `allow_methods`| The HTTP methods that are allowed when calling the function URL. For example: `["GET", "POST", "DELETE"]`, or the wildcard character (`["*"]`). | None | `list(string)` |
| `allow_headers`| The HTTP headers that origins can include in requests to the function URL. For example: `["date", "keep-alive", "x-custom-header"]` | None | `list(string)` |
| `expose_headers`| The HTTP headers in your function response that you want to expose to origins that call the function URL. For example: `["date", "keep-alive", "x-custom-header"]`. | None | `list(string)` |
| `max_age`| The maximum amount of time, in seconds, that web browsers can cache results of a preflight request. By default, this is set to 0, which means that the browser doesn't cache results. The maximum value is 86400. | `0` | `int` |

Example without CORS enabled:
```
function_url = {
    "use_function_url"  = true
    "enable_cors"       = false
  }
```

Examples with CORS enabled:
```
function_url = {
    "use_function_url"  = true
    "enable_cors"       = true
    "allow_credentials" = false
    "allow_origins"     = ["https://www.example.com", "http://localhost:60905"] # required when CORS is enabled
    "allow_methods"     = ["GET", "POST"]
    "allow_headers"     = ["date", "keep-alive"]
    "expose_headers"    = ["keep-alive", "date"]
    "max_age"           = 86400
  }
```

```
function_url = {
    "use_function_url"  = true
    "enable_cors"       = true
    "allow_origins"     = ["https://www.example2.com"] # required when CORS is enabled
  }
```

## Sandbox Development

Due to the nature of lambda functions and the inability to fully test them outside of the AWS environment, this workspace has been designed with developers in mind. The intention is that developers will be able to run the necessary updates in order to provision new lambda functions, update existing ones and any other non-restricted (such as iam roles) components that go along with those.

### Sandbox Provisioning

Certain components, such as IAM roles and policies are not permitted to be controlled by those with developer roles. Because of this limitation, each workspace must be run once by someone with appropriate permissions prior to enabling developers to make updates. This should be a one-time run, except if new permissions need to be added to the lambdas to allow proper operation.

## Developer Workflow

### Requirements

* [AWS Saml Auth Utility](https://github.disney.com/WDPR-RA/aws-saml-auth): This utility must be installed prior to being able to communicate appropriately to AWS via the CLI. Please follow the instructions within the repository to install the utility properly.
* [Terraform Package Manager](https://github.disney.com/WDPR-RA/terraform-package-manager): This utility is used to wrap many of the base terraform commands in a simple helper application so that much of the tasks that should be run prior to executing terraform are properly initialized. Follow the instructions in the repository for installation.
* You should have already provisioned a certificate for the domain name you are using

### Instructions

Developers should utilize the `tfdev.sh` script for interactions. This script has a simple command line that is used to ensure that developers do not clash when deploying Api Gateway from the same repository. In order for multiple developers to work simultaneously in the same environment on the various Gateway Integration etc, care must be taken to create `namespaced` gateway and other non-shared pieces of the infrastructure. To that end, the `tfdev.sh` script enforces this by extracting a developer ID from the `aws-saml-auth.json` configuration file.

* AWS Saml Auth Config file:
  * In your local home directory create a file at the following location `~/.config/configstore/aws-saml-auth.json`
  * The file should look like the following

  ```json
  {
   "profile": "default",
   "user": "<your hub ID>",
   "pass": null,
   "account": null,
   "role": "arn:aws:iam::876496569223:role/WDPRPCM-DEVELOPER",
   "idpurl": "https://efs.disney.com:9031/idp/startSSO.ping?PartnerSpId=urn:amazon:webservices",
   "sandbox_account": "<name of the sandbox account. ie. wdpr-sandbox>"
  }
  ```

  * This file will be utilized by the development script in order to extract values.

### tfdev.sh execution options

##### -w <workspace> (Required)

The workspace defines a unique set of state and configurations that allow terraform to work in isolated buckets of work. This allows this type of repository to exist where many projects live alongside each other to use the same basic infrastructure layout yet with different configurations on top of that. The workspace should be named according to the following pattern.

* Convention: <ownerorg>-<bag>-<application_name>-<region(short)>-<environment>
* Examples: wdpr-parkops-opc-facilities-use1-latest | wdpr-cast-estp-use1-latest
This will map directly to the `tfvars` in the env directory. This workspace file will be copied to a unique workspace file with your `developer id` (user from aws-saml-auth.json file) as part of the file name. This new file will be used to override specific values that will force terraform to deploy into the `sandbox_account` that you have configured in your `aws-saml-auth.json`

##### -c <terraform command> (Required)

This is fairly straightforward and should be the terraform command that you wish to run. The standard sequence is as follows

* Init: Run init only when starting with a workspace for the first time.
* Plan: run plan first to identify any changes and create an update plan for review
* Apply: run apply after only reviewing the steps that terraform plan has shown it would take
* Destroy: Only run destroy when you are sure you want to remove all the components in the infrastructure. This will not happen often if ever.
* Clean: not a terraform command, but utilized to clean up the files that `tfdev.sh` creates as part of its execution./

### Workflow Execution

The following basic steps should be utilized to execute the terraform code into a sandbox environment

1. Follow the Requirements section
2. Log into aws with `aws-saml-auth`
3. Initialize the workspace (first time only)
    1. `./tfdev.sh -w <workspace_name> -c init`
4. Plan the workspace
    1. `./tfdev.sh -w <workspace_name> -c plan`
5. Review the plan, ensuring that you can identify your developer id (hub id) as part of the lambda function names and other components.
6. Ensure that your plan is targeted at the proper workspace and not at some other workspace
7. Ensure that your plan only modifies/updates resources that belong to your lambda functions
8. Apply the plan to the workspace
    1. `./tfdev.sh -w <workspace_name> -c apply`
    2. Review the execution of the plan and identify any errors and determine how to fix
    3. if necessary start again at step 4 (plan)
9. Continue running step 4 and above until the apply successfully executes

* Destroy: Only run destroy when you are sure you want to remove all the components in the infrastructure. This will not happen often if ever.

---
