#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

FUNCTION=$1
DATA=$2
mkdir -p ./tmp
echo "$DATA" > ./tmp/$FUNCTION.json

jq -f ./tmp/$FUNCTION.json