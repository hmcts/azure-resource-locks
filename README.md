# azure-resource-locks
For maintaining azure resource lock configuration and automation

# Pipeline jobs
The enable resource locks pipeline jobs are scheduled to *run every 3 hours* for *AAT* and *Prod* environments. Each pipeline has been configured to use service connection(set as a pipeline variable) for the corresponding environments
* Enable-resource-locks-aat
* Enable-resource-locks-prod


The disable resource locks pipeline needs running manually by  specifying the corresponding service Connection (set as a pipeline variable) for the *AAT* and *Prod* environments
* Disable-resource-locks


# Locks applicable for specific Resource Types
Currently the resource locks are applied to *resource groups* which have the following resource types :- 
* Storage
* Key Vault
* SQL Databases
* APP Insights

The list could be extended by adding *|| contains(type, '<<*resource type*>>'))* in the *enable-resource-locking.sh* and *disable-resource-locking.sh* shell scripts under */scripts* folder