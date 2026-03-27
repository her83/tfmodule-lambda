#!/bin/bash

clear_environment_variables() {
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
}

# clear_environment_variables
echo "Assuming $ROLE"
command="aws sts assume-role --role-arn "$ROLE" --role-session-name SNS_ADD_PERMISSIONS_$NAME"
runCmd=$($command)
status=$?

if [ $status -eq 0 ]; then
  access_key=$(echo $runCmd | jq -r '.Credentials.AccessKeyId')
  secet_access_key=$(echo $runCmd | jq -r '.Credentials.SecretAccessKey')
  session_token=$(echo $runCmd | jq -r '.Credentials.SessionToken')
  export AWS_ACCESS_KEY_ID=$access_key
  export AWS_SECRET_ACCESS_KEY=$secet_access_key
  export AWS_SESSION_TOKEN=$session_token

  operation="unknown"
  permissionCmd=""
  if [ "${OPERATION}" = "ADD" ]; then
    operation="add"
    echo "aws sns add-permission --label lambda-access-$NAME --aws-account-id $LAMBDA_ACCOUNT --topic-arn $TOPIC_ARN --action-name Subscribe ListSubscriptionsByTopic --region $REGION"
    permissionCmd="aws sns add-permission --label lambda-access-$NAME --aws-account-id $LAMBDA_ACCOUNT --topic-arn $TOPIC_ARN --action-name Subscribe ListSubscriptionsByTopic --region $REGION"
  elif [ "${OPERATION}" = "REMOVE" ]; then
    operation="remove"
    permissionCmd="aws sns remove-permission --label lambda-access-$NAME --topic-arn $TOPIC_ARN  --region $REGION"
  else
    echo "Invalid Operation"
    clear_environment_variables
    exit 100
  fi
  echo "Executing $operation-permission on topic $TOPIC_ARN for lambda to subscribe to topics"
  runPermCmd=$($permissionCmd)
  permStatus=$?
  if [ "${permStatus}" -eq 0 ]; then
    echo "Successfully called $operation-permission"
    echo $runPermCmd
  else
    echo "Error calling $operation-permission, cmd exited with $permStatus: $runPermCmd"
    clear_environment_variables
    exit $permStatus
  fi

else
  echo "Error assuming role $ROLE, status code is $status and run result is $runCmd"
  clear_environment_variables
  exit $status
fi
clear_environment_variables
