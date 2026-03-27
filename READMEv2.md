# WDPR Lambda Workspaces
Infrastructure as a code (IaC) is a prerequisite for our common DevOps practices to deliver stable environments rapidly, reliably and at scale, avoiding manual configuration of multi-environments and enforcing consistency. This repository provisions Lambda functions.

## Table of Contents

   1. [SMEs for this workspace](#1-smes-for-this-workspace)
   2. [Usage](#2-usage)
   3. [Variables](#3-variables)
   4. [Lambda Usage Details](#4-lambda-usage-details)
   5. [Misc Tools](#5-misc-tools-optional)
   6. [Applying partial changes thru terraform](#6-applying-partial-changes-thru-terraform)
   7. [WARNINGS](#7-warnings)

## 1. SMEs for this workspace

The [SME's listed here](https://confluence.disney.com/display/wdprcloud/GEN3+and+GEN4+Terraform+Workspace+Details) must be reviewers for all code and/or documentation changes.   They should also be contacted with any questions or concerns with using this workspace.

Updates to TFVAR/Workspace files can be reviewed and approved by any other SE

---

## 2. Usage
1. Create a new branch, based on the workspace name, with the changes required
2. Open a PR to run Atlantis
3. Comment on the PR to have Atlantis run the Terraform Plan
4. Review the results of the Plan in the PR comments
5. If the plan was successful, get the PR approved
6. Comment on the PR to have Atlantis run the Terraform Apply
7. If the apply was successful, merge the PR and delete the branch

---

## 3. Variables

This workspace requires certain variables to be filled out in order for it to function. Any variables that do not have a default value must be set in order for Atlantis/Terraform to run properly. These variables should be placed in the `env` directory, named using the following naming convention: `org-bag-snowid-reg-env-app.tfvars`

### One-Time Initial Configuration
This workspace has a special set of resources that allow the first time terraform run to properly succeed without any prior external interactions in regards to the zip/jar file for lambdas to be created. The below is all that needs to be set up.

* Initial Version: `artifact_version = 0.0.0`
* Initial Version only gets run on `latest` environment.
* That's it. 
* The version `0.0.0` will automatically be created and uploaded to the proper S3 bucket as if CICD had deployed it

### Common Variables

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `account` | The AWS account name where the lambdas will be provisioned. | None | `string` |
| `ownerorg` | The org the VPC belongs to. Ex - `wdpr` | None | `string` |
| `bag` | The business affinity group associated with the application. | None | `string` |
| `application_name` | The application name associated with this Lambda functions. This is part of the name that will be included in all lambda functions defined here. | None | `string` |
| `region` | The region the Lambda functions will be provisioned in. | None | `string` |
| `environment` | The environment the Lambda functions are getting provisioned to. | None | `string` |
| `bapp_id` | The Bapp ID assigned in Service Now for the application. | None | `string` |
| `bid` | Service Now BID identifier ex. S0001326 | None | `string` |
| `node_name_id` | Taxonomy code used for billing (4 digit number). Found in service now. | None | `string` |
| `change_request_number` | The SNOW Change Number relating to this update. | None/Optional | `string` |
| `change_request_date` | The date/time the Change is being done on. | None/Optional | `string` |
| `auto_id` | The unique Automation ID, if done though automation. | None/Optional | `string` |


### Lambda Specific Variables

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `git_org` | Git org where lambda code is located | None | `string` |
| `git_repo` | Git repo where lambda code is located | None | `string` |
| `artifact_version` | CICD generated artifact version (ex. 1.2.3-4.0.0.0 )| None | `string` |
| `artifact_base_name` | CICD generated artifact's base file name. (usually the same as git_repo)  | None | `string` |
| `s3_lambda_artifact_bucket` | S3 root folder where CICD artifact lives (Only necessary for `sandbox` environment. Other environments the value is calculated.)  | `wdpr-lambda-deploy` | `string` |
| `app_policy`| This indicates that your lambdas utilize a secondary IAM policy defined in the `templates` folder named `$app_policy.json.tmpl`. Extra permissions, beyond those that are defined in the `lambda_policy.json.tmpl` need to be added here. For example, if your lambda function needs access to an S3 bucket outside of the default then it should be added here. Note that certain permissions for lambdas are added where there is a specific integration.| None | `string` |
| `vpc_subnet_ids` | AWS VPC Subnet IDs where lambdas will be placed if configured. | `"[]"` | `list` |
| `vpc_security_group_ids` | AWS VPC Security group IDs that lambdas will be allowed to use if configured. | `"[]"` | `list` |
| `lambda_iam_role_override` | If this is set than terraform wont create IAM role for lambda and use this role instead, (Primarily for sandbox)  | `""` | `string` |
| `lambda_global_vars_map` | Global variable map, will be applied to all lambdas (environment, region, etc)  | None | `map` |
| `lambda_global_tags_map` | Map of global tags that will be applied to all lambdas. | None | `map` |
| `lambda_list` | Array/list of lambda functions and associated variables  | None | `list` |
| `alias_maps` | An array of maps having the lambda aliases for dark, light, canary   | None | `list` |
| `scheduled_lambda_triggers` | If lambdas are called by scheduled triggers provide a list  | `"[]"` | `list` |
|`invoke_permission_principal_list`| Allows to granularly grant invoke access to a given list of AWS principals. | `"[]"` | `list` |


### invoke_permission_principal_list variables
The invoke_permission_principal_list variable define a list of principals that should be defined as shown:  

```hcl
  invoke_permission_principal_list = [
      {
        type = "role" 
        account = "wdpr-ee-dev"
        value = "WDPR-DEVELOPER"
      }
  ]
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

## 4. Lambda Usage Details

### Warnings
In the tfvars file, there are several list-based configurations for things such as `Lambda Functions` and `Aliases`. Because of the way that terraform will treat this, if the list itself is changed such that an item at one index is moved to another index, this will cause those affected list items to be destroyed and recreated. This should not present a big issue but in the case some components such as `Lambda Functions` this could cause an unintended service interruption.

To guard against this, the lists should only be additive unless it is absolutely necessary to remove an item from the list. The items should not be reshuffled except in the case of a removal.

### Configuration Format
In order to properly utilize this workspace you must understand the configuration structure, the variable definitions and their capabilities and limitations. The overall tvars file structure will broken down below.

### Basic Configuration Variables
These values should be standard and self explanatory. Be aware of their importance though as they drive the naming convention of the infrastructure components.
```
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
These variables define the location of where the lambda artifact will be sourced from. THe git repository and the artifact base name will most always match, but there may be exceptions. The bucket name will alays be a base value of `wdpr-lambda-deploy` and going forward will be suffixed with the region in short form: ie. `use1` for a bucket value of `wdpr-lambda-deploy-use1`

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `git_org` | The name of the git org where the code resides. | None | `string` |
| `git_repo` | The name of the git repo where the code resides. | None | `string` |
| `artifact_version` | The version of the artifact including build number to be deployed. This may be overridden by values in Consul driven by the Nimbus runs. Value would be found at `/terraform/wdpr-lambda-workspaces/<workspace_name>/config/version` | None | `string` |
| `artifact_base_name` | The base name of the artifact without the extension. Typically the name of the git repo. | None | `string` |
| `artifact_file_type` | The file type of the artifact. | `zip` | `string` |
```
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
| `tf_wdpr_aws_workspaces_account_name`| This identifies account name where the lambdas should be deployed. Defaults to the `account` name. This is used for pulling in values that are built out at the account level.| `$account | `string` |
| `snow_assignment_group`| This is the name of the assignment group in service now where incidents should be assigned.| None | `string` |
| `snow_configuration_item`| This is the name of the configuration item which your workspace is a part of.| None | `string` |
| `snow_tier` | This is the Service Now Application tier designation. | `3` | `number` |
| `tf_wdpr_vpc_workspaces_vpc_name`| Name of the VPC workspace (use TF workspace name for VPC) where the lambdas will be placed if `use_vpc` is set in the lambda configuration | None | `string` |
| `vpc_security_group_ids`| This is a list of security groups you want to allow your lambda function access to.| None | `string` |
| `lambda_global_vars_map`| Utilize this variable to define global environment variables that each lambda defined in your workspace will have access to. No need to repeat the variable for each function. These can be overriden at the lambda level.| None | `string` (encoded json via [HEREDOC](https://en.wikipedia.org/wiki/Here_document) format) |
| `lambda_global_tags_map` | Utilize this variable to define global tags that each lambda defined in your workspace will be tagged with. These can be overridden at the lambda level | None | `string` (encoded json via [HEREDOC](https://en.wikipedia.org/wiki/Here_document) format) |
| `allow_cross_account_access_from` | A list of account names which are then granted rights to invoke the lambda functions defined in this workspace. | None| `string` |
| `lambda_alarms_default_map` | A map of alarm thresholds, that is applied to each lambda to trigger warning/high/critical alarms that create Incidents in Service Now | See the variables.tf | `map` |
| `enable_write_values_consul` | Flag that will disable the upload of keys into consul for the metadata around the functions | `true` | `string` (boolean value) |
| `override_consul_artifact_version` | Flag that will force the `artifact_version` variable to be used instead of one pulled from consul (as set by the Nimbus deployment) | `false` | `string` (boolean value) |
| `lambda_alarms_actions_enabled` | Map to enable or disable the alarm creation for a specific environment. This should only be used in accounts where the SNS Topics for Incident Management have not been rolled out | enabled for all but sandbox | `map` example: `{ "environment" = 0 }` |
```
app_policy                     = "gwauth"

tf_wdpr_aws_workspaces_account_name = "wdpr-apps"

snow_assignment_group   = "ops-global-wdpr-ra"
snow_configuration_item = "WDPRT AWS Gateway Authorizer"

lambda_global_vars_map = {
  "test" = "global"
}
```

### Lambda Configuration
The `lambda_list` variable contains the definition of all of your lambda functions in a single workspace. This is an array of maps. Some of these are fairly self explanatory but they are all detailed here. Note that all but required values have a default value and therefore do not need to be defined in your tfvars file. The exception to that rule is `name`, `function_handler`, `snow_description`, `var_map` and `tag_map` (these last two can simply be `"{}"` empty maps).

| Variable | Description | Default | Type | Required |
|----------|-------------|-------- | ---- | -------- |
|  `name`| (Required) The base name of a lambda function. This is the reference name for the function and must be unique. The actual lambda function name will be constructed of several more variables that identify it more clearly.| None | `string` | Y |
|  `function_handler`|  (Required) this indicates where your function handler lives and the name of the handler. Typically this will be at the root of your zip file and also be named the same of your function. Recommendation is `handler` be the implementation method.| None | `string` | Y |
|  `lambda_runtime`|  (Required) The AWS lambda runtime for your function.| `nodejs20.x` | `string` | Y |
|  `lambda_memory_size`|  (Required) The size in MB of memory your lambda will be allocated| `128` | `string` | Y |
|  `lambda_timeout`|  (Required) The number of seconds that your lambda function may run, this is a hard stop limit.| `10` | `string` | Y |
|  `lambda_publish`|  (Required) Whether or not to actively publish this lambda function (most times it should be true)| `true` | `string` | Y |
|  `light_alias` | (Required) The name of the light alias. | `LIGHT` | `string` | Y |
|  `dark_alias` | (Required) The name of the dark alias. | `DARK` | `string` | Y |
|  `reserved_concurrent_executions`|  (Required) The number of concurrent executions of your function that are allowed, this is a required value.| `10` | `string` | Y |
|  `retention_in_days`|  (Required) The number of days the log group for this function will hold onto logs (90 is the standard value but lower can be set)| `90` | `string` | Y |
|  `use_vpc`|  (Required) Triggers whether this lambda function will be allowed access to the vpc parameters above.| `0` | `string` | Y |
|  `dlq_name`|  (Required) Sets up the connection of this lambda to a dead letter queue (see below for [Dead Letter Queue Configuration](#dead-letter-queue-configuration))| `default_lambda` | `string` | Y |
|  `tracing_config`|  (Required) Can be either PassThrough or Active.  If PassThrough, only trace the request from an upstream service if it contains a tracing header with "sampled=1" If Active, Lambda will respect any tracing header it receives from an upstream service. If no tracing header is received, Lambda will call X-Ray for a tracing decision. | `PassThrough` | `string` | Y |
|  `sqs_trigger`|  (Required) [SQS configuration](#sqs-lambda-event-sources) Set to `1` to enable an SQS queue to be an event source trigger for this lambda function. This will iniate the creation of an SQS queue and set up the proper connection for the lambda function to call this sqs queue to retrieve the data.| `0` | `string` | Y |
|  `sqs_trigger_alias`|  If `sqs_trigger` is `1` this value needs to be specified so that the SQS queue is properly connected to the alias you desire.| `LIGHT` | `string` | N |
|  `sqs_redrive_queue_name`|  This indicates the sqs redrive (dead letter queue) that will be used for the sqs queue being configured here (see below for [Dead Letter Queue Configuration](#dead-letter-queue-configuration))| `default_sqs` | `string` | N |
|  `sqs_<parameter>`|  There are a number of extra sqs parameters that can be configured when creating an sqs trigger for your lambda, see below for [SQS configuration](#sqs-lambda-event-sources).| None | `string` | N |
|  `ext_sqs_trigger`| Set to `1` to enable an External SQS queue to be an event source trigger for this lambda function. This will connect an already existent SQS queue to this lambda as a trigger. | `0` | `int` | Y |
|  `ext_sqs_trigger_name`|  If `ext_sqs_trigger` is set to `1` then this must be specified. This is the general name of the SQS queue as seen in the aws console, it is not the full ARN. | `""` | `string` | Y |
|  `ext_sqs_trigger_batch_size`| If `ext_sqs_trigger` is set to `1` then this is uesed for the message batch size that will be used when the lambda function that this triggers pulls messages off the queue. | `10` | `int` | Y |
|  `ext_sqs_trigger_max_batching_window_in_seconds`| If `ext_sqs_trigger` is set to `1` then this is uesed for the message batch time that will be used when the lambda function that this triggers pulls messages off the queue. | `5` | `int` | Y |
|  `ext_sqs_trigger_alias`| If `ext_sqs_trigger` is set to `1` this can be used to select which alias of the lambda fucntion will be invoked with this trigger. | `LIGHT` | `string` | Y |
|  `sns_trigger`|  (Required) [SNS Configuration](#sns-lambda-triggers) Set to `1` to enable an SNS topic to be a trigger for calling this lambda function. This will initiate the createion of an SNS topic and set up the proper subscriptions for the SNS topic to lambda.| `0` | `string` | Y |
|  `sns_trigger_alias`|  If `sns_trigger` is `1` this value neeeds to be specified so that the SNS topic is properly connecting to the lambda alias for the topic subscription.| `LIGHT` | `string` | N |
|  `s3_trigger`|  (Required)  Set to `1` to enable an S3 Bucket Notification to be a trigger for calling this lambda function. Learn more [AWS Lambda with S3](https://docs.aws.amazon.com/lambda/latest/dg/with-s3.html) | `0` | `string` | Y |
|  `s3_trigger_alias`|  If `s3_trigger` is `1` this value needs to be specified so that the S3 Bucket Notification is properly connecting to the lambda alias for the S3 Event.| `LIGHT` | `string` | N |
|  `s3_trigger_bucket`|  Required If `s3_trigger` is `1` this value needs to be specified. It defines the S3 bucket name that will be configured to send notification to this Lambda.| None | `string` | N |
|  `s3_trigger_event`|  If `s3_trigger` is `1`  It defines a comma separated list of event types for the configuration notification.  Learn more [Event Type](https://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html#notification-how-to-event-types-and-destinations)  | `s3:ObjectCreated:*` | `string` | N |
|  `s3_trigger_prefix`|  If `s3_trigger` is `1`  You can configure notifications to be filtered by the prefix of the key name of objects. i.e: images  | None | `string` | N |
|  `s3_trigger_suffix`|  If `s3_trigger` is `1`  You can configure notifications to be filtered by the suffix of the key name of objects. i.e: .jpg  | None | `string` | N |
|  `sns_protocol` |  This setting allows you to create an SNS topic but have the subscription be sent to the configured `SQS` queue for the lambda in question so you end up with `SNS -> SQS -> Lambda`. In most cases this this will not be necessary but the capability is there if the need arises.| `lambda` | `string` | N |
|  `sqs_<parameter>`|  There are a number of SNS parameters that can be configured when creating an SNS trigger for your lambda. See below for [SNS Configuration](#sns-lambda-triggers).| None | `string` | N |
|  `snow_description` | (Required) A textual description that will be used when service now alerts are created for this Lambda function. Ensure this is descriptive enough to be useful | None | `string` | Y |
|  `var_map`|  (Required) This is a map of environment variables that will be applied to your lambda function. You can utilize variable replacement via the notation `${}`. The variables that are allowed to be used as replacement are limited. See below for [SQS configuration](#sqs-lambda-event-sources).| None | `string` | Y |
|  `tag_map`|  (Required) This is a map of tags to apply to your function. There are default tags that will be added to each function automatically such as bapp_id. You can utilize the same variable replacement that the `var_map` uses.| None | `string` | Y |
|  `iot_policy`|  (Optional) Set to "true" if your lambda needs a trust relationship to iot.amazonaws.com. Any other values are ignored, as is the absence of the variable entirely. If the Lambda needs rights to anything iot:*, then this is likely needed. | None | `string` | N |
```
##############################
# Lambda Function Definitions
##############################
lambda_list = [
  {
    "name"                           = "snow"
    "function_handler"               = "entry/authHandler.authorizer"
    "lambda_memory_size"             = "256"
    "sqs_trigger"                    = 1
    "sqs_redrive_queue_name"         = "default_sqs"
    "sns_trigger"                    = 1
    "var_map"                        = <<DOC
  {
    "SNOW_BASE_URL": "https://wdprlatest.service-now.com",
    "SNOW_TOKEN_ENDPOINT": "/api/x_wdtpa_wdpr_share/v1/user/authz",
    "SNOW_AUTH_ENDPOINT": "/api/x_wdtpa_wdpr_estp/v1/sales_tool/cdn_auth",
    "MYID_USERINFO_URL": "https://efs.disney.com,9031/idp/userinfo.openid",
    "AUTHZ_VALIDATE_URL": "https://cloud.authorization.go.com/validate/",
    "SCOPES_BUCKET": "wdpr-auth-scopes-${environment}",
    "SECRET_NAME": "wdpr-ra/apigw-auth-lambda/${environment}",
    "REGION": "${region}",
    "test": "override"
  }
DOC
    "tag_map"                        = "{}"
  },
```

* Variable replacements available for the `var_map` are limited to the following
```
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
    "sid"              = local.snow_id
    "account_id"       = local.account_id
    "vault_addr"       = local.vault_addr
  }
```

### Alias Configuration
The alias configuration has been moved to be part of the Lambda list configuration. only two aliases are now supported, a `light` alias with a default value of `LIGHT` and a `dark` alias with a default value of `DARK`. No overrides are needed to accept these as the two alias values for each lambda function.

### Dead Letter Queue Configuration
A Dead Letter queue is a SQS queue that is utilized in case of an asynchronous lambda invocation that fails. The async invoke will retry a certain number of times (configurable) and if the lambda function still fails to process the message it is placed on a Dead Letter Queue if configured. By default a single dead letter queue for all the lambdas in your workspace is created. This can be overriden by specifying more queues inside the variable `dead_letter_queues`.

Below is the DLQ default configuration. You can see that the variable is a list of maps. Each map gets merged with the `dlq_defaults` map so any variable you define in an individual `dead_letter_queues` map will override the value found in `dlq_defaults`. If you choose to override the `dead_letter_queues` list of maps you must ensure that the `default_lambda` and the `default_sqs` are properly defined in your overridden code so that they are still available for use.

```
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
    "fifo_queue"                  = "false"
    "content_based_deduplication" = "false"
  }
}
```
Below is a simple example of how to override the DLQ configuration. As you can see, the `default_lambda` and the `default_sqs` queues are preserved and a new `example_queue` is added and overrides the `visibiltiy_timeout_seconds` value from 30 seconds to 120 seconds.
```
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
* set `sqs_trigger` to `1` instead of `0`
* set `sqs_trigger_alias` to the name of the alias you want to receive the queue.

There are other options that can be set and all of them are prefixed with `sqs_`. Below is a list of these options.

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `sqs_delay_seconds`| This sets up a delay from when a message arrives in the queue until a function can see it and process it.| None | `string` |
| `sqs_max_msg_size`| This sets the maxmimum size a message can be| None | `string` |
| `sqs_batch_size`| For an sqs triggering a lambda, this will indicate how many messages will be batched together (in coordination with sqs_max_batching_window_in_seconds) | 10 | `string` |
| `sqs_max_batching_window_in_seconds`| For an sqs triggering a lambda, this will indicate how many seconds the trigger will be delayed if `sqs_batch_size` has not been reached | 5   | `string` |
| `sqs_msg_retention_seconds`| This sets how long a message can be in the queue before being deleted.| None | `string` |
| `sqs_receive_wait_time_seconds`| This indicates how long a call to `ReceiveMessage` on the queue will wait before returning if no message arrives.| None | `string` |
| `sqs_redrive_queue_name`| This sets the name of the SQS queue that is utilized as the Dead Letter Queue for this SQS. By default there is one called `default_sqs` but others can be created, see [Dead Letter Queue Configuration](#dead-letter-queue-configuration) for details.| None | `string` |
| `sqs_redrive_max_recv_count`| This indicates the number of times a message will be delivered from the source queue before being placed into the dead letter queue.| None | `string` |
| `sqs_fifo_queue` | Determines whether the queue will be a standard queue or a FIFO queue | `false` | `string` |
| `sqs_content_based_deduplication` | If `sqs_fifo_queue` is set to `true` then this will determine if the queue will perform content-based deduplication [AWS Docs for SQS](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/FIFO-queues.html#FIFO-queues-exactly-once-processing) | `false` | `string` | 

### DynamoDB Streams Lambda Event Sources
Lambda has the ability to be configured as a destination for different event sources. DynamoDB Streams is one of those sources. This section describes how to set up a lambda function to utilize a DynamoDB Stream as an event source.

As seen in the [Lambda Configuration](#lambda-configuration) section you need to add a few key configuration items to a lambda configuration to enable DynamoDB event sources. At a minimum you need to set:
* `ddb_trigger` to `1` instead of `0`
* `ddb_trigger_table_name` to the name of the dynamo db table you want to attach a stream to.

Below is the full list of DynamoDB streams options that you can set and their defaults

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `ddb_trigger` | Determines if this lambda will have an event source created from a ddb stream | `0` | `integer` |
| `ddb_trigger_table_name` | The name of the DynamoDB Table that will be used as the source for the events | NA | `string` |
| `ddb_trigger_alias` | The alias that this trigger will be attached to | `LIGHT` | `string` |
| `ddb_trigger_start_pos` | The starting position where the lambda function will start receiving updates from the DynamoDB Stream ([GetShardIterator position types](https://docs.aws.amazon.com/kinesis/latest/APIReference/API_GetShardIterator.html#API_GetShardIterator_RequestSyntax)) | `LATEST` | `string` |
| `ddb_trigger_batch_size` | The max number of records the lambda will retrieve during a single invocation | `100` | `integer |
| `ddb_trigger_maximum_batching_window_in_seconds` | The max number of seconds the lambda will wait before being invokes | `5` | `integer` |
| `ddb_trigger_maximum_retry_attempts` | The max number of retries that will be attempted when the function returns an error | `10000` | `integer` |
| `ddb_trigger_maximum_record_age_in_seconds` | The max number of seconds a record will be before being automatically sent to the lambda function (Range: 0-604800) | `604800` | `integer` |
| `ddb_trigger_bisect_batch_on_function_error` |  If the function returns an error, split the batch in two and retry | `false` | `boolean` |

### SNS Lambda Triggers
Lambda has the ability to be configured as a subscriber for a SNS Topic. This section describes how to set up a lambda function to utilize an SNS Topic as an trigger.

As seen in the [Lambda Configuration](#lambda-configuration) section you need to add a few key configuration items to a lambda configuration to enable SNS as a trigger. At a minimum you need to:
* set `sns_trigger` to `1` instead of `0`
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
```
* SQS: If a SQS queue is not available, SNS will retry 10 times immediately, then 100,000 times every 20 seconds for a total of 100,010 attempts over more than 23 days before the message is discarded from SNS.
* Lambda: If Lambda is not available, SNS will retry 2 times at 1 seconds apart, then 10 times exponentially backing off from 1 seconds to 20 minutes and finally 38 times every 20 minutes for a total 50 attempts over more than 13 hours before the message is discarded from SNS.
```



### S3 Lambda Triggers
Lambda has the ability to be configured as a destination for a S3 Bucket Notification. This section describes how to set up a lambda function to utilize an S3 Bucket as a trigger.

As seen in the [Lambda Configuration](#lambda-configuration) section you need to add a few key configuration items to a lambda configuration to enable S3 Bucket as a trigger. At a minimum you need to:
* set `s3_trigger` to `1` instead of `0`
* set `s3_trigger_bucket` to the name of the S3 Bucket you want to use to trigger the lambda.

There are other options that can be set and all of them are prefixed with `s3_`. Below is a list of these options

| Variable | Description | Default | Type |
|----------|-------------|---------|------|
|  `s3_trigger`|  (Required)  Set to `1` to enable an S3 Bucket Notification to be a trigger for calling this lambda function. Learn more [AWS Lambda with S3](https://docs.aws.amazon.com/lambda/latest/dg/with-s3.html) | `0` | `string` |
|  `s3_trigger_alias`|  If `s3_trigger` is `1` this value needs to be specified so that the S3 Bucket Notification is properly connecting to the lambda alias for the S3 Event.| `LIGHT` | `string` |
|  `s3_trigger_bucket`|  (Require) If `s3_trigger` is `1` this value needs to be specified. It defines the S3 bucket name that will be configured to send notification to this Lambda.| None | `string` |
|  `s3_trigger_event`|  If `s3_trigger` is `1`  It defines a comma separated list of event types for the configuration notification.  Learn more [Event Type](https://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html#notification-how-to-event-types-and-destinations)  | `s3:ObjectCreated:*` | `string` |
|  `s3_trigger_prefix`|  If `s3_trigger` is `1`  You can configure notifications to be filtered by the prefix of the key name of objects. i.e: images  | None | `string` |
|  `s3_trigger_suffix`|  If `s3_trigger` is `1`  You can configure notifications to be filtered by the suffix of the key name of objects. i.e: .jpg  | None | `string` |


### Cloudwatch Lambda Triggers
Lambda can be configured so that a cloudwatch event is the trigger for the lambda invocation. This has several purposes that will not be covered here. To set up a configuration there is a `scheduled_lambda_triggers` variable that is utilized to accomplish the creation and configuration of the Cloudwatch Trigger. Below is an example configuration. As you can see this variable is a list of maps where each map in the list is a single Cloudwatch trigger configuration

```
scheduled_lambda_triggers = [
  {
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
]
```

| Variable | Description | Default | Type |
|----------|-------------|-------- | ---- |
| `lambda_function_base_name`| this references the Lambda function name as defined by the `name` attribute in the lambda list. This ties the trigger to a specific lambda function.| None | `string` |
| `name`| A hyphen-separated name for the trigger. This should be short and descriptive (ie. `1min`)| None | `string` |
| `sched_type`| The type of schedule for this event, either `rate` or `cron`| None | `string` |
| `sched_expression`| Either the rate expression (ie. `1-minute`) or the cron expression for this schedule| None | `string` |
| `enabled`| Whether to enable this trigger or not.| None | `string` |
| `input`| This is the input format for your trigger (ie. what it will send to your lambda function) This needs to be well formed JSON in HereDoc format.| None | `string` |


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
  ```
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
## 5. Misc Tools (optional)
---
### Atlantis
https://confluence.disney.com/display/wdprcloud/Atlantis+Terraform+Deployment

```bash
# From an open PR (type following command in the comment field)

# Create a Plan  
atlantis plan -w <workspace> -- -var phase="A-B"

# Apply the plan (PR Approval Required)
atlantis apply -w <workspace>
```

### TPM
https://github.disney.com/WDPR-RA/terraform-package-manager

```bash
# Authenticate with AWS https://github.disney.com/WDPR-RA/aws-saml-auth
$ aws-saml-auth  // Always wdpr-apps  

#Update your ~/.aws/credentials to contain all the roles
$ tpm account-update

#Check the ~/.aws/credentials - this needs to have wdpr-apps
$ cat ~/.aws/credentials
[default]
aws_access_key_id = XXXXX
aws_secret_access_key = XXX/XXX
aws_session_token = XXXXX

[wdpr-apps]
role_arn = arn:aws:iam::876496569223:role/WDPRPCM-DEVELOPER
source_profile = default
color = ed6f5b

#Run the below command again if you needed to run tpm account-update
$ aws-saml-auth  // Always wdpr-apps  

# List workspaces  
$ tpm init ?

# Initialize Project  
$ tpm init <workspace>

# Create a Plan
$ tpm plan <workspace> <workspace> -var phase="A-B"

# Apply a Plan  
$ tpm apply <workspace>

```

### Terraform
https://www.terraform.io/docs/index.html

```bash
# Authenticate with AWS https://github.disney.com/WDPR-RA/aws-saml-auth
$ aws-saml-auth

# Check Terraform Version for 0.11.7
$ terraform version  

# Initialize Backend Config and Download Modules and Providers
$ terraform init   

# Select Workspace:
$ terraform workspace select <workspace>

# Create a Plan  
$ terraform plan -var-file ./env/<workspace>.tfvars -o <workspace>.plan

# Apply a Plan  
$ terraform apply <workspace>.plan

```

## 6. Applying partial changes thru terraform

To apply an update targeting only specific resources and disregarding other changes then use the -target flag (-target=resource). The target flag can be used multiple times.

Example, to target AMI and user_data change for ASG only, target the module.ecs_cluster.module.asg.aws_launch_configuration.config which contains the AMI change and also the changed user_data:

```
## Thru Terraform
$ terraform plan -var-file env/<workspace>.tfvars -out <workspace>.plan
-target=module.ecs_cluster.module.asg.aws_launch_configuration.config -target=module.ecs_cluster.module.asg.aws_cloudformation_stack.ecs_asg

## Thru TPM
$ tpm plan workspace -target=module.ecs_cluster.module.asg.aws_launch_configuration.config -target=module.ecs_cluster.module.asg.aws_cloudformation_stack.ecs_asg

## Thru Atlantis
atlantis plan -w <workspace> --  
-target=module.ecs_cluster.module.asg.aws_launch_configuration.config -target=module.ecs_cluster.module.asg.aws_cloudformation_stack.ecs_asg

```
The parameter -target requires a resource id as an argument. To get a list of all resource id uses the command:  ``` terraform state list ``` .    

Also, then terraform apply after verifying the plan.

Note: Verify the main.tf or the terraform files that the ecs_cluster module is named the same as some TFs might have a different module name.


More info: (using the -target flag)[https://www.terraform.io/docs/commands/plan.html#target-resource]



## 7. WARNINGS

When working with multiple environments, extreme care needs to be taken for following human errors:

* Make sure the workspace, account, environment, and region is correctly set in all locations:

    * Double check each tfvars validating if the variables: environment, account and regions, tf_* are correctly configured.   
    * Make sure that the naming standard was implemented successfully especially for the backend section: workspace, region, workspace_prefix, and key.
    * Ensure to set the correct terraform version of Atlantis.yaml file before initializing.   

* Do not overwrite the state of one environment with other.

* When using the alb_dns variable, any existing deployed apps will cause a destructive change to them. Adding value to this variable will destroy existing lb and recreate a new one.

#### Locking State

The backend is now configured using a  state locking table to prevent concurrent modification. State locking happens automatically on all operations that could write state. You won't see any message that it is happening. If state locking fails, Terraform will not continue. You can disable state locking for most commands with the -lock flag, but not recommended.    


#### Shrinkwrap Modules  

During the infrastructure lifecycle the modules used to deploy infrastructure into a logical environment such as latest could get upgrades, and by the time the application is promoted these upgrades could unintentionally take place without proper validation.
To avoid inconsistencies between the logical environment is recommended shrinkwrap the modules before committing your changes.

    # After your plan looks good, Shrinkwrap the modules by typing:

    $ tpm shrinkwrap


#### Auto Tag Rollback strategies

Atlantis was designed to create a tag automatically using the workspace name  + timestamp for all applied plans.  So in case you need to check out the last code used to deploy infrastructure from a timeline perspective, you can do it using Git to check out release tag that contains the desired coding.

To get access open http://github.disney.com/<org>/<repository>/releases.

#### Variable File

While running terraform apply command, you have to ensure the variable file being passed corresponds to the intended environment; otherwise, unexpected things
can happen. E.g., You have prod and staging environments, and currently, your prod
state is active. Now if you run terraform apply and pass the variable file of
staging then it could result is some of the production resources being destroyed and recreated according to staging parameters. In the best case scenario of the resources are being used AWS may error out. The main precaution is to run terraform plan and keep a keen eye especially on the items being destroyed or changed.

#### State Overwriting

Even with remote state terraform keeps a local copy of state (.terraform/terraform.tfstate). When a remote config command is executed, and a local state file is present then terraform uploads the local file to remote storage and thus overwriting the current environments state to the state of environment you were switching to. So before switching from one environment to another, please make sure the local state file is deleted or copied to a different directory. The below commands might be a good idea. Especially if you are using terraform command instead of TPM.

```
    rm .terraform/terraform.tfstate
    terraform init -backend-config="bucket=<bucket name>" -backend-config="key=<key of state file>"

```

 In case the worst happens, and you have enabled versioning on the bucket, use the steps below to restore a previous version:

```
     # list all available versions of the object
     aws s3api list-object-versions --bucket <tfstate bucket> --key <key of the object which needs to be restored>
     # scan through the output and find a version ID that you think should have the correct state.
     aws s3api get-object --bucket <tfstate bucket> --key <key of the object which needs to be restored> --version-id <version id> .terraform/terraform.tfstate
     terraform show
     # Verify that state is looking good and then upload it back
     aws s3api put-object --bucket <tfstate bucket> --key <key of the object which needs to be restored> --body .terraform/terraform.tfstate
```
