#!/bin/bash

TF_WORKSPACE=""
ENVIRONMENT=""
DEVELOPER_ID=""
SANDBOX_ACCOUNT=""
TF_COMMAND=""
TF_WS_DIR=""
workspace_name=""
workspace_type=""
workspace_type_gateway="wdpr-api-gateway-workspaces"
workspace_type_lambda="wdpr-lambda-workspaces"
AWS_SAML_AUTH_CONF_LOC="/.config/configstore/aws-saml-auth.json"
#TARGET="-target=aws_lambda_function.default -target=aws_lambda_alias.aliases"

usage()
{
    echo "Execute terraform commands for development purposes into sandbox environment"
    echo ""
    echo "./tfdev.sh"
    echo "-h --help"
    echo "-w $TF_WORKSPACE"
    echo "-c $TF_COMMAND {plan|apply|destroy|clean|init}"
    echo ""
}

log_error_aws_saml_auth() 
{
  echo "Please set your \"$1\" in $2"
  echo "More documentation can be found: https://github.disney.com/WDPR-RA/aws-saml-auth/blob/develop/README.md#usage-without-prompts"
  exit 1
}

extract_value_from_saml_auth()
{
  json_file_loc=$HOME$AWS_SAML_AUTH_CONF_LOC
  local  __resultvar=$1
  field=$2
  local  myresult=""

  echo "Determining \"$field\" in $json_file_loc"
  
  if [ -e $json_file_loc ]; then
    myresult=$(cat $json_file_loc | jq -r ".$field")
    if [[ -z "$myresult" || "$myresult" == "null" ]]; then
      log_error_aws_saml_auth "$field" $json_file_loc  
    fi 
  else
    log_error_aws_saml_auth "$field" $json_file_loc
  fi
  if [[ "$__resultvar" ]]; then
      eval $__resultvar="'$myresult'"
  else
      echo "$myresult"
  fi
}

create-override-file() 
{
  workspace_name=$1
  workspace_dir=$2

  cat <<EOF > ${workspace_dir}/${workspace_name}.override
terraform {
  backend "s3" {
    bucket               = "${SANDBOX_ACCOUNT}-apps-tf"
    workspace_key_prefix = "${workspace_type}"
    region               = "us-east-1"
    key                  = "deployed.tfstate"
    profile              = "${SANDBOX_ACCOUNT}"
  }
}
EOF
  
}

append_to_workspace_file()
{
  echo $1 >> ./${TF_WS_DIR}/${workspace_name}.tfvars
}

rectify-workspace()
{
  sandbox_account_id=""
  if [[ $SANDBOX_ACCOUNT == "ra-sandbox" ]]; then
    sandbox_account_id="633112549318"
  elif [[ $SANDBOX_ACCOUNT == "wdpr-sandbox" ]]; then
    sandbox_account_id="141854384972"
  else
    echo "Invalid sandbox account"
    exit 1
  fi
  workspace_name=${DEVELOPER_ID}-${TF_WORKSPACE}

  echo "Creating developer workspace ${workspace_name}"

  cp ./${TF_WS_DIR}/${TF_WORKSPACE}.tfvars ./${TF_WS_DIR}/${workspace_name}.tfvars
  append_to_workspace_file ""
  append_to_workspace_file "developer_prefix=\"${DEVELOPER_ID}\""
  append_to_workspace_file "account=\"${SANDBOX_ACCOUNT}\""
  append_to_workspace_file "artifact_version=\"${DEVELOPER_ID}\""

  if [[ ${workspace_type} == ${workspace_type_lambda} ]]; then
    append_to_workspace_file "s3_lambda_artifact_bucket=\"${SANDBOX_ACCOUNT}-lambda-deploy\""
    append_to_workspace_file "lambda_iam_role_override=\"arn:aws:iam::${sandbox_account_id}:role/DevelopmentTrustRole\""
  elif [[ ${workspace_type} == ${workspace_type_gateway} ]]; then

    append_to_workspace_file "tf_lambda_func_state_bucket=\"${SANDBOX_ACCOUNT}-apps-tf\""
    append_to_workspace_file "tf_lambda_func_state_account=\"${SANDBOX_ACCOUNT}\""
    #append_to_workspace_file "tf_auth_lambda_func_state_bucket=\"${SANDBOX_ACCOUNT}-apps-tf\""
    append_to_workspace_file "tf_auth_lambda_func_state_account=\"${SANDBOX_ACCOUNT}\""
    append_to_workspace_file "lambda_deploy_bucket=\"${SANDBOX_ACCOUNT}-lambda-deploy\""
    append_to_workspace_file "create_regional_domain_name=\"0\""
    append_to_workspace_file "create_edge_domain_name=\"0\""
    append_to_workspace_file "iam_role_override=\"arn:aws:iam::${sandbox_account_id}:role/DevelopmentTrustRole\""
    append_to_workspace_file "swagger_source_bucket_account=\"${SANDBOX_ACCOUNT}\""
    append_to_workspace_file "authorizer_account=\"${SANDBOX_ACCOUNT}\""
    append_to_workspace_file "r53_account=\"${SANDBOX_ACCOUNT}\""
  fi

  create-override-file $workspace_name $TF_WS_DIR

  dev_ignore=$(grep ${DEVELOPER_ID} .gitignore)
  if [[ -z "${dev_ignore}" ]]; then
    echo "Adding ${DEVELOPER_ID} to gitignore"
    echo "**/${DEVELOPER_ID}*" >> .gitignore
  fi
  TF_WORKSPACE=${workspace_name}
  ENVIRONMENT="${TF_WORKSPACE}"
}

