#!/bin/bash

VERSION=1.2.0

usage() {
    echo "Version: ${VERSION}"
    echo ""
    echo "Usage:"
    echo "\$1 [pre|post|validate]"
    echo "\$2 [init|plan|apply]"
    echo "\$3 (post)[success|failure] or (pre)terraform version from statefile ex: 0.11.15 OR unknown"
    echo "\$4 (pre)terraform version being run ex: 1.0.5"
    echo "\$5 (pre)workspace code version from statefile ex: 3.2.1 OR unknown"
    echo "\$6 (pre)workspace code version being run ex: 4.0.1"
    echo "\$7 (pre)path_to_workspace ex: /tmp/.tpm-cache/dpep-cloud-terraform/wdpr-ecs-workspaces/wdpr-ra-B0090314-use1-sbx-meyeb016-hackday"
    echo "\$8 (pre)workspace_name ex: wdpr-ra-B0090314-use1-sbx-meyerb016-hackday"
    echo ""
    echo "example: upgrade.sh pre init 0.11.15 1.0.5 3.2.1 4.0.1 /tmp/.tpm-cache/dpep-cloud-terraform/wdpr-ecs-workspaces/wdpr-ra-B0090314-use1-sbx-meyeb016-hackday"
    echo "example: upgrade.sh post init failure"
    exit 0
}

#
# Fix the TF version for older terraform command line calls
#
fixTFVersion() {
    local sf_tf_version=$1
    local code_tf_version=$2
    local tf_version=$1

    # shellcheck disable=SC2046
    if [ $(echo "${sf_tf_version}" | cut -c1-5) == "0.11." ] && [ $(echo "${code_tf_version}" | cut -c1-5) == "0.11." ]; then
        tf_version="0.11.15"
    fi
    # shellcheck disable=SC2046
    if [ $(echo "${sf_tf_version}" | cut -c1-5) == "0.11." ] && [ $(echo "${code_tf_version}" | cut -c1-5) == "0.12." ]; then
        tf_version="0.12.31"
    fi
    # shellcheck disable=SC2046
    if [ $(echo "${sf_tf_version}" | cut -c1-5) == "0.12." ] && [ $(echo "${code_tf_version}" | cut -c1-5) == "0.12." ]; then
        tf_version="0.12.31"
    fi

    echo "${tf_version}"
}

#
# Get the statefile version
#
getStatefileVersion() {
    local statefile=$1
    local tf_sf_version=0

    if [ -n "${statefile}" ]; then
        if [ -r "${statefile}" ]; then
            tf_sf_version=$(jq -r '.version // "0"' "${statefile}")
            # Handle special cases where only the latest version of the TF is the only one that works
            # shellcheck disable=SC2046
            if [ $(echo "${tf_sf_version}" | cut -c1-5) == "0.11." ]; then
                tf_sf_version="0.11.15"
            fi
            # shellcheck disable=SC2046
            if [ $(echo "${tf_sf_version}" | cut -c1-5) == "0.12." ]; then
                tf_sf_version="0.12.31"
            fi            
        fi
    fi

    echo "${tf_sf_version}"
}

#
# Get the statefile version
#
getStatefileResourceCount() {
    local statefile=$1
    local tf_sf_version=0
    local resources_count=""
    local rc=1

    tf_sf_version=$(getStatefileVersion "${statefile}")
    case ${tf_sf_version} in
        3)
            resources_count=$(jq '.modules[0].resources | length' "${statefile}")
            ;;
        4)
            resources_count=$(jq -r '.resources | length' "${statefile}")
            # There could be a list of managed resources, with nothing in the list of instances within each
            if [ "${resources_count}" != "0" ]; then
                resources_count=$(jq -r '[.resources[] | select(.mode=="managed") | .instances | length] | add' "${statefile}")
                if [ "${resources_count}" == "null" ]; then
                    resources_count=0
                fi
            fi
            ;;
        *)
            ;;
    esac

    if [ -n "${resources_count}" ]; then
        rc=0
    fi

    echo "${resources_count}"
    return ${rc}
}

#
# Parse a semvar version number and out the three numeric parts
# semvar_array=($(parse_semver "1.2.3"))
#
function parse_semver() {
    local semver="$1"
    local major=0
    local minor=0
    local patch=0

    if grep -E '^[0-9]+\.[0-9]+\.[0-9]+' <<<"${semver}" >/dev/null 2>&1 ; then
        # It has the correct syntax.
        local n="${semver//[!0-9]/ }"
        local a="(${n//\./ })"
        major=${a[0]}
        minor=${a[1]}
        patch=${a[2]}
    fi

    echo "${major} ${minor} ${patch}"
}

#
# Compare two semver versions, returning which is higher
#
function semver_compare() {
    local first_version=$1
    local second_version=$2
    local compare=""
    local ret_val=""

    # Return the lower of the two versions
    compare=$(echo -e "${first_version}\n${second_version}" | sort -V | head -n1)

    # If both versions are identical return same
    if [[ "${first_version}" == "${second_version}" ]]; then
         ret_val="same"
    # If second version is the lower version, return first
    elif [[ "${second_version}" == "${compare}" ]]; then
        ret_val="first"
    # Otherwise first version is lower version, return 1 for greater than
    else
        ret_val="second"
    fi
    echo "${ret_val}"
}

#
# If running code version (json.min_version) is equal to or greater than AND statefile tf version (json.tf_state_ver) is less than ERROR
#
function check_tf_ver() {
    local tf_statefile_ver=$1
    local code_workspace_ver=$2
    local upgrade_config_file=$3
    local tf_min_required=""
    local ret_val=""
    local msg=""
    local ret_semver=""
    local code_min_version=""
    local action=""
    local numVers=0
    local rc=0
    local v=0

    numVers=$(jq '.tf_versions | length' "${upgrade_config_file}")
    if [ -z "${numVers}" ]; then
        numVers=0
    fi
    # shellcheck disable=SC2004
    for (( v=0; v<$numVers; v++ ))
    do
        code_min_version=$(jq -r ".tf_versions[${v}].code_min_version // \"unknown\"" "${upgrade_config_file}")
        tf_min_required=$(jq -r ".tf_versions[${v}].tf_min_required // \"unknown\"" "${upgrade_config_file}")
        action=$(jq -r ".tf_versions[${v}].action // \"fail\"" "${upgrade_config_file}")
        msg=$(jq -r ".tf_versions[${v}].msg //\"missing\"" "${upgrade_config_file}")

        # If min_version or min_required is not set, skip this version entry from config file all together
        if [ "${code_min_version}" != "unknown" ] && [ "${tf_min_required}" != "unknown" ]; then
            # Check if the code verison is the SAME or HIGHER than the one from the config, if not SKIP
            ret_semver=$(semver_compare "${code_min_version}" "${code_workspace_ver}")
            if [ "${ret_semver}" == "same" ] || [ "${ret_semver}" == "second" ]; then
                # Check if the version from the statefile is unknown (this should never happen)
                if [ "${tf_statefile_ver}" != "unknown" ]; then
                    # Check if the required version is the SAME or HIGHER that the one from the statefile
                    ret_semver=$(semver_compare "${tf_min_required}" "${tf_statefile_ver}")
                    if [ "${ret_semver}" == "first" ]; then
                        ret_val=${msg}
                        # If the action is to fail, no need to check others
                        if [ "${action}" == "fail" ]; then
                            rc=1
                            break
                        fi
                    fi
                else
                    ret_val="ERROR: Unable to determine the current workspace terraform version from the statefile.  If you are changing releases, try going back to the latest version of the previous release and doing a plan again."
                    rc=1
                    break
                fi
            fi
        fi
    done
    echo "${ret_val}"
    return ${rc}
}

