# Change Log 

## [v5.1.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v5.1.2) (2025-11-25)
- Update INSTRUCTIONS file in the "Upgrading to v5.0.0" section.

## [v5.1.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v5.1.0) (2025-11-19)
- Fix issue with the variable type defined in lambda_definition_defaults and lambda_alarms_default_map variables.

## [v5.1.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v5.1.0) (2025-11-12)
- Fix issue with Terraform coercing a cast operation from bool to string values.

## [v5.0.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v5.0.0) (2025-08-08)
- Update terraform from v1.5 to 1.13.0
- Update AWS provider from v5.34.0 to 6.10.0
- Update Hashicorp Vault from 4.0.0 to 5.2.1
- Update Hashicorp Consul from 2.10 to 2.22.0
- Update Hashicorp External from 2.3.3 to 2.3.5
- Terraform workspace files restructure
- Tfvars refactor

## [v4.6.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.6.0) (2025-08-08)
- Add the option to enable/disable Report Batch Item Failures feature for SQS triggers.

## [v4.5.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.5.0) (2025-06-09)
- Update INSTRUCTIONS.md file to make a reference to the corresponding Lambda v2 to v3 Migration confluence documentation

## [v4.4.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.4.1) (2025-03-17)
- Add missing defaults for kafka trigger configuration.

## [v4.4.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.4.0) (2025-03-10)
- A new feature has been added to create Kafka triggers for specific topics and clusters, associated with a Lambda, including all necessary configurations.

## [v4.3.5](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.3.5) (2024-12-17)
- Add support for configuring maximum age records and retry attempts for an existing Kinesis Stream trigger

## [v4.3.4](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.3.4) (2024-12-10)
- Add support for using an existing Kinesis Stream as trigger

## [v4.3.3](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.3.3) (2024-12-09)
- Fix issue with batching window conditional for FIFO type queues

## [v4.3.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.3.2) (2024-12-05)
- Fix issue with batching window that is not supported for FIFO type queues

## [v4.3.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.3.1) (2024-11-14)
- Add support for configuring Batch Window for sqs in the "aws_lambda_event_source_mapping" resource

## [v4.3.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.3.0) (2024-07-25)
- Update code to use the new global-config module version. This will fix the issue with the global-config module that has overpopulated the state files with unused data

## [v4.2.4](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.2.4) (2024-05-07)
- Update default Nodejs version from nodejs16.x to nodejs20.x

## [v4.2.3](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.2.3) (2024-04-23)
- Fixed the bug with an empty-derived version

## [v4.2.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.2.2) (2024-04-19)
- Fixed the performance issues coming from the non-secret data sources.
- Fixed the issue with the vault throwing the access denied response (code 403)

## [v4.2.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.2.1) (2024-04-17)
- Fix script issue when latest version of vault key is deleted/destroyed

## [v4.2.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.2.0) (2024-03-26)
- Consul write -> Vault write

## [v4.1.3](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.1.3) (2024-03-25)
- Fix issue with non-strings in non_secret mount

## [v4.1.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.1.2) (2024-03-19)
- Fix issue with regions outside of vault's regions

## [v4.1.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.1.1) (2024-03-15)
- Fix issue with pulling from wrong consul

## [v4.1.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.1.0) (2024-02-23)
- Consul Read -> Vault Read

## [v4.0.4](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.0.4) (2024-01-30)
- Update AWS Provider 5.34.0 to support Node.js 20

## [v4.0.3](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.0.3) (2023-12-06)
- Hotfix with conditions related to the type of package when this is an image

## [v4.0.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.0.2) (2023-11-13)
- Update terraform version and AWS provider to 5.25.0 to support Python 3.11

## [v4.0.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.0.1) (2023-10-18)
- Update terraform version and AWS provider
## [v4.0.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v4.0.0) (2023-10-02)
- Set to false use_kinesis_stream to prevent kinesis stream resource creation as default 

## [v3.13.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.13.0) (2023-09-30)
- Added support for Custom Egress Rules

