###########################################
# STATE + Pinnings
###########################################
terraform {
  required_version = ">= 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.10.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.22.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.2.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }

  backend "s3" {
    bucket               = "wdpr-apps-terraform"
    workspace_key_prefix = "wdpr-lambda-workspaces"
    region               = "us-east-1"
    key                  = "deployed.tfstate"
    use_lockfile         = true
    acl                  = "bucket-owner-full-control"
    profile              = "wdpr-apps"
  }
}