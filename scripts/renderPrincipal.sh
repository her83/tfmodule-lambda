#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

tmp=$(mktemp)
cat "$@" > $tmp

cat $tmp >> /tmp/a
resourceType=$(cat $tmp | jq -r '.type')
case $resourceType in
    "user")
        user=$(cat $tmp | jq -r ".value | select (.!=null)")
        account=$(cat $tmp | jq -r ".account_id | select (.!=null)")
        PRINCIPAL="arn:aws:iam::$account:user/$user"
    ;;
    "role")
        role=$(cat $tmp | jq -r ".value | select (.!=null)")
        account=$(cat $tmp | jq -r ".account_id | select (.!=null)")
        PRINCIPAL="arn:aws:iam::$account:role/$role"
    ;;
    "account")
        account=$(cat $tmp | jq -r ".account_id | select (.!=null)")
        PRINCIPAL="$account"
    ;;
    "root")
        account=$(cat $tmp | jq -r ".account_id | select (.!=null)")
        PRINCIPAL="arn:aws:iam::$account:root"
    ;;
    *)
        PRINCIPAL=$(cat $tmp | jq -r '.value')
    ;;
esac 
jq -n --arg principal $PRINCIPAL '{"principal":$principal}'