## [v3.12.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.12.1) (2023-09-28)
- Fixed consul logic for sandbox environment, use globals instead of internal environment map

## [v3.12.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.12.0) (2023-08-10)
- Added support for filter criteria for DynamoDB trigger

## [v3.11.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.11.1) (2023-08-02)
- Updated upgrade script to latest version to address an error when upgrading from `v2.x` to `v3.x` using ddb trigger.
- Added ddb resources to `upgrade.json`.

## [v3.11.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.11.0) (2023-07-12)
- Add code signing configuration 

## [v3.10.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.10.0) (2023-07-10)
- SnapStart feature to reduce Java cold starts on AWS Lambda functions

## [v3.9.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.9.0) (2023-06-28)
- Add kinesis stream resource block to provision within lambda workspace

## [v3.8.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.8.1) (2023-06-16)
- Fix the issue with Alarms when reserved concurrency at -1, adding validation for when concurrency is less than 0

## [v3.8.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.8.0) (2023-06-12)
- Bumping terraform provider version to `4.67.0` to support `java17` runtime.

## [v3.7.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.7.0) (2023-05-24)
- Added provisioned concurrency feature.
- Changed `function_name` and `function_version` for alias resource in case we expect to have provisioned concurrency by alias in the future.

## [v3.6.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.6.0) (2023-05-17)
- Fixed bug reported when the SNS topic Permission issue if the region is different 

## [v3.5.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.5.1) (2023-05-04)
- Updated upgrade script to address external sqs data resource renaming when upgrading from 2.x

## [v3.5.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.5.0) (2023-02-03)
- Add feature for Lambda function urls, dedicated HTTPS endpoint
- Update ReadMe to follow template format

## [v3.4.7](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.4.7) (2023-01-26)
- Add check for boolean value for use_vpc

## [v3.4.6](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.4.6) (2022-12-29)
- Update documentation to use terraform docs
- Added description and type to variables
- Terraform fmt execution

## [v3.4.5](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.4.5) (2022-12-12)
- Add trouble shooting guide links.

## [v3.4.4](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.4.4) (2022-12-07)
- Fix for `sns_permissions.sh` script.

## [v3.4.3](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.4.3) (2022-11-17)
- Clean up old template files
- Update IoT resource to use IoT variables instead of app_policy

## [v3.4.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.4.2) (2022-11-04)
- Add SQS Encryption by Default

## [v3.4.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.4.1) (2022-10-28)
- Add feature to set a custom SNS policy

## [v3.4.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.4.0) (2022-10-26)
- Add ephemeral storage argument support 

## [v3.3.7](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.3.6) (2022-10-21)
- Updated upgrade script to avoid recreation of some of the resources coming from `v2.x`.
- Updated `INSTRUCTIONS.md`.

## [v3.3.6](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.3.6) (2022-10-14)
- Update default Nodejs version from nodejs14.x to nodejs16.x

## [v3.3.5](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.3.4) (2022-09-21)
- Added `INSTRUCTIONS.md` with upgrade instructions.
- Updated example tfvars.
- Updated `vpc_config` to enable VPC settings only for functions that have the flag enabled.
- Added `code_version` variable.
- Updated README.
- Updated upgrade script with custom function and updated `upgrade.json` to validate deprecated variables.

## [v3.3.4](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.3.4) (2022-08-25)
- Updated ```upgrade.json``` to prevent any upgrade from v2.x (which uses tf 0.11)

## [v3.3.3](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.3.3) (2022-07-21)
- Update Nodejs version In Readme2.md
- Fix Invalid Function Argument

## [v3.3.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.3.2) (2022-07-06)
- Documentation update to CHANGELOG

## [v3.3.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.3.1) (2022-07-05)
- Remove deprecated resource in lambda workspace

## [v3.3.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.3.0) (2022-06-08)
- Added CloudWatch Metric filters with related Alarms and SNS topics
 
## [v3.2.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.2.0) (2022-06-03)
- Added SQS Event Filter Pattern for SQS
- Uplifted the AWS provider version to 4.17.0 
- Fixed the issue with 2m timeouts from SQS and the latest provider 

