###########################################
# RETRIEVE GLOBALS
###########################################
module "global-config" {
  source = "git::ssh://git@github.disney.com/dpep-terraform-modules/global-config.git?ref=v4.x"

  org         = var.ownerorg
  bag         = var.bag
  environment = var.environment
  region      = var.region

  bapp_id          = var.bapp_id
  name_node_id     = var.name_node_id
  se_contact       = var.se_contact
  bid              = var.bid
  application_name = var.application_name

  git_config_org  = var.git_config_org
  git_config_repo = var.git_config_repo
  git_config_dir  = var.git_config_dir

  terraform                = var.terraform
  terraform_workspace_type = var.terraform_workspace_type

  global_general_request_map = local.global_general_request_map
}

#################################################
# DATA SOURCES
#################################################
data "aws_sns_topic" "alarm_topic_p2" {
  name = local.pri2_sns_name
}

data "aws_sns_topic" "alarm_topic_p3" {
  name = local.pri3_sns_name
}

data "aws_sns_topic" "alarm_topic_p4" {
  name = local.pri4_sns_name
}

data "aws_vpc" "vpc" {
  for_each = local.vpc_name_configured ? { (var.vpc_info["vpc_name"]) = true } : {}
  filter {
    name   = "tag:Name"
    values = [var.vpc_info["vpc_name"]]
  }
  provider = aws
}

data "aws_subnet" "subnets" {
  for_each = local.vpc_name_configured ? toset(var.vpc_info["subnet_list"]) : toset([])
  filter {
    name   = "tag:Name"
    values = [each.key]
  }
}

data "aws_caller_identity" "current" {}

# Create one template for each lambda function to output the name value
data "template_file" "lambda_function_short_name" {
  for_each = var.lambda_map
  template = var.lambda_map[each.key]["name"]
}

data "external" "lambda_workspace_defaults" {
  program = [
    "python3",
    "${path.module}/scripts/pullNonSecretsFromVault.py",
    var.consul_defaults_path,
    var.non_secret_vault_url
  ]
}

data "external" "lambda_workspace_config" {
  program = [
    "python3",
    "${path.module}/scripts/pullNonSecretsFromVault.py",
    format("%s/%s/nimbus/", var.consul_nimbus_base, local.base_name),
    var.non_secret_vault_url
  ]
}