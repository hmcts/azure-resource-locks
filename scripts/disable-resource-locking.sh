#!/bin/bash
set -e

RESOURCE_GROUPS_LIST=$1

if [ -z "${RESOURCE_GROUPS_LIST}" ]; then
    echo "Resource Groups list is empty, aborting"
    exit 1
fi

IFS=', ' read -r -a RESOURCE_GROUPS_ARRAY <<< "$RESOURCE_GROUPS_LIST"
for RG in "${RESOURCE_GROUPS_ARRAY[@]}"
do

  echo "retrieving locks for each resource group"
  LOCKS=$(az group lock list -g $RG -o json | jq '.[].name')

  echo "Checking if LOCKS exist for the resource group: $RG then disable locks"
  if [ ! -z "$LOCKS" -a $LOCKS != " " ]; then
    echo "disable lock for resource group: $RG"
    for RG_LOCK in ${LOCKS[@]};
    do
      LOCK=$(sed -e 's/^"//' -e 's/"$//' <<<"$RG_LOCK")
      az lock delete --name $LOCK --resource-group $RG
    done
  fi
  
done