#
# Check if a workspace is being upgraded and meets a minimum version prior to doing the upgrade
#
function check_code_ver() {
    local code_statefile_ver=$1
    local code_workspace_ver=$2
    local upgrade_config_file=$3
    local min_required=""
    local ret_val=""
    local msg=""
    local ret_semver=""
    local min_version=""
    local action=""
    local numVers=0
    local rc=0
    local v=0

    numVers=$(jq '.versions | length' "${upgrade_config_file}")
    if [ -z "${numVers}" ]; then
        numVers=0
    fi
    # shellcheck disable=SC2004
    for (( v=0; v<$numVers; v++ ))
    do
        min_version=$(jq -r ".versions[${v}].min_version // \"unknown\"" "${upgrade_config_file}")
        min_required=$(jq -r ".versions[${v}].min_required // \"unknown\"" "${upgrade_config_file}")
        action=$(jq -r ".versions[${v}].action // \"fail\"" "${upgrade_config_file}")
        msg=$(jq -r ".versions[${v}].msg //\"missing\"" "${upgrade_config_file}")

        # If min_version or min_required is not set, skip this version entry from config file all together
        if [ "${min_version}" != "unknown" ] && [ "${min_required}" != "unknown" ]; then
            # Check if the code verison is the SAME or HIGHER than the one from the config, if not SKIP
            ret_semver=$(semver_compare "${min_version}" "${code_workspace_ver}")
            if [ "${ret_semver}" == "same" ] || [ "${ret_semver}" == "second" ]; then
                # Check if the version from the statefile is unknown (there are no "code_version" tags in the statefile)a, if so return failure
                if [ "${code_statefile_ver}" != "unknown" ]; then
                    # Check if the required version is the SAME or HIGHER that the one from the statefile
                    ret_semver=$(semver_compare "${min_required}" "${code_statefile_ver}")
                    if [ "${ret_semver}" == "first" ]; then
                        ret_val=${msg}
                        # If the action is to fail, no need to check others
                        if [ "${action}" == "fail" ]; then
                            rc=1
                            break
                        
                        
                        
                        
                        fi
                    fi
                else
                    ret_val="ERROR: Unable to determine the current workspace code version from tags in the statefile.  If you are changing releases, try going back to the latest version of the previous release and doing a plan again."
                    rc=1
                    break
                fi
            fi
        fi
    done
    echo "${ret_val}"
    return ${rc}
}

function process_variable_action() {
    local name=$1
    local action=$2  
    local found=$3
    local msg=$4
    local foundState=""
    local level="INFO"
    local shouldExit=0

    case "${found}" in
    true)
        foundState="was"
        ;;
    false)
        foundState="was not"
        ;;
    esac

    case ${action} in
        fail)
            level="ERROR"
            shouldExit=1
            ;;
        warn)
            level="WARN"
            ;;
        info)
            level="INFO"
            ;;
    esac
    if [ -n "${foundState}" ]; then
        # shellcheck disable=SC2028
        echo "${level} ${name} ${foundState} found: ${msg}\n"
    else
        # shellcheck disable=SC2028
        echo "${level}: ${name} - ${msg}\n"
    fi
    return ${shouldExit}
}

function process_resource_action() {
    local old_name=$1
    local new_name=$2
    local action=$3
    local msg=$4
    local tf_state_file=$5
    local tf_statefile_ver=$6
    local tf_vars_file=$7
    local tf_workspace_ver=$8
    local resourceAction=""
    local level="INFO"
    local shouldExit=0
    local rc=0
    tf_cmd=/usr/local/bin/terraform$(fixTFVersion $6 $8)

    case ${action} in
        mv)
            "${tf_cmd}" state mv "${old_name}" "${new_name}"
            rc=$?
            if [ $rc -eq 0 ]; then
                level="INFO"
                resourceAction="succeeded"
            else
                level="ERROR"
                resourceAction="failed"
                shouldExit=1
            fi
            # shellcheck disable=SC2028
            echo "\n${level} Resource migration from ${old_name} to ${new_name} ${resourceAction}\n"
            ;;
        rm)
            "${tf_cmd}" state rm "${old_name}"
            rc=$?
            if [ $rc -eq 0 ]; then
                level="INFO"
                resourceAction="succeeded"
            else
                level="ERROR"
                resourceAction="failed"
                shouldExit=1
            fi
            # shellcheck disable=SC2028
            echo "\n${level} Resource ${old_name} removal ${resourceAction}\n"
            ;;
        import)
            "${tf_cmd}" import -var-file="${tf_vars_file}" "${new_name}" "${old_name}"
            rc=$?
            if [ $rc -eq 0 ]; then
                level="INFO"
                resourceAction="succeeded"
            else
                level="ERROR"
                resourceAction="failed"
                shouldExit=1
            fi
            # shellcheck disable=SC2028
            echo "\n${level} Resource imported to ${new_name} ${resourceAction}\n"
            ;;
        list)
            level="INFO"
            ;;
        custom)
            # Custom modifications if required for a resource
            level="INFO"
            ;;
    esac
    return ${shouldExit}
}

