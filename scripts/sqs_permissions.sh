#!/bin/bash

clear_environment_variables () {
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
} 
#https://sqs.us-east-1.amazonaws.com/633112549318/wdpr-ra-B0090314-use1-sbx-hello-aloha
execute_permissions_modification () {
  op=$1
  operation="unknown"
  permissionCmd=""
  if [[ $op == "ADD" ]]
  then
    operation="add"
    permissionCmd="aws sqs add-permission --label lambda-access-$NAME --aws-account-id $LAMBDA_ACCOUNT --queue-url $QUEUE_URL --actions ReceiveMessage DeleteMessage GetQueueAttributes --region $REGION"
  elif [[ $op == "REMOVE" ]]
  then
    operation="remove"
    permissionCmd="aws sqs remove-permission --label lambda-access-$NAME --queue-url $QUEUE_URL  --region $REGION"
  else
    echo "Invalid Operation"
    clear_environment_variables
    exit 100
  fi
  echo "Executing $operation-permission on queue $QUEUE_URL for lambda to be triggered from SQS"
  runPermCmd=$( $permissionCmd )
  permStatus=$?
  if [[ $permStatus == 0 ]]
  then
    echo "Successfully called $operation-permission"
    echo $runPermCmd
  elif [[ $op == "REMOVE" ]]
  then
    echo "Error calling $operation-permission, cmd exited with $permStatus: $runPermCmd"
    echo "This occurred during the REMOVE operation. If the permissions weren't applied already then this is not a fatal error. Continuing"
  else
    echo "Error calling $operation-permission, cmd exited with $permStatus: $runPermCmd"
    clear_environment_variables
    exit $permStatus
  fi
}

clear_environment_variables
echo "Assuming $ROLE"
command="aws sts assume-role --role-arn "$ROLE" --role-session-name SQS_ADD_PERMISSIONS_$NAME"
runCmd=$( $command )
status=$?
if [[ $status == 0 ]]
then
  access_key=$(echo $runCmd | jq -r '.Credentials.AccessKeyId')
  secet_access_key=$(echo $runCmd | jq -r '.Credentials.SecretAccessKey')
  session_token=$(echo $runCmd | jq -r '.Credentials.SessionToken')
  export AWS_ACCESS_KEY_ID=$access_key
  export AWS_SECRET_ACCESS_KEY=$secet_access_key
  export AWS_SESSION_TOKEN=$session_token
  execute_permissions_modification "REMOVE"
  execute_permissions_modification "ADD"
else
  echo "Error assuming role $ROLE, status code is $status and run result is $runCmd"
  clear_environment_variables
  exit $status
fi
clear_environment_variables 


