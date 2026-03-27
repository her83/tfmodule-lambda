
terraform = {
  git_source = "git::ssh://git@github.disney.com/dpep-cloud-terraform/wdpr-lambda-workspaces/?ref=v4.x"
}

#############################################
# Standard variables
#############################################
account          = "" # Account Name Ref: https://confluence.disney.com/display/wdprcloud/Account+Information
region           = ""
environment      = ""
application_name = ""

#############################################
# Accounting
#############################################
bapp_id      = "" # Application BAPP ID
ownerorg     = ""
bag          = ""
name_node_id = "" # Ref: https://wdpr-se-cloud.pages.gitlab.disney.com/wiki/se/infrastructure/taxonomies.html
bid          = ""

#############################################
# Artifact Location
#############################################
git_org            = ""
git_repo           = ""
artifact_version   = ""
artifact_base_name = ""
s3_existing_package = {
  bucket     = ""
  key        = ""
  version_id = ""
}


#############################################
# Policy
#############################################
app_policy           = ""
app_policy_directory = "custom"
app_policy_extension = ".json.tmpl"


#############################################
# LOGGING && SPLUNK INTEGRATION
#############################################
use_kinesis_stream = false


#############################################
# SERVICE NOW INCIDENTS ON FAILURES
#############################################
snow_assignment_group   = ""
snow_configuration_item = ""
lambda_alarms_actions_enabled = {
  "latest" = {
    "warning"  = false
    "high"     = false
    "critical" = true
  }
}

#############################################
# VPC INFO (Required for use_vpc=1) 
#############################################
vpc_info = {
  vpc_name    = ""
  subnet_list = ["subnet_name1", "subnet_name2"]
}

#############################################
# GLOBAL ENVIRONMENT VARIABLES
#############################################
lambda_global_vars_map = <<DOC
{
  "environment": "$${environment}",
  "region": "$${region}"
}
DOC

#############################################
# GLOBAL TAGS
#############################################
lambda_global_tags_map = <<DOC
{
  "environment": "$${environment}",
  "region": "$${region}"
}
DOC

#############################################
# FUNCTION DEFINITIONS
#############################################
lambda_map = {
  "<function1>" = {
    "name"                           = "<function1>"
    "function_handler"               = ""
    "lambda_memory_size"             = ""
    "snow_description"               = ""
    "use_vpc"                        = true
    "lambda_timeout"                 = "30" ## in seconds, max 900s 
    "reserved_concurrent_executions" = -1
    "var_map"                        = <<DOC
      {
        "ENVIRONMENT_VAR1": "$${ENVIRONMENT_VAR1}",
        "ENVIRONMENT_VAR2": "$${ENVIRONMENT_VAR2}"
      }
      DOC
    "tag_map"                        = "{}"
  },
  "<function2>" = {
    "name"                           = "<function2>"
    "function_handler"               = ""
    "lambda_memory_size"             = ""
    "snow_description"               = ""
    "use_vpc"                        = false
    "lambda_timeout"                 = ""
    "reserved_concurrent_executions" = -1
    "var_map"                        = <<DOC
      {
        "ENVIRONMENT_VAR1": "$${ENVIRONMENT_VAR1}",
        "ENVIRONMENT_VAR2": "$${ENVIRONMENT_VAR2}"
      }
      DOC
    "tag_map"                        = "{}"
  }
}