function check_variables() {
    local tfvars_file=$1
    local upgrade_conf_file=$2
    local code_statefile_ver=$3
    local code_workspace_ver=$4
    local ret_val=""
    local grepRetCode=0
    local compared=""
    local numVars=0
    local v=0
    local name=""
    local regex_type=""
    local regex_leading_space=""
    local regex_data_type=""
    local action=""
    local msg=""
    local min_version=""
    local compared=""
    local prefix=""
    local regexp=""
    local rc=0
    local ret_code=0
    local grepOutput=""
    local grepRetCode=0
    local leading_spaces_regexp_prefix="^\s*"
    local non_leading_spaces_regexp_prefix="^"
    local name_regex_suffix="\s*=.*$"
  
    numVars=$(jq '.variables | length' "${upgrade_conf_file}")
    if [ -z "${numVars}" ]; then
        numVars=0
    fi

    # shellcheck disable=SC2004
    for (( v=0; v<$numVars; v++ ))
    do
        name=$(jq -r ".variables[${v}].name //\"unknown\"" "${upgrade_conf_file}")
        regex_type=$(jq -r ".variables[${v}].regex.type // \"na\"" "${upgrade_conf_file}")
        regex_leading_space=$(jq -r ".variables[${v}].regex.leading_space // \"disabled\"" "${upgrade_conf_file}" )
        regex_data_type=$(jq -r ".variables[${v}].regex.data_type // \"na\"" "${upgrade_conf_file}" )
        action=$(jq -r ".variables[${v}].action // \"fail\"" "${upgrade_conf_file}")
        msg=$(jq -r ".variables[${v}].msg //\"missing\"" "${upgrade_conf_file}")

        min_version=$(jq -r ".variables[${v}].min_version // \"missing\"" "${upgrade_conf_file}")
        if [ "${name}" != "unknown" ]; then
            if [ "${min_version}" != "missing" ]; then
                compared=$(semver_compare "${min_version}" "${code_workspace_ver}")
                if [ "${compared}" == "first" ]; then
                    continue
                fi
            fi
            prefix="${non_leading_spaces_regexp_prefix}"
            if [ "${regex_leading_space}" == "enabled" ]; then
                prefix="${leading_spaces_regexp_prefix}"
            fi

            regexp="${prefix}${name}${name_regex_suffix}"

            grepOutput=$(grep --regexp="${regexp}" < "${tfvars_file}")
            grepRetCode=$?

            if [ "${regex_type}" == "present" ]; then
                if [ "${grepRetCode}" -eq 0 ]; then
                    ret_val="${ret_val}$(process_variable_action "${name}" "${action}" true "${msg}")"
                    rc=$?
                    # If we already have a failure, don't update it
                    if [ "${ret_code}" -eq 0 ]; then
                        ret_code=${rc}
                    fi
                fi
            elif [ "${regex_type}" == "absent" ]; then
                if [ "${grepRetCode}" -eq 1 ]; then
                    ret_val="${ret_val}$(process_variable_action "${name}" "${action}" false "${msg}")"
                    rc=$?
                    # If we already have a failure, don't update it
                    if [ "${ret_code}" -eq 0 ]; then
                        ret_code=${rc}
                    fi
                fi
            fi

            case ${regex_data_type} in
                bool)
                    if [ "${grepRetCode}" -eq 0 ]; then
                        # Use the sheel pattern ${x%%#*} to remove anything on the output line after the comment character, before checking for true/false
                        value=$(echo "${grepOutput%%#*}" | cut -d'=' -f2 | grep -E "true|false")
                        if [ -n "${value}" ]; then
                            string_value=$(echo "${value}" | grep '\"')
                            if [ -n "${string_value}" ]; then
                                # If it is a string
                                ret_val="${ret_val}$(process_variable_action "${name}" "${action}" na "${msg}")"
                                rc=$?
                                # If we already have a failure, don't update it
                                if [ ${ret_code} -eq 0 ]; then
                                    ret_code=${rc}
                                fi
                            fi
                        else
                            # If it is not a boolean true/false
                            ret_val="${ret_val}$(process_variable_action "${name}" "${action}" na "${msg}")"
                            rc=$?
                            # If we already have a failure, don't update it
                            if [ "${ret_code}" -eq 0 ]; then
                                ret_code=${rc}
                            fi
                        fi
                    fi
                    ;;
                na)
                    ;;
                *)
                    ret_val="ERROR Cannot process variable, data_type ${regex_data_type} in not supported"
                    ;;
            esac
        else 
            ret_val="ERROR Cannot process variable defined in upgrade config file, no name is given."  
        fi 
    done
    echo "${ret_val}"
    return ${ret_code}
}

##################################
## Check if a resource block exist in the state file and perform action based on input from upgrade.json
## Inputs: TFState File, TFState Terraform version, upgrade.json
## Outputs: Success or failure
##################################
function check_resources() {
    local tf_state_file=$1
    local tf_statefile_ver=$2
    local upgrade_conf_file=$3
    local workspace_name=$4
    local tf_vars_file=$5
    local tf_workspace_ver=$6
    local ret_val=""
    local grepRetCode=0
    local compared=""
    local numRes=0
    local r=0
    local old_name=""
    local new_name=""
    local action=""
    local msg=""
    local min_version=""
    local res_list=""
    local rc=0
    local ret_code=0
    local grepRetCode=0
    tf_cmd=/usr/local/bin/terraform$(fixTFVersion $2 $6)
  
    numRes=$(jq '.resources | length' "${upgrade_conf_file}")
    if [ -z "${numRes}" ]; then
        numRes=0
    fi

    # ${tf_cmd} init
    # ${tf_cmd} workspace select "${workspace_name}"

    res_list=$("${tf_cmd}" state list)
    if [ -z "${res_list}" ]; then
        res_list=""
    else
        # shellcheck disable=SC2206
        res_listArr=($res_list)
    fi

    # shellcheck disable=SC2004
    for (( r=0; r<$numRes; r++ ))
    do
        old_name=$(jq -r ".resources[${r}].old_name //\"unknown\"" "${upgrade_conf_file}")
        new_name=$(jq -r ".resources[${r}].new_name //\"unknown\"" "${upgrade_conf_file}")
        action=$(jq -r ".resources[${r}].action // \"list\"" "${upgrade_conf_file}")
        msg=$(jq -r ".resources[${r}].msg //\"missing\"" "${upgrade_conf_file}")
        min_version=$(jq -r ".resources[${r}].min_version // \"missing\"" "${upgrade_conf_file}")

        if [ "${old_name}" != "unknown" ]; then
            for resource in "${res_listArr[@]}"
            do
                # shellcheck disable=SC2053
                if [[ "${resource}" == "${old_name}" ]]; then
                    ret_val="${ret_val}$(process_resource_action "${old_name}" "${new_name}" "${action}" "${msg}" "${tf_state_file}" "${tf_statefile_ver}" "${tf_vars_file}" "${tf_workspace_ver}")"
                    rc=$?
                    # If we already have a failure, don't update it
                    if [ "${ret_code}" -eq 0 ]; then
                        ret_code=${rc}
                        break
                    fi
                fi
            done
        else
            ret_val="ERROR Cannot process resource defined in upgrade config file, no name is given."
        fi 
    done

    # Push state file to s3 bucket here

    echo "${ret_val}"
    set +x
    return ${ret_code}
}

