#!/bin/bash
set -e

SUBS=$1

echo "retrieve all resource groups in a subscription"
RESOURCE_GROUPS=$(az group list --subscription DCD-CFTAPPS-SBOX | jq '.[].name')

for rg in ${RESOURCE_GROUPS[@]}; 
do
  RG_NAME=$(sed -e 's/^"//' -e 's/"$//' <<<"$rg")
  RSRC_LIST=$(az resource list -g $RG_NAME --subscription DCD-CFTAPPS-SBOX | jq '.[].type' | sed -e 's/^"//' -e 's/"$//' | grep -ciE 'Storage|KeyVault|Sql')
  echo "Total no of resources matched: $RSRC_LIST"
  echo "retrieving locks for each resource group in the subscription: "
  locks=$(az lock list -g $RG_NAME -o tsv)

  echo "Checking if no locks exist for the resource group: $RG_NAME then assign cannot delete lock"
  if [[ -z "$locks" && $locks==" " ]]; then
    echo "creating locks for resource group: $RG_NAME as they don't exist"
    az lock create --name SboxLockGroup --lock-type CanNotDelete --resource-group $RG_NAME
  fi
done
