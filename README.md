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
The enable resource locks pipeline jobs are scheduled to *run every 3 hours* for *CNP-DEV* , *AAT* and *Prod* environments. Each pipeline has been configured to use service connection(set as a pipeline variable) for the corresponding environments
* [Enable-resource-locks-aat](https://dev.azure.com/hmcts/CNP/_build?definitionId=421)
* [Enable-resource-locks-prod](https://dev.azure.com/hmcts/CNP/_build?definitionId=422)


The disable resource locks pipeline needs running manually by  specifying the corresponding service Connection and *resource-groups-list* (set as pipeline variables) for the *CNP-DEV* , *AAT* and *Prod* environments
* On the [Disable-resource-locks](https://dev.azure.com/hmcts/CNP/_build?definitionId=423) build definition click on the *Run pipeline* button as shown below
![Alt text](/img/Run_pipeline.png?raw=true "Run Pipeline")
* Add variables *azureSubscription* and *resource-groups-list* as below
  * Click on variables under *Advanced Options*
    ![Alt text](/img/Add_variables.png?raw=true "Add Variables")
     
    Service connection names - azurerm-nonprod , OPS-APPROVAL-GATE-PROD-ENVS or OPS-APPROVAL-GATE-STG-ENVS to be provided:
    ![Alt text](/img/azureSubscription_variable.png?raw=true "Azure subscription")

    Resource groups list to provided:
    ![Alt text](/img/resource-groups-list.png?raw=true "Resource groups list")