##################################
## Get the Terraform file that has the backend configuration in it
## Inputs: Directory
## Outputs: Backend File that contains s3 backend
##################################
function getTerraformBackendFile() {
    local dir=$1
    local files=""
    local file=""
    local backend_file=""
    local cnt=0

    files=$(find "${dir}" -maxdepth 1 -type f -iname '*_override.tf')
    
    if [ -n "${files}" ]; then
        for file in ${files}; do
            cnt=$(grep -c "backend.*s3.*{" "${file}")

            if [ "${cnt}" -eq 1 ]; then
                backend_file=${file}
                break
            fi
            # For Azure Blob backend
            cnt=$(grep -c "backend.*azurerm.*{" "${file}")
            if [ "${cnt}" -eq 1 ]; then
                debug_log 5 "Found Azure override backend"
                backend_file="${file}"
                break
            fi
        done
    fi

    if [ -z "${backend_file}" ]; then
        files=$(find "${dir}" -maxdepth 1 -type f -iname '*.tf')

        if [ -n "${files}" ]; then
            for file in ${files}; do
                cnt=$(grep -c "backend.*s3.*{" "${file}")

                if [ "${cnt}" -eq 1 ]; then
                    backend_file="${file}"
                    break
                fi
                cnt=$(grep -c "backend.*azurerm.*{" "${file}")
                if [ "${cnt}" -eq 1 ]; then
                    backend_file="${file}"
                    break
                fi
            done
        fi
    fi

    echo "${backend_file}"
}

