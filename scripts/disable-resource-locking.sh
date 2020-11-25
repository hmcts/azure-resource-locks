#!/bin/bash
set -e

JSONPATH="[?(contains(type, 'Storage') || contains(type, 'KeyVault') || contains(type, 'SQL') || contains(type, 'Insights')) ].[resourceGroup]"

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
