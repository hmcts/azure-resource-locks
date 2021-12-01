# azure-resource-locks
For maintaining azure resource lock configuration and automation

# Locks applicable for specific Resource Types
Currently the resource locks are applied to *resource groups* which have the following resource types :- 
* Storage
* Key Vault
* SQL Databases
* APP Insights
* Managed Identity

The list could be extended by adding *|| contains(type, '<<*resource type*>>'))* to the [JSONPATH](https://github.com/hmcts/azure-resource-locks/blob/056dc8882431966269951abbef2f5dd9fd727e5e/scripts/enable-resource-locking.sh#L4) in the *enable-resource-locking.sh*

# Pipeline jobs
The enable resource locks pipeline jobs are scheduled to *run every 3 hours* for the *CNP-DEV*, *CNP-Prod*, *SDS-STG* and *SDS-PROD* environments. 
Each pipeline has been configured to use the appropriate service connection automatically.
* [Enable-resource-locks](https://dev.azure.com/hmcts/CNP/)


The disable resource locks pipeline must be run manually by selecting the name of a subscription from the dropdown and entering a list of resource groups to be targeted via the *resource-groups-list* pipeline variable.
* On the [Disable-resource-locks](https://dev.azure.com/hmcts/CNP/_build?definitionId=423) build definition click on the *Run pipeline* button as shown in the image below:
![Alt text](/img/Run_pipeline.png?raw=true "Run Pipeline")
* Select the subscription to target as shown in the image below:
  ![Alt text](/img/subscription_parameter.png?raw=true "Choose subscription")
* Enter a list of resource group names for the *resource-groups-list* variable by clicking on variables under *Advanced Options*
    ![Alt text](/img/Add_variables.png?raw=true "Add Variables")

    Resource groups list to provided:
    ![Alt text](/img/resource-groups-list.png?raw=true "Resource groups list")
