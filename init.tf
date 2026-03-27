##########################################################################################
# This file is to support the initial provisioning of a lambda function workspace
##########################################################################################

resource "aws_s3_object" "initial_artifact" {
  count  = var.initial_artifact_enable == "enable" ? (var.environment == "latest" ? 1 : 0) : 0
  bucket = local.lambda_deploy_bucket
  key    = format("%s/%s/0.0.0/%s.%s", var.git_org, var.git_repo, var.artifact_base_name, var.artifact_file_type)
  source = format("%s/files/default_lambda_artifact.zip", path.module)
  acl    = "bucket-owner-full-control"

  provider = aws.init_artifact
}
