#!/bin/bash
set -e

JSONPATH_ALL="[?((contains(type, 'Storage') && tags.\"databricks-environment\" != 'true') || (contains(type, 'KeyVault') || contains(type, 'SQL') || contains(type, 'Insights') || contains(type, 'azureFirewalls') || contains(type, 'resources') || contains(type, 'virtualWans') || contains(type, 'servers') || contains(type, 'databaseAccounts') || contains(type, 'privateDnsZones')) && (tags."exemptFromAutoLock" != 'true') )].[resourceGroup]"
JSONPATH_ALL_PIPS="[?contains(publicIpAllocationMethod, 'Static')].[resourceGroup]"


echo "Retrieve all resource groups in a subscription"
RG_LIST=$(az resource list --query "${JSONPATH_ALL}"  -o tsv | sort -u &&
          az network public-ip list --query "${JSONPATH_ALL_PIPS}" -o tsv | sort -u )

exclusions=(
  mi-synapse-prod-rg
  mi-PROD-rg
  mi-ingestion-prod-rg
  mi-STG-rg
  mi-synapse-stg-rg
  cft-prod-00-aks-node-rg
  cft-prod-01-aks-node-rg
  cft-aat-00-aks-node-rg
  cft-aat-01-aks-node-rg
  ss-prod-00-aks-node-rg
  ss-prod-01-aks-node-rg
  ss-stg-00-aks-node-rg
  ss-stg-01-aks-node-rg
  cft-prod-network-rg
  cft-aat-network-rg
  cft-demo-network-rg
  ss-stg-network-rg
  ss-prod-network-rg
  managed-rg-fxateuu
  baubais-synapse
  ingest00-product-synapse001
  ingest01-product-synapse001
  ingest02-product-synapse001
  ingest03-product-synapse001
  ingest04-product-synapse001
  ingest05-product-synapse001
  ingest06-product-synapse001
  ingest07-product-synapse001
  ingest08-product-synapse001
  ingest09-product-synapse001
  ingest10-product-synapse001
)

RG_LIST_EXEMPT=$(az group list --query "[?tags.exemptFromAutoLock=='true'].name" -o tsv | sort -u )

for rg in ${RG_LIST[@]}
do
   [[ "${exclusions[@]}" =~ "$rg" ]] && echo "Skipping $rg as its whitelisted" && continue
   [[ "${RG_LIST_EXEMPT[@]}" =~ "$rg" ]] && echo "Skipping $rg as it exempt from locking" && continue
    echo "Retrieving locks for resource group: $rg"
    locks=$(az lock list -g $rg -o tsv)
    
    subname=$(az account show | jq .name)
    if [[ $subname == *"STG"* ]] || [[ $subname == *"NONPROD"* ]]
    then
      lockname="stg-lock"
    else
      lockname="prod-lock"
    fi

    if [[ -z "$locks" && $locks==" " ]]; then
      echo "Creating locks for resource group: $rg they don't exist"
      az lock create --name $lockname --lock-type CanNotDelete --resource-group $rg
    fi
done

