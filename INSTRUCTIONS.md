### Upgrading from v2.x to v2.7.x
You can refer to the following [Lambda v2.x to v2.7.x Migration](https://confluence.disney.com/spaces/DPEPRA/pages/895847869/Lambda+v2.x+to+v2.7.x+Migration+NodeJs+Support+v14+v16) guide for more information.

## Upgrading from v2 to v3 of Lambda Workspace

You can refer to the following [Lambda v2 to v3 Migration](https://confluence.disney.com/spaces/DPEPRA/pages/880040631/Lambda+v2+to+v3+Migration) guide for more information.

## Upgrading from v3 to v4 of Lambda Workspace

For this release the default value for creating kinesis stream was changed to false to prevent the creation of unnecessary resources. If you use kinesis stream to maintain the previously created resource, make sure to add the variable "use_kinesis_stream" with value "true" in your tfvars and if you want to use an existing one, also add the variable "kinesis_stream_name"

# Upgrading to v5.0.0
Starting in **v5.0.0**, this workspace is running **Terraform version 1.13.0**, and we are switching the terrafom state locking mechanism from **DynamoDB-based locking** to **S3-managed lock file** to leverage new Terraform version capabilities. This change deprecates concurrency protection handled by DynamoDB `LockID` rows for the workspace.

If you performed a migration from older workspace versions to **v5.0.0** and you require to **roll back** to the previous version, you must run [Rundeck Job](https://rundeck.wdprapps.disney.com/project/atlantis_webhooks/job/show/0dc0c072-1b03-4667-a55f-835d06d0e6fc) to avoid digest/lock errors like ```Failed to load state: state data in S3 does not have the expected content.```

## Note:
When uplifting from **v4.x** to **v5.x**, probably it will be seen the following message when running the **atlantis plan** command:
```
Error: Backend initialization required: please run "terraform init"
 
Reason: Backend configuration block has changed
```
This is due to the changes introduced in **v5.0.0**, which include an update in the terraform and providers versions and in the terraform backend configuration.

This error message will not prevent from **atlantis plan** from finishing successfully. After the first **plan/apply**, it could be executed the plan/apply again and the error **will not show up anymore**.
