#################################################
# PROVIDERS
#################################################
provider "aws" {
  region = var.region
  assume_role {
    role_arn     = format("arn:aws:iam::%s:role/%s", local.provider_account_id, var.provider_assumed_role)
    session_name = var.se_contact
  }
  default_tags {
    tags = merge(
      tomap({ "code_version" = var.code_version }),
      module.global-config.common_tags,
    var.user_tags)
  }
}

provider "aws" {
  region = var.dr_region == "" ? var.region : var.dr_region
  assume_role {
    role_arn     = format("arn:aws:iam::%s:role/%s", local.provider_dr_account_id, var.provider_assumed_role)
    session_name = var.se_contact
  }
  default_tags {
    tags = merge(
      tomap({ "code_version" = var.code_version }),
      module.global-config.common_tags,
    var.user_tags)
  }
  alias = "dr"
}

provider "aws" {
  region = var.secrets_region == "" ? var.region : var.secrets_region
  assume_role {
    role_arn     = format("arn:aws:iam::%s:role/%s", local.provider_secrets_account_id, var.provider_assumed_role)
    session_name = var.se_contact
  }
  default_tags {
    tags = merge(
      tomap({ "code_version" = var.code_version }),
      module.global-config.common_tags,
    var.user_tags)
  }
  alias = "secrets"
}

provider "aws" {
  region = var.initial_artifact_region == "" ? var.region : var.initial_artifact_region
  assume_role {
    role_arn     = format("arn:aws:iam::%s:role/%s", local.provider_initial_artifact_account_id, var.provider_assumed_role)
    session_name = var.se_contact
  }
  default_tags {
    tags = merge(
      tomap({ "code_version" = var.code_version }),
      module.global-config.common_tags,
    var.user_tags)
  }
  alias = "init_artifact"
}

provider "aws" {
  region = var.external_trigger_region == "" ? var.region : var.external_trigger_region
  assume_role {
    role_arn     = format("arn:aws:iam::%s:role/%s", local.external_trigger_account_id, var.provider_assumed_role)
    session_name = var.se_contact
  }
  default_tags {
    tags = merge(
      tomap({ "code_version" = var.code_version }),
      module.global-config.common_tags,
    var.user_tags)
  }
  alias = "external_trigger"
}

provider "aws" {
  region = var.external_trigger_region != var.region ? var.external_trigger_region : var.region
  assume_role {
    role_arn     = format("arn:aws:iam::%s:role/%s", local.provider_account_id, var.provider_assumed_role)
    session_name = var.se_contact
  }
  default_tags {
    tags = merge(
      tomap({ "code_version" = var.code_version }),
      module.global-config.common_tags,
    var.user_tags)
  }
  alias = "external_sns_trigger"
}

provider "vault" {
  address = local.vault_url
  alias   = "non_secret"
  auth_login {
    path   = "auth/aws/login"
    method = "aws"
    parameters = {
      sts_region = "us-east-1"
      role       = var.non_secret_vault_role
    }
  }
}