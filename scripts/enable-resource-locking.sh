#!/bin/bash
set -e

JSONPATH="[?(contains(type, 'Storage') || contains(type, 'KeyVault') || contains(type, 'SQL') || contains(type, 'Insights')) || contains(type, 'ManagedIdentity')) ].[resourceGroup]"

echo "retrieve all resource groups in a subscription"
RG_LIST=$(az resource list --query "${JSONPATH}"  -o tsv | sort -u)


for rg in ${RG_LIST[@]}
do
  echo "retrieving locks for each resource group:"
  locks=$(az lock list -g $rg -o tsv)
  
  subname=$(az account show | jq .name)
  if [[ $subname == *"STG"* ]]
  then
    lockname="stg-lock"
  else
    lockname="prod-lock"
  fi

  if [[ -z "$locks" && $locks==" " ]]; then
    echo "creating locks for resource group: $rg they don't exist"
    az lock create --name $lockname --lock-type CanNotDelete --resource-group $rg
  fi
done
