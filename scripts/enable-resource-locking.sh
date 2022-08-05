#!/bin/bash
set -e

JSONPATH_ALL="[?(contains(type, 'Storage') && tags.\"databricks-environment\" != 'true' || contains(type, 'KeyVault') || contains(type, 'SQL') || contains(type, 'Insights') || contains(type, 'azureFirewalls') || contains(type, ('resources') || contains(type, ('virtualWans') || contains(type, ('servers') || contains(type, ('databaseAccounts') || contains(type, 'privateDnsZones'))].[resourceGroup]"
JSONPATH_ALL_PIPS="[?contains(publicIpAllocationMethod, 'Static')].[resourceGroup]"

#comment
echo "retrieve all resource groups in a subscription"
RG_LIST=$(az resource list --query "${JSONPATH_ALL}"  -o tsv | sort -u &&
          az network public-ip list --query "${JSONPATH_ALL_PIPS}" -o tsv | sort -u )

exclusions=(
  pre-stg #see https://tools.hmcts.net/jira/browse/DTSPO-9316?focusedCommentId=1341646
  pre-prod
)

for rg in ${RG_LIST[@]}
do
   [[ "${exclusions[@]}" =~ "$rg" ]] && echo "skipping $rg as its whitelisted" && continue
    echo "retrieving locks for resource group: $rg"
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