## [v3.1.8](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.1.8) (2022-05-19)
- Fixed hardcoded name on the AWS IAM policy created for external sqs  
- Added configuration for setting custom policies for SQS
- Reverted aws provider back to version = "~> 3.44.0" fix issues timeout with SQS

## [v3.1.7](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.1.7) (2022-05-18)
- Added a tfvars file template 

## [v3.1.6](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.1.6) (2022-05-10)
- Upgrade aws provider version to support runtime `dotnet6` 

## [v3.1.5](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.1.5) (2022-04-25)
- Add upgrade script to help with consul token issue

## [v3.1.4](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.1.4) (2022-04-19)
- Remove use of var.consul_token and use local.consul_token instead

## [v3.1.3](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.1.3) (2022-04-07)
- Consul resource fix to remove token (should only be on provider)

## [v3.1.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.1.2) (2022-03-22)
- RAA-2482 Updated Version details in atlantis.yaml, update changelog, update backend tfstate setup.

## [v3.1.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.1.1) (2022-02-16)
- RITM5421406 Add customized role policy 

## [v3.1.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.1.0) (2021-01-11)
- RAA-1493 Upgrade Terraform Version to v1.0.11
- RAA-2001 Add Set common tags 

## [v3.0.12](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.0.12) (2022-01-13)
- Revert aws provider to a lower version v3.44.0 to resolve sqs redrive policy error

## [v3.0.11](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.0.11) (2022-01-13)
- Revert aws provider to a lower version v3.68.0 to resolve sqs state lookup issue

## [v3.0.10](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.0.10) (2022-01-11)
- Update aws provider to latest version 3.71.0 as per aws guideline to handle ResourceConflictException

## [v3.0.9](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.0.9) (2021-11-16)
- Fix a few minor bugs related to utilizing Docker-based lambdas.

## [v3.0.8](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.0.8) (2021-11-12)
- Move all terraform blocks to terraform.tf


## [v3.0.7](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.0.7) (2021-10-04)
- Add `Name` tag to lambda security group set same as `name`

## [v3.0.6](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.0.6) (2021-06-07)
- Upgrade default node.js runtime version to v14

## [v3.0.5](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.0.5) (2021-05-11)
 - Bugfix: Fix default value for global_tags_map to be valid json
 
## [v3.0.4](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.0.4) (2021-05-17)
 - Add security group update to support access SES from lambda functions


## [v3.0.3](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.0.3) (2021-04-30)

- Update Terraform version per Hashicorp recommendation [HCSEC-2021-12]

## [v3.0.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.0.2) (2021-04-20)

- Bugfix: Trailing slashes on some of the consul path values were causing issues
- Bugfix: snow_id from global-configs module was not properly being used.

## [v3.0.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.0.1) (2021-04-19)

- Bugfix: Syntactical error with kinesis check causing failure.

## [v3.0.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v3.0.0) (2021-02-12)

- Feature: Upgrade Terraform version from 0.11.14 -> 0.14.5
  - Breaking Change: State file is not compatible between v3.x and v2.x
  - Many updates aimed at better maintenance of the code base
  - Switch from list-based variables to mostly map-based variables
- Feature: Add External SNS trigger capability
- Feature: Add Docker image support for Lambda provisioning
- Feature: Add local file system support for lambda provisioning
- Feature: Add support for EFS shared file system for lambdas
- Feature: Usage of global-config module
- Feature: Cloudwatch alarms can now be disabled by the level (critical/high/warn) in addition to environment
- Enhancement: Remove dependency of external state files by instead using data ssource lookups (vpc, sns topics ,etc)

## [v2.6.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.6.0) (2021-3-2)

- Feature: Allow consul path to be variablized

## [v2.5.5](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.5.5) (2020-12-1)

- Feature: Add support for FIFO Queues as lambda triggers.

## [v2.5.4](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.5.4) (2020-11-30)

- BugFix: Fix IAM code to function properly when iot_policy is set to true.

## [v2.5.3](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.5.3) (2020-11-11)

- BugFix: Update the atlantis.yaml file format

