#!/usr/bin/env bash
set -e

if [ -z "${RESOURCE_GROUPS_LIST}" ]; then
    echo "Resource Groups list is empty, aborting"
    exit 1
fi

IFS=', ' read -r -a RESOURCE_GROUPS_ARRAY <<< "$RESOURCE_GROUPS_LIST"
for RG in "${RESOURCE_GROUPS_ARRAY[@]}"
do

  echo "Retrieving locks for resource group $RG"
  LOCKS=$(az group lock list --resource-group $RG --query [].name --output tsv)

  echo "Checking if any locks exist for the resource group: $RG"
  if [ ! -z "$LOCKS" ]; then
    echo "Disabling lock for resource group: $RG"
    for RG_LOCK in ${LOCKS[@]};
    do
      LOCK=$(sed -e 's/^"//' -e 's/"$//' <<<"$RG_LOCK")
      az lock delete --name $LOCK --resource-group $RG
    done
  fi
  
done
