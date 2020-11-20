#!/bin/bash
set -e

JSONPATH="[?(contains(type, 'Storage') || contains(type, 'KeyVault') || contains(type, 'SQL') || contains(type, 'Insights')) ].[resourceGroup]"

echo "retrieve all resource groups in a subscription"
RG_LIST=$(az resource list --query "${JSONPATH}"  -o tsv | sort -u)


for rg in ${RESOURCE_GROUPS[@]}
do
  RG_NAME=$(sed -e 's/^"//' -e 's/"$//' <<<"$rg")

  echo "retrieving locks for each resource group:"
  locks=$(az lock list -g $RG_NAME -o tsv)


  if [[ -z "$locks" && $locks==" " ]]; then
    echo "creating locks for resource group: $RG_NAME as they don't exist"
    az lock create --name SboxLockGroup --lock-type CanNotDelete --resource-group $RG_NAME
  fi
done