## [v2.5.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.5.2) (2020-10-02)

- BugFix: Fixed a bug on action defined for invoke permission

## [v2.5.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.5.1) (2020-10-01)

- BugFix: Fixed a bug that was introduced that broke the VPC state file lookup.

## [v2.5.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.5.0) (2020-10-01)

- Add feature that allows to granularly grant invoke access to a given list of AWS principals.

## [v2.4.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.4.0) (2020-09-23)

- Fixed production naming of kinesis streams to not have `-qa` on them. This bug was introduced~ ~2.3.4 -> 2.3.5

## [v2.3.6](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.3.6) (2020-08-10)

- Add iot_policy variable to support iot.amazonaws.com trust policy

## [v2.3.5](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.3.5) (2020-07-24)

- Add `consul_datacenter_override` variable to support new `consul-dlp-<env>` naming convention after euw1 rebuild

## [v2.3.4](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.3.4) (2020-06-10)

- Support usage of dev1 and dev2

## [v2.3.3](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.3.3) (2020-05-13)

- Fix permissions to support for s3 trigger

## [v2.3.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.3.2) (2020-05-06)

- Support load-dr and prod-dr environments

## [v2.3.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.3.1) (2020-04-14)

- Update ddb trigger to properly support `maximum_batching_window_in_seconds`

## [v2.3.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.3.0) (2020-04-09)

- Support triggers from External SQS queues not created via this workspace

## [v2.2.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.2.0) (2020-03-12)

- Add support for training and shadow environments

## [v2.1.5](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.1.5) (2020-03-10)

- Support custom folder for app policy file.

## [v2.1.4](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.1.4) (2020-02-04)

- Add support for explicitly disabling upload of consul data (for other non-nimbus deployments)

## [v2.1.3](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.1.3) (2020-02-04)

- Add support for vault URL as a local that can be utilized in variables definitions.

## [v2.1.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.1.2) (2019-12-16)

- Adding S3 trigger support
- Adding Tracing Config Option for X-Ray tracing configuration

## [v2.1.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.1.1) (2019-11-18)

- Fix DDB policy creation when no tables are being used.

## [v2.1.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.1.0) (2019-11-05)

- Adding Dynamo DB trigger support

## [v2.0.4](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.0.4) (2019-10-29)

- Updated example `tfdev.sh` script to properly support Terraform Workspace Segementation (Gen4)

## [v2.0.3](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.0.3) (2019-10-10)

- Added support for defaulting values for SNS topics. This prevents the blocking of using accounts which don't have SNS topics yet.

## [v2.0.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.0.2) (2019-10-03)

- Add support for specifying which account the initial artifact version is uploaded through.

## [v2.0.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.0.1) (2019-09-19)

- Update the default egress configuration to allow more targeted outbound.

## [v2.0.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v2.0.0) (2019-08-21)

- Update the code to create a security group for lambdas in a VPC
- This is a breaking change for those using VPC already as the definition for vpc configuration is different.

## [v1.1.4](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v1.1.4) (2019-08-21)

**Merged pull requests:**

## [v1.1.3](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v1.1.3) (2019-08-20)

**Merged pull requests:**

- correct syntax errors. [\#245](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/pull/245) ([MATTD043](https://github.disney.com/MATTD043)
- correct syntax errors. [\#244](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/pull/244) ([MATTD043](https://github.disney.com/MATTD043)

## [v1.1.2](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v1.1.2) (2019-08-16)

**Merged pull requests:**

- Update of change log and version number. [\#237](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/pull/237) ([MATTD043](https://github.disney.com/MATTD043)
- Update of code_path tag to remove special characters. [\#236](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/pull/236) ([MATTD043](https://github.disney.com/MATTD043)

## [v1.1.1](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v1.1.1) (2019-08-15)

**Merged pull requests:**

- Testing automated version tagging. [\#228](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/pull/228) ([MATTD043](https://github.disney.com/MATTD043)

## [v1.1.0](https://github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/tree/v1.1.0) (2019-08-14)

**Initial Release**