remove_file_if_exists() {
  file_name=$1

  if [ -e $file_name ]; then
    echo "Cleaning workspace file $file_name"
    rm $file_name
  fi
}

clean-workspace()
{
  echo "Cleaning workspace ${TF_WORKSPACE}"
  
  remove_file_if_exists "./${TF_WS_DIR}/${TF_WORKSPACE}.tfvars"
  remove_file_if_exists "./${TF_WORKSPACE}_override.tf"
  remove_file_if_exists "./${TF_WORKSPACE}.plan"
}

run-terraform()
{
  echo "******** Terraform Run Start ********"
  the_command=""
  if [[ "plan" == $TF_COMMAND ]]; then
    echo "TPM Plan selected"
    the_command="tpm plan -d ${TF_WS_DIR} -w ${ENVIRONMENT}"
  elif [[ "apply" == $TF_COMMAND ]]; then
    echo "TPM Apply selected"
    the_command="tpm apply -d ${TF_WS_DIR} -w ${ENVIRONMENT}"
  elif [[ "init" == "$TF_COMMAND" ]]; then
    echo "TPM Init selected"
    the_command="tpm init -d ${TF_WS_DIR} -w ${ENVIRONMENT}"
  elif [[ "destroy" == $TF_COMMAND ]]; then
    echo "TPM Destroy selected"
    the_command="tpm destroy -d ${TF_WS_DIR} -w ${ENVIRONMENT}"
  else
    echo "Command $TF_COMMAND not supported"
  fi

  echo "Running terraform command: ${the_command}"
  $the_command
  #echo $result
  echo "******** Terraform Run End ********"
}

check-workspace()
{
  workspace_command=""
  echo "******** Terraform Workspace Check ********"
  echo "Checking for terraform workspace '$TF_WORKSPACE'"
  workspace_command="tpm workspace ${TF_WORKSPACE}"
  $workspace_command
  echo "******** Terraform Workspace Check ********"
  echo ""
}

determine-workspace-type() {
  echo "******** Determining workspace type ********"
  if [[ ${TF_WS_DIR} == *"lambda"* ]]; then
    workspace_type=${workspace_type_lambda}
  elif [[ ${TF_WS_DIR} == *"api-gateway"* ]]; then
    workspace_type=${workspace_type_gateway}
  else
    echo "FATAL: COULD NOT DETERMINE WORKSPACE TYPE"
  fi
  echo "******** Workspace Type Identified: ${workspace_type} ********"
}

PARAMS=""

while (( "$#" )); do
  case "$1" in
    -c|--command)
      TF_COMMAND=$2
      shift 2
      ;;
    -w|--workspace)
      TF_WORKSPACE=$2
      shift 2
      ;;
    -d|--directory)
      TF_WS_DIR=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

extract_value_from_saml_auth DEVELOPER_ID "user"
echo $DEVELOPER_ID

extract_value_from_saml_auth SANDBOX_ACCOUNT "sandbox_account"
echo $SANDBOX_ACCOUNT

determine-workspace-type

rectify-workspace

if [[ $TF_COMMAND == "clean" ]]; then
  clean-workspace
else

  check-workspace
  run-terraform
fi
