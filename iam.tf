data "template_file" "lambda_role_policy" {
  template = file(format("%s/templates/lambda_policy.json.tmpl", path.module))

  vars = {
    s3_lambda_artifact_bucket = local.lambda_deploy_bucket != null ? local.lambda_deploy_bucket : ""
    region                    = var.region
    account_id                = local.account_id
    ownerorg                  = var.ownerorg
    bag                       = var.bag
    application_name          = var.application_name
    short_region              = local.short_region
    environment               = var.environment
    sid                       = local.snow_id
    environment_code          = local.environment_code
    base_name                 = local.base_name
  }
}

# IAM role and policies
resource "aws_iam_role" "role" {
  count              = local.create_iam_role ? 1 : 0
  name               = format("%s-iam_role", local.base_name)
  assume_role_policy = var.custom_role_policy == true ? file(format("custom/%s%s", var.custom_role_file, var.custom_role_extension)) : file(format("%s/policies/lambda_role.json", path.module))
}

# service scheduler role
resource "aws_iam_role_policy" "role_policy" {
  count  = local.create_iam_role ? 1 : 0
  name   = format("%s-iam_role_policy", local.base_name)
  policy = data.template_file.lambda_role_policy.rendered
  role   = aws_iam_role.role[0].id
}

data "template_file" "app_policy_template" {
  count    = local.create_iam_role && var.app_policy != "" ? 1 : 0
  template = file(format("%s/%s%s", var.app_policy_directory, var.app_policy, var.app_policy_extension))

  vars = {
    region           = var.region
    account_id       = local.account_id
    ownerorg         = var.ownerorg
    bag              = var.bag
    application_name = var.application_name
    short_region     = local.short_region
    environment_code = local.environment_code
    environment      = var.environment
    sid              = local.snow_id
    base_name        = local.base_name
  }

}

resource "aws_iam_role_policy" "app_policy" {
  count  = local.create_iam_role && var.app_policy != "" ? 1 : 0
  name   = format("%s-app-iam_role_policy", local.base_name)
  policy = data.template_file.app_policy_template[0].rendered
  role   = aws_iam_role.role[0].id
}

##################################################################
# IAM Invocation Role
##################################################################

data "template_file" "invocation_lambda_role_policy" {
  template = file(format("%s/templates/invocation_lambda_policy.json.tmpl", path.module))

  vars = {
    s3_lambda_artifact_bucket = local.lambda_deploy_bucket
    region                    = var.region
    account_id                = local.account_id
    short_region              = local.short_region
    org                       = var.ownerorg
    bag                       = var.bag
    app                       = var.application_name
    env                       = local.environment_code
    sid                       = local.snow_id
    base_name                 = local.base_name
  }
}

# IAM role and policies
resource "aws_iam_role" "invocation_role" {
  count              = local.create_iam_role ? 1 : 0
  name               = format("%s-invoke_role", local.base_name)
  assume_role_policy = file(format("%s/policies/invocation_lambda_role.json", path.module))
}

# service scheduler role
resource "aws_iam_role_policy" "invocation_role_policy" {
  count  = local.create_iam_role ? 1 : 0
  name   = format("%s-invoke_role_policy", local.base_name)
  policy = data.template_file.invocation_lambda_role_policy.rendered
  role   = aws_iam_role.invocation_role[0].id
}

##################################################################
# IoT Invocation Role
##################################################################
data "template_file" "iot_lambda_role_policy" {
  count    = var.iot_policy != "" ? 1 : 0
  template = file(format("%s/%s%s", var.iot_policy_directory, var.iot_policy, var.iot_policy_extension))

  vars = {
    iot_policy   = var.iot_policy
    region       = var.region
    account_id   = local.account_id
    short_region = local.short_region
    org          = var.ownerorg
    bag          = var.bag
    app          = var.application_name
    env          = local.environment_code
    sid          = local.snow_id
    base_name    = local.base_name
  }
}

# IAM role and policies
resource "aws_iam_role" "lambda_iot_role" {
  count              = var.iot_policy == "true" ? 1 : 0
  name               = format("%s-lambda_iot_role", local.base_name)
  assume_role_policy = file(format("%s/policies/lambda_role_iot.json", path.module)) # <-this is the trust policy with Iot.amazonaws.com
}

# lambda iot role
resource "aws_iam_role_policy" "lambda_iot_role_policy" {
  count  = var.iot_policy == "true" ? 1 : 0
  name   = format("%s-lambda_iot_role_policy", local.base_name)
  policy = data.template_file.iot_lambda_role_policy[0].rendered
  role   = aws_iam_role.lambda_iot_role[0].id
}
