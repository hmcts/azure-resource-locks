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
  LOCKS=$(az lock list --resource-group $RG --query '[].{id:id}' -o tsv)

  echo "Checking if any locks exist for the resource group: $RG"
  if [ ! -z "$LOCKS" ]; then
    echo "Disabling lock for resource group: $RG"
    for LOCK in $LOCKS;
    do
      if grep -q "$RG/providers/Microsoft.Authorization" <<< "$LOCK"
      then
      echo "Deleting resource group level lock $LOCK"
      az group lock delete --ids $LOCK

      else
      echo "Deleting resource level lock $LOCK"
      az lock delete --ids $LOCK

      fi
    done
  fi
  
done
