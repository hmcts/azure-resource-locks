#!/bin/bash
set -e

SUBS=$1

echo "retrieve all resource groups in a subscription"
RESOURCE_GROUPS=$(az group list | jq '.[].name')

for rg in ${RESOURCE_GROUPS[@]}; 
do
  RG_NAME=$(sed -e 's/^"//' -e 's/"$//' <<<"$rg")

  echo "retrieving locks for each resource group"
  locks=$(az group lock list -g ${RG_NAME} -o json | jq '.[].name')

  echo "locks: ${locks}"
  echo "Checking if locks exist for the resource group: $RG_NAME then disable locks"
  if [ ! -z "$locks" -a $locks != " " ]; then
    echo "disable lock for resource group: $RG_NAME"
    for rg_lock in ${locks[@]};
    do
      lock=$(sed -e 's/^"//' -e 's/"$//' <<<"$rg_lock")
      az lock delete --name $lock --resource-group $RG_NAME
    done
  fi
done
