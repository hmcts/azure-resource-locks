#!/bin/bash
set -e

RESOURCETYPES_LIST=$1

if [ -z "${RESOURCETYPES_LIST}" ]; then
    echo "ResourceTypes list is empty, aborting"
    exit 1
fi

IFS=', ' read -r -a RESOURCETYPES_ARRAY <<< "$RESOURCETYPES_LIST"
echo "Array : $RESOURCETYPES_ARRAY"
for RESOURCETYPE in "${RESOURCETYPES_ARRAY[@]}"
do
    
  JSONPATH="[?(contains(type, '$RESOURCETYPE').[resourceGroup]"

  echo "retrieve all resource groups in a subscription"
  RG_LIST=$(az resource list --query "${JSONPATH}"  -o tsv | sort -u)

  for rg in ${RG_LIST[@]}; 
  do
    echo "retrieving locks for each resource group"
    locks=$(az group lock list -g $rg -o json | jq '.[].name')

    echo "locks: ${locks}"
    echo "Checking if locks exist for the resource group: $rg then disable locks"
    if [ ! -z "$locks" -a $locks != " " ]; then
      echo "disable lock for resource group: $rg"
      for rg_lock in ${locks[@]};
      do
        lock=$(sed -e 's/^"//' -e 's/"$//' <<<"$rg_lock")
        az lock delete --name $lock --resource-group $rg
      done
    fi
  done
done