##################################
## Search for the backend configuration in a terraform file and return a value based on the key
## Inputs: File, Key
## Outputs: Value of key from s3 backend in file
##################################
function getTerraformBackendValueFromFile() {
    local file=$1
    local key=$2
    local val=""

    while read -r object name rest; do
        if [ "${object}" == "backend" ]; then
            if [ "${name}" == '"azurerm"' ] || [ "${name}" == '"s3"' ]; then
                # shellcheck disable=SC2034
                while read -r var x val junk; do
                    if [ "${var}" == "}" ]; then
                        break
                    fi

                    if [ "${var}" == "${key}" ]; then
                        val=$(echo "${val}" | tr -d \")
                        break
                    fi
                done
            fi
        fi
    done < "${file}"

    echo "${val}"
}

##################################
## Uploads a state file to the appropriate backend
## Inputs: Workspace Dir, TFState File Path
## Outputs: Success or failure
##################################
function uploadTerraformWorkspaceStatefile() {
    local dir=$1
    local workspace=$2
    local tfstate_file=$3
    local ret_val=""
    local rc=0
    local file=""
    local bucket=""
    local prefix=""
    local filename=""
    local profile=""
    local region=""
    local storage_account_name=""
    local container_name=""
    local key=""
    local dynamodb_table=""

    file=$(getTerraformBackendFile "${dir}")

    if [ -n "${file}" ]; then
        # See if we can get the required AWS settings
        bucket=$(getTerraformBackendValueFromFile "${file}" bucket)
        prefix=$(getTerraformBackendValueFromFile "${file}" workspace_key_prefix)
        filename=$(getTerraformBackendValueFromFile "${file}" key)
        profile=$(getTerraformBackendValueFromFile "${file}" profile)
        region=$(getTerraformBackendValueFromFile "${file}" region)
        dynamodb_table=$(getTerraformBackendValueFromFile "${file}" dynamodb_table)

        # See if we can get the required Azure settings
        storage_account_name=$(getTerraformBackendValueFromFile "${file}" storage_account_name)
        container_name=$(getTerraformBackendValueFromFile "${file}" container_name)
        key=$(getTerraformBackendValueFromFile "${file}" key)

        if [ -n "${bucket}" ] && [ -n "${prefix}" ] && [ -n "${filename}" ] && [ -n "${profile}" ] && [ -n "${region}" ]; then
            # AWS Backend
            ret_val=$(aws s3 cp "${tfstate_file}" "s3://${bucket}/${prefix}/${workspace}/${filename}" --profile "${profile}" --region "${region}" --acl "bucket-owner-full-control")
            rc=$?
            if [[ "${rc}" == 0 ]] && [[ "${dynamodb_table}" != "" ]]; then
                ret_val="${ret_val}$(aws dynamodb delete-item --table-name "${dynamodb_table}" --key "{\"LockID\": { \"S\": \"${bucket}/${prefix}/${workspace}/${filename}-md5\"}}" --profile "${profile}" --region "${region}")"
                rc=$?
            fi
        elif [ -n "${storage_account_name}" ] && [ -n "${container_name}" ] && [ -n "${key}" ]; then
            # Azure Backend
            ret_val=$(az storage blob upload --account-name "${storage_account_name}" --container-name "${container_name}" --name "${key}env:${dir}" --file "${tfstate_file}" 2>&1)
            rc=$?
        else
            ret_val="Backend not found"
            rc=1
        fi
    fi

    echo "${ret_val}"
    return $rc
}

#
# This section is for doing custom tests not supported by the JSON Confiuration File
# CAUTION - These have to work for all workspaces all versions!!!!
#
pre_init_custom() {
    # This is a CUSTOM check for getting to v3
    local rc=0
    local tf_statefile_ver=$1
    local code_statefile_ver=$2
    local code_workspace_ver=$3
    local tfvars_file=$4
    local tfstate_file=$5
    local cnt=0
    local bucket_name=""
    local aws_profile=""
    local region=""
    local versioning_state=""
    local ret_val=""
    local ret_semver=""
    local exit_code=""
    local temp_array=""
    local re='^[0-1]+$'
    local to_replace=("use_vpc" "sns_trigger" "sqs_trigger" "ext_sqs_strigger" "ddb_trigger")
    
    ##############################################################################################
    # NOTE: This special test is required for the S3 workspace to handle two conditions
    # 1 - When using v1 of the workspace it is necessary to block upgrading to v2 and the JSON configuration does not support this check
    # 2 - Versioning must be enabled on a bucket before you can upgrade from v1 to v3
    ##############################################################################################
    cnt=$(grep "code_path" ${tfstate_file} | grep -c "wdpr-s3-workspaces")
    if [ ${cnt} -gt 0 ]; then
        if [ "${tf_statefile_ver}" == "0.12.31" ] && [ "${code_statefile_ver}" != "unknown" ] && [ ${code_workspace_ver:0:1} -eq 2 ]; then
            ret_val="ERROR: There is no upgrade path to v2.x from v1.x. Please upgrade to the latest v1.x release and then you could upgrade to v3.x"
            rc=1
        fi
        if [ ${rc} -eq 0 ]; then
            # We check that the current version is 1 and it is trying to go to v3
            if [[ ${code_statefile_ver:0:1} -eq 1 && ${code_workspace_ver:0:1} -eq 3 ]]; then
                # shellcheck disable=SC2207
                bucket_name=($(jq -r '.outputs.s3_bucket_name.value | split(",")' ${tfstate_file} | tr -d '[],'))
                if [ ${#bucket_name[@]} -eq 1 ]; then
                    bucket_name=$(echo ${bucket_name[0]} | tr -d '"')
                    aws_profile=$(grep -w '^account' ${tfvars_file} | cut -d'=' -f2 | tr -d '[:space:]' | sed 's/"//g')
                    region=$(grep -w '^region' ${tfvars_file} | cut -d'=' -f2 | tr -d '[:space:]' | sed 's/"//g')
                    versioning_state=$(aws --profile ${aws_profile} --region ${region} s3api get-bucket-versioning --bucket ${bucket_name} | jq -r ".Status")
                    if [ "${versioning_state}" == "Suspended" ]; then
                        ret_val="ERROR: You should enable versioning on this bucket before upgrading"
                        rc=1
                    fi
                fi
            fi
        fi
    fi

    ##############################################################################################
    # TODO: Test/implement for all workspaces
    # For Terraform 0.12 and greater, env vars need to be escaped ${}->$${}
    ##############################################################################################
    cnt=$(grep "code_path" ${tfstate_file} | grep -c "wdpr-lambda-workspaces")
    if [ ${cnt} -gt 0 ]; then
        ret_semver=$(semver_compare "${tf_statefile_ver}" "0.12.0")
        if [ "${ret_semver}" == "same" ] || [ "${ret_semver}" == "second" ]; then
            grep -q '"${.*}"' ${tfvars_file}
            exit_code=$?
            if [ "$exit_code" == 0 ]; then
                echo "\n \nERROR: Environment variable(s) in your tfvars needs to escape interpolation.\n"
                readarray -t targets < <(grep -n '"${.*}"' ${tfvars_file})
                for each in "${targets[@]}"; do
                    echo "$each \n"
                done
                echo "Above variables should have \$\${variable}. \n
                Refer to INSTRUCTIONS.md for more info. \n"
                rc=1
            fi
        fi
        if [ ${rc} -eq 0 ]; then
            # shellcheck disable=SC2068
            for replaceable in ${to_replace[@]}; do
                if [ ${rc} -eq 0 ]; then
                    readarray -t temp_array < <(grep -n -w ${replaceable} ${tfvars_file})
                    if [ ! -z "$temp_array" ]; then
                        for ((i = 0; i < ${#temp_array[@]}; i++)); do
                            value=$(echo ${temp_array[i]} | cut -d'=' -f2 | tr -d '[:space:]' | sed 's/"//g')
                            if [[ "${value}" =~ $re ]]; then
                                echo "\n\nERROR: '${replaceable}' should be boolean (true/false). Please update it in your tfvars\n"
                                echo ${temp_array[i]}
                                rc=1
                                break
                            fi
                        done
                    fi
                fi
            done
        fi
    fi
    
    echo "${ret_val}"
    return ${rc}
}

#
# This section is for doing custom tests not supported by the JSON Confiuration File
# CAUTION - These have to work for all workspaces all versions!!!!
#
pre_plan_custom() {
    local rc=0
    local tfvars_file=$1
    local tfstate_file=$2
    local tf_statefile_ver=$3
    local code_statefile_ver=$4
    local code_workspace_ver=$5
    local tf_workspace_ver=$6
    local action="mv"
    local ret_val=""
    local res_list=""
    local base_name=""
    local default_log_group_base_name="/aws/lambda/"
    local sns_log_group_base_name="sns"
    local alias_base_name="arn:aws:lambda"
    local function_name=""
    local default_log_group_name=""
    local sns_log_group_name=""
    local sns_topic_name=""
    local dlq_name=""
    local queue_name=""
    local alias_name=""
    local real_name=""
    local real_default_log_group_name=""
    local real_sns_log_group_name=""
    local real_sns_topic_name=""
    local real_dlq_name=""
    local real_queue_name=""
    local real_alias_name=""
    local account_id=""
    local region=""
    local cnt=0
    local shouldExit=0
    tf_cmd=/usr/local/bin/terraform$(fixTFVersion $3 $6)

    cnt=$(grep "code_path" ${tfstate_file} | grep -c "wdpr-lambda-workspaces")
    if [ ${cnt} -gt 0 ] && [ ${code_statefile_ver} != "unknown" ]; then
        ret_semver=$(semver_compare "${code_statefile_ver}" "2.7.0") # we check that the state file is v2.7.x or higher
        if [ "${ret_semver}" == "first" ] || [ "${ret_semver}" == "same" ]; then
            ret_semver=$(semver_compare "${code_statefile_ver}" "3.0.0") # we check that the state file is lower than v3.x 
            if [ "${ret_semver}" == "second" ]; then
                ret_semver=$(semver_compare "${code_workspace_ver}" "3.0.0") # we check that the version we are running is v3.0 or higher
                if [ "${ret_semver}" == "first" ] || [ "${ret_semver}" == "same" ]; then
                    # we get a list of all the resources we are going to rename
                    res_list=$(${tf_cmd} state list | grep 'aws_lambda_function.default\|aws_cloudwatch_log_group\|aws_sqs_queue\|aws_sns_topic.sns_lambda_trigger\|consul_key_prefix.lambda_function_conf\|aws_lambda_alias\|data.aws_sqs_queue')
                    if [ -z "${res_list}" ]; then
                        res_list=""
                    else
                        res_listArr=($res_list)
                    fi
                    account_id=$(${tf_cmd} state show 'data.aws_caller_identity.current' | grep account_id | cut -d'=' -f2 | tr -d '\"[:space:]')
                    region=$(grep -w '^region' ${tfvars_file} | cut -d'=' -f2 | tr -d '[:space:]' | sed 's/"//g')
                    base_name=$(grep -m 1 -w base_name ${tfstate_file} | cut -d':' -f2 | tr -d '\",[:space:]') # we get the base name from the state file
                    default_log_group_base_name="${default_log_group_base_name}${base_name}"
                    sns_log_group_base_name="${sns_log_group_base_name}/${region}/${account_id}/${base_name}"
                    alias_base_name="${alias_base_name}:${region}:${account_id}:function:${base_name}"
                    for resource in "${res_listArr[@]}"; do
                        if [[ "${resource}" == *"aws_cloudwatch_log_group.default"* ]]; then
                            default_log_group_name=$(${tf_cmd} state show ${resource} | grep -m 1 name | cut -d'=' -f2 | tr -d '\"[:space:]') # we get the log group name from the state file
                            real_default_log_group_name=$(echo ${default_log_group_name} | sed  s!^${default_log_group_base_name}-!!) # we remove the base name from the log group to get the real name for the logical resource
                            if [ "${resource}" == "aws_cloudwatch_log_group.default[\"${real_default_log_group_name}\"]" ]; then
                                continue # this means that the resource was already updated
                            fi
                            ret_val="${ret_val}$(process_resource_action "${resource}" "aws_cloudwatch_log_group.default[\"${real_default_log_group_name}\"]" "${action}" "" "${tf_state_file}" "${tf_statefile_ver}" "${tf_vars_file}" "${tf_workspace_ver}")"
                            rc=$?
                            if [ "${rc}" -eq 1 ]; then
                                shouldExit=${rc}
                            fi
                        elif [[ "${resource}" == *"aws_cloudwatch_log_group.sns"* ]]; then
                            sns_log_group_name=$(${tf_cmd} state show ${resource} | grep -m 1 name | cut -d'=' -f2 | tr -d '\"[:space:]') # we get the log group name from the state file
                            real_sns_log_group_name=$(echo ${sns_log_group_name} | sed  s!^${sns_log_group_base_name}-!! | sed 's/\/Failure//') # we remove the base name from the log group to get the real name for the logical resource
                            if [ "${resource}" == "aws_cloudwatch_log_group.sns_default[\"${real_sns_log_group_name}\"]" ] || [ "${resource}" == "aws_cloudwatch_log_group.sns_default_failure[\"${real_sns_log_group_name}\"]" ]; then
                                continue # this means that the resource was already updated
                            fi
                            if [[ "${resource}" == *"aws_cloudwatch_log_group.sns_default_failure"* ]]; then
                                ret_val="${ret_val}$(process_resource_action "${resource}" "aws_cloudwatch_log_group.sns_default_failure[\"${real_sns_log_group_name}\"]" "${action}" "" "${tf_state_file}" "${tf_statefile_ver}" "${tf_vars_file}" "${tf_workspace_ver}")"
                            else
                                ret_val="${ret_val}$(process_resource_action "${resource}" "aws_cloudwatch_log_group.sns_default[\"${real_sns_log_group_name}\"]" "${action}" "" "${tf_state_file}" "${tf_statefile_ver}" "${tf_vars_file}" "${tf_workspace_ver}")"
                            fi
                            rc=$?
                            if [ "${rc}" -eq 1 ]; then
                                shouldExit=${rc}
                            fi
                        elif [[ "${resource}" == *"aws_lambda_function"* ]]; then
                            function_name=$(${tf_cmd} state show ${resource} | grep function_name | cut -d'=' -f2 | tr -d '\"[:space:]') # we get the function name from the state file
                            real_name=$(echo ${function_name} | sed s/^${base_name}-//) # we remove the base name from the function name to get the real name of the function, which is also defined in the tfvars
                            if [ "${resource}" == "aws_lambda_function.default[\"${real_name}\"]" ]; then
                                continue # this means that the resource was already updated
                            fi
                            ret_val="${ret_val}$(process_resource_action "${resource}" "aws_lambda_function.default[\"${real_name}\"]" "${action}" "" "${tf_state_file}" "${tf_statefile_ver}" "${tf_vars_file}" "${tf_workspace_ver}")"
                            rc=$?
                            if [ "${rc}" -eq 1 ]; then
                                shouldExit=${rc}
                            fi
                        elif [[ "${resource}" == *"aws_sns_topic"* ]]; then
                            sns_topic_name=$(${tf_cmd} state show ${resource} | grep -m 1 name | cut -d'=' -f2 | tr -d '\"[:space:]') # we get the sns topic name from the state file
                            real_sns_topic_name=$(echo ${sns_topic_name} | sed s/^${base_name}-//)
                            if [ "${resource}" == "aws_sns_topic.sns_lambda_trigger[\"${real_sns_topic_name}\"]" ]; then
                                continue # this means that the resource was already updated
                            fi
                            ret_val="${ret_val}$(process_resource_action "${resource}" "aws_sns_topic.sns_lambda_trigger[\"${real_sns_topic_name}\"]" "${action}" "" "${tf_state_file}" "${tf_statefile_ver}" "${tf_vars_file}" "${tf_workspace_ver}")"
                            rc=$?
                            if [ "${rc}" -eq 1 ]; then
                                shouldExit=${rc}
                            fi
                        elif [[ "${resource}" == *"aws_sqs_queue.dlq"* ]]; then
                            dlq_name=$(${tf_cmd} state show ${resource} | grep -m 1 name | cut -d'=' -f2 | tr -d '\"[:space:]') # we get the dlq name from the state file
                            real_dlq_name=$(echo ${dlq_name} | sed s/^${base_name}-// | sed 's/-dlq$//' | sed 's/.fifo$//')
                            if [ "${resource}" == "aws_sqs_queue.dlq[\"${real_dlq_name}\"]" ]; then
                                continue # this means that the resource was already updated
                            fi
                            ret_val="${ret_val}$(process_resource_action "${resource}" "aws_sqs_queue.dlq[\"${real_dlq_name}\"]" "${action}" "" "${tf_state_file}" "${tf_statefile_ver}" "${tf_vars_file}" "${tf_workspace_ver}")"
                            rc=$?
                            if [ "${rc}" -eq 1 ]; then
                                shouldExit=${rc}
                            fi
                        elif [[ "${resource}" == *"aws_sqs_queue.sqs_lambda_trigger"* ]]; then
                            queue_name=$(${tf_cmd} state show ${resource} | grep -m 1 name | cut -d'=' -f2 | tr -d '\"[:space:]') # we get the queue name from the state file
                            real_queue_name=$(echo ${queue_name} | sed s/^${base_name}-// | sed 's/.fifo$//')
                            if [ "${resource}" == "aws_sqs_queue.sqs_lambda_trigger[\"${real_queue_name}\"]" ]; then
                                continue # this means that the resource was already updated
                            fi
                            ret_val="${ret_val}$(process_resource_action "${resource}" "aws_sqs_queue.sqs_lambda_trigger[\"${real_queue_name}\"]" "${action}" "" "${tf_state_file}" "${tf_statefile_ver}" "${tf_vars_file}" "${tf_workspace_ver}")"
                            rc=$?
                            if [ "${rc}" -eq 1 ]; then
                                shouldExit=${rc}
                            fi
                        elif [[ "${resource}" == *"consul_key_prefix"* ]]; then
                            if [ "${resource}" == "consul_key_prefix.lambda_function_conf[\"tokens\"]" ]; then
                                continue # this means that the resource was already updated
                            fi
                            ret_val="${ret_val}$(process_resource_action "${resource}" "consul_key_prefix.lambda_function_conf[\"tokens\"]" "${action}" "" "${tf_state_file}" "${tf_statefile_ver}" "${tf_vars_file}" "${tf_workspace_ver}")"
                            rc=$?
                            if [ "${rc}" -eq 1 ]; then
                                shouldExit=${rc}
                            fi
                        elif [[ "${resource}" == *"aws_lambda_alias"* ]]; then
                            alias_name=$(${tf_cmd} state show ${resource} | grep -m 1 arn | cut -d'=' -f2 | tr -d '\"[:space:]')
                            real_alias_name=$(echo ${alias_name} | sed s/^${alias_base_name}-//)
                            if [ "${resource}" == "aws_lambda_alias.alias[\"${real_alias_name}\"]" ]; then
                                continue # this means that the resource was already updated
                            fi
                            ret_val="${ret_val}$(process_resource_action "${resource}" "aws_lambda_alias.alias[\"${real_alias_name}\"]" "${action}" "" "${tf_state_file}" "${tf_statefile_ver}" "${tf_vars_file}" "${tf_workspace_ver}")"
                            rc=$?
                            if [ "${rc}" -eq 1 ]; then
                                shouldExit=${rc}
                            fi
                        elif [[ "${resource}" == *"data.aws_sqs_queue"* ]]; then
                            ext_sqs_name=$(${tf_cmd} state show ${resource} | grep -m 1 name | cut -d'=' -f2 | tr -d '\"[:space:]') # we get the external sqs name from the state file
                            if [ "${resource}" == "data.aws_sqs_queue.ext_sqs_queue[\"${ext_sqs_name}\"]" ]; then
                                continue # this means that the resource was already updated
                            fi
                            ret_val="${ret_val}$(process_resource_action "${resource}" "data.aws_sqs_queue.ext_sqs_queue[\"${ext_sqs_name}\"]" "${action}" "" "${tf_state_file}" "${tf_statefile_ver}" "${tf_vars_file}" "${tf_workspace_ver}")"
                            rc=$?
                            if [ "${rc}" -eq 1 ]; then
                                shouldExit=${rc}
                            fi
                        else
                            echo "${resource} is invalid\n"
                            shouldExit=1
                        fi
                    done
                fi
            fi
        fi
    fi
    echo "${ret_val}"
    return ${shouldExit}
}

#
# Function to handle "pre" action precessing 
# All output will be consumed and displayed by the caller (TPM in most cases)
# Ex. pre [init | plan | apply ] tf_statefile_ver tf_running_ver code_statefile_ver code_workspace_ver Workpsace_path workspace_name
#
pre_stage() {
    local stage=$1
    local action=$2
    local tf_statefile_ver=$3
    local tf_workspace_ver=$4
    local code_statefile_ver=$5
    local code_workspace_ver=$6
    local workspace_path=$7
    local workspace_name=$8
    local tfvars_file=""
    local tfstate_file=""
    local upgrade_config_file=""
    local import_config_file=""
    local ret_val=""
    local statefile_resources_count=0
    local rc=0

    #
    # Set some basic variables
    #
    tfvars_file="${workspace_path}/env/${workspace_name}.tfvars"
    tfstate_file="${workspace_path}/${workspace_name}.state"
    upgrade_config_file="${workspace_path}/scripts/upgrade.json"
    import_config_file="${workspace_path}/custom/import_${workspace_name}.json"
    #
    # The statefile should be in the workspace path so we can confirm it
    # We can also get counts of resources and outputs
    #
    # This returns a warning as there is nothing a user could do to fix this if it failed the workflow!
    if [ ! -f "${tfstate_file}" ]; then
        echo "WARNING: Workspace statefile is not available.  This script should not have been called as part of the workflow."
    else
        statefile_resources_count=$(getStatefileResourceCount "${tfstate_file}")
        if [ -z "${statefile_resources_count}" ]; then
            statefile_resources_count=0
        fi

        case ${action} in
            init)
                ret_val=$(pre_init_custom "${tf_statefile_ver}" "${code_statefile_ver}" "${code_workspace_ver}" "${tfvars_file}" "${tfstate_file}")
                rc=$?
                if [ -f "${upgrade_config_file}" ] && [ ${rc} -eq 0 ]; then
                    # If there are no resources in the statefile "code_version" will always be "unknown" so skip this check
                    if [ ${statefile_resources_count} -gt 0 ]; then
                        ret_val=$(check_code_ver "${code_statefile_ver}" "${code_workspace_ver}" "${upgrade_config_file}")
                        rc=$?
                    fi
                    # If we already have an error, no need to check further
                    if [ ${rc} -eq 0 ]; then
                        ret_val=$(check_tf_ver "${tf_statefile_ver}" "${code_workspace_ver}" "${upgrade_config_file}")
                        rc=$?
                    fi
                    # If we already have an error, no need to check further
                    if [ ${rc} -eq 0 ]; then
                        ret_val=$(check_variables "${tfvars_file}" "${upgrade_config_file}" "${code_statefile_ver}" "${code_workspace_ver}")
                        rc=$?
                    fi
                fi
                ;;
            plan)
                ret_val=$(pre_plan_custom "${tfvars_file}" "${tfstate_file}" "${tf_statefile_ver}" "${code_statefile_ver}" "${code_workspace_ver}" "${tf_workspace_ver}")
                rc=$?
                if [ -f "${import_config_file}" ] && [ -f "${upgrade_config_file}" ] && [ ${rc} -eq 0 ]; then
                    if [ ${statefile_resources_count} -gt 0 ]; then
                        ret_val="${ret_val}$(import_resources "${tfstate_file}" "${tf_statefile_ver}" "${import_config_file}" "${upgrade_config_file}" "${workspace_name}" "${tfvars_file}" "${tf_workspace_ver}")"
                        rc=$?
                    fi
                fi
                if [ -f "${upgrade_config_file}" ] && [ ${rc} -eq 0 ]; then
                    if [ ${statefile_resources_count} -gt 0 ]; then
                        ret_val="${ret_val}$(check_resources "${tfstate_file}" "${tf_statefile_ver}" "${upgrade_config_file}" "${workspace_name}" "${tfvars_file}" "${tf_workspace_ver}")"
                        rc=$?
                    fi
                fi

                # This will remove the consul prefix resources from state file for migrating to vault
                if [ ${statefile_resources_count} -gt 0 ]; then
                    tf_cmd=/usr/local/bin/terraform$(fixTFVersion "${tf_statefile_ver}" "${tf_workspace_ver}")
                    old_name=consul_key_prefix.lambda_functions
                    new_name=""
                    tf_action=rm
                    if ${tf_cmd} state list | grep -q "^${old_name}\["; then
                        # The resource exists in the Terraform state
                        ret_val="${ret_val}$(process_resource_action "${old_name}" "${new_name}" "${tf_action}" "${msg}" "${tfstate_file}" "${tf_statefile_ver}" "${tf_vars_file}" "${tf_workspace_ver}")"
                        rc=$?
                    fi
                fi
                ;;
            apply)
                ;;
            *)
                ret_val="WARNING: Invalid action vailue (${action}) in stage: pre"
                ;;
        esac
    fi
    echo "${ret_val}"
    return ${rc}
}

#
# Function to handle custom import of resources which are manually created 
# This function will be call in the Pre Plan execution of the script so the conflicting resource will be added to the statfile and during plan it will be part of the change/update resources
#
import_resources() {

    local tf_state_file=$1
    local tf_statefile_ver=$2
    local import_config_file=$3
    local upgrade_conf_file=$4
    local workspace_name=$5
    local tf_vars_file=$6
    local tf_workspace_ver=$7
    local numRes=0
    local is_import_enabled="false"
    local ret_val=""
    local res_list=""
    local r=0
    local workspace=""
    local new_name=""
    local id=""
    local action=""
    local msg=""
    local min_version=""
    local res_list=""
    local rc=0
    local ret_code=0
    local grepRetCode=0
    local already_present=0
    tf_cmd=/usr/local/bin/terraform$(fixTFVersion $2 $7)


    # Get the list of Resources which are in the current state file
    res_list=$("${tf_cmd}" state list)  
    if [ -z "${res_list}" ]; then
        res_list=""
    else
        # shellcheck disable=SC2206
        res_listArr=($res_list)
    fi

    # Check if the Import is allowed for SE to read the json file from custom folder 
    is_import_enabled=$(jq -r ".custom_action[0].enable_se_import //\"unknown\"" "${upgrade_conf_file}")

    # Import logic for custom resource which are manually created 
    if [[ "$is_import_enabled" == "true" ]]; then
        numRes=$(jq '.resources | length' "${import_config_file}")
        if [ -z "${numRes}" ]; then
            numRes=0
        fi
        # shellcheck disable=SC2004
        # This Loop is to check if the resource mentioned in the import.json file is already present in the state file. Also to validate if the import is for the expected workspace
        for (( r=0; r<$numRes; r++ ))
        do
            if [ $already_present -eq 0 ]; then
                new_name=$(jq -r ".resources[${r}].new_name //\"unknown\"" "${import_config_file}")
                workspace=$(jq -r ".resources[${r}].workspace //\"unknown\"" "${import_config_file}")
                id=$(jq -r ".resources[${r}].id //\"unknown\"" "${import_config_file}")
                action=$(jq -r ".resources[${r}].action // \"list\"" "${import_config_file}")
                msg=$(jq -r ".resources[${r}].msg //\"missing\"" "${import_config_file}")
                min_version=$(jq -r ".resources[${r}].min_version // \"missing\"" "${import_config_file}")

                if [ "${new_name}" != "unknown" ]; then
                    for resource in "${res_listArr[@]}"
                    do                
                        # shellcheck disable=SC2053
                        if [[ "${resource}" == "${new_name}" ]] ||  [[ "${workspace_name}" != "${workspace}" ]]; then
                            ret_val="Resources already available in state file or Import is not for the workspace : ${workspace}"
                            echo -e "Resources Name already present : ${resource}"  
                            ret_code=1
                            already_present=1
                            break
                        fi
                    done
                
                else
                    ret_val="ERROR Cannot process resource defined in upgrade config file, no name is given."
                fi
            else
                break
            fi
        done
        
        if [ $ret_code -eq 0 ]; then
            # This loop is to validate is the resource is only for import action and make sure the resource is not already present in the state file
            # Once validate the above condition execute the import command to import the resources to the state file 
            for (( r=0; r<$numRes; r++ ))
            do
                new_name=$(jq -r ".resources[${r}].new_name //\"unknown\"" "${import_config_file}")
                workspace=$(jq -r ".resources[${r}].workspace //\"unknown\"" "${import_config_file}")
                id=$(jq -r ".resources[${r}].id //\"unknown\"" "${import_config_file}")
                action=$(jq -r ".resources[${r}].action // \"list\"" "${import_config_file}")
                msg=$(jq -r ".resources[${r}].msg //\"missing\"" "${import_config_file}")
                min_version=$(jq -r ".resources[${r}].min_version // \"missing\"" "${import_config_file}")
                if [ "${new_name}" != "unknown" ] && [ "${action}" == "import" ] && [ "${already_present}" -eq 0 ]; then
                    "${tf_cmd}" import -var-file="${tf_vars_file}" "${new_name}" "${id}"
                else
                    ret_val="ERROR Validate Resources Name/Action/If the Resources already part of the state file"
                fi 
            done 
            echo -e "Import Process completed"
        fi
    else
        echo -e "Import_resources Not activated"
    fi
    echo "${ret_val}"
    set +x
    return ${ret_code}
}

#
# Function to handle "post" action processig
# Ex. post [ init | plan | apply ] [ success | failure ]
#
post_stage() {
    local status=$3
    local rc=0
    
    status=$3 # used when stage is "post"
    if [ "${status}" != 'success' ]; then
        rc=1
    fi
    echo ""
    return ${rc} 
}

####################################################################
# MAIN SCRIPT
####################################################################

#
# Check the commnd line parameters
#
if [ $# -lt 2 ]; then
    usage
    exit 1
fi
if [ "$1" != "pre" ] && [ "$1" != "post" ]; then
    usage
    exit 1
fi
stage=$1
output=""
exit_code=0

#
# Main case statement for processing stage & action
#
case ${stage} in
    pre)
        if [ $# -eq 8 ]; then
            output=$(pre_stage "$@")
            exit_code=$?
        else
            usage
            exit_code=1
        fi
        ;;
    post)
        if [ $# -eq 3 ]; then
            output=$(post_stage "$@")
            exit_code=$?
        else
            usage
            exit_code=1
        fi
        ;;
    *)
        usage
    exit_code=1
        ;;
esac

if [ -n "${output}" ]; then
    echo "${output}"
fi
exit ${exit_code}
