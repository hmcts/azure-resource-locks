# Azure-Resource-Locks
For maintaining Azure resource lock configuration and automation

These are used to protect from automation gone wrong against resources that have persistent data that we really don't want accidentally deleted.

## Resource types
Currently the resource locks are applied to *resource groups* which have the following resource types:

* Storage
* Key Vault
* SQL Databases
* APP Insights
* Static IPs 
* Azure Firewall
* SaaS Resources
* Virtual Wan
* CosmosDB
* Frontdoor 
* App Gateways 
* Private DNS Zones 

The list could be extended by adding *|| contains(type, '<<*resource type*>>'))* to the [JSONPATH](https://github.com/hmcts/azure-resource-locks/blob/056dc8882431966269951abbef2f5dd9fd727e5e/scripts/enable-resource-locking.sh#L4) in the *enable-resource-locking.sh*

## Pipeline jobs

- [Enable-resource-locks](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=534)

   Scheduled to *run every 3 hours* for the environments below
    - *CNP-DEV*
    - *CNP-Prod*
    - *SDS-STG* 
    - *SDS-PROD* 
    - *HUB-PROD* 
    - *HUB-NONPROD*
    - *DCD-CFT-PROD*
- [Disable-resource-locks](https://dev.azure.com/hmcts/PlatformOperations/_build?definitionId=535)
    - Select the subscription and resource group(s) to run against from the job parameters

## Exempt from autolocking

- In order to exempt from auto locking resource, you can use below tag on the resource group which will filter out the resource group from being auto locked by Enable-resource-locks pipeline.
```bash
exemptFromAutoLock = true
```