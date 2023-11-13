# Introduction
This repository contains `terraform` code to deploy Databricks workspace for training purpose in Azure.

## Resources to be created by this script
1. Microsoft Entra ID Users and Groups (region-agnostic)
    - Instructors
    - Students
1. Azure Storage Account for Databricks Unity Catalog (region-specific)
    - **Important!** One Azure region can only setup one Databricks Unity Catalog. If you want to reuse the existing Databricks Unity Catalog, then change the `terraform` code accordingly.
1. Azure Databricks Workspace (region-specific)
1. Azure Databricks Clusters
    - Instructors' Clusters
        - Data Engineering
        - Machine Learning
    - Students' Clusters
        - Data Engineering
        - Machine Learning
1. Azure Databricks Training Materials ((c) Databricks)

## Required Azure resources and accesses
1. Azure `Service Principal` with access granted below.
    - `Domain.Read.All`
    - `Group.ReadWrite.All`
    - `User.ReadWrite.All`
1. Azure `Subscription` with resource provider registered below.
    - `Microsoft.Compute`
    - `Microsoft.Databricks`
    - `Microsoft.ManagedIdentity`
    - `Microsoft.Storage`
1. The Azure `Service Principal` from step 2 has access to manage resources in Azure `Subscription` from step 3.
1. Databricks account on Azure (can be found with link [here](https://accounts.azuredatabricks.net/)), which is already created by following [this documentation](https://learn.microsoft.com/en-us/azure/databricks/administration-guide/#--establish-your-first-account-admin).
1. Databricks Group `Databricks Unity Catalog Administrators` (this is created separately from this project).
1. Azure `Service Principal` have been added to Databricks Account.

## Preparing `secrets.tfvars` for deploying with Service Principal
```tfvars
region = "<Azure region>"
tenant_id = "<Azure tenant ID>"
subscription_id = "<Azure subscription ID that contains all resources>"
client_id = "<Azure client (app) ID>"
client_secret = "<Azure client (app) secret>"
databricks_account_id = "<Azure Databricks account ID>"
```

# Deployment Steps
1. Install Azure CLI `az` & `terraform`
1. Login Azure CLI, run `az login --service-principal -u <app-id> -p <password-or-cert> --tenant <tenant-id>`
1. `cd` to the correct sub-folder first, e.g. `cd ./20231101`
1. Install terraform providers, run `terraform init`
1. Check and see if there is anything wrong, run `terraform plan -var-file='<file>.tfvars' -out='<file>.out'`
1. Deploy the infra, run `terraform apply '<file>.out'`
1. To remove the whole deployment, run `terraform plan -destroy -var-file='<file>.tfvars' -out='<file-destroy>.out'` and then `terraform apply '<file-destroy>.out'`

## Caveats
In region `eastasia`, there is an issue to create Unity Catalog directly with `terraform`, thus requires manual creation in [Databricks Account page](https://accounts.azuredatabricks.net/data), and then `terraform import -var-file='<file>.tfvars' module.databricks.databricks_metastore.this '<metastore_id>'`

# Databricks users
The user list can be modified to suit your needs, e.g. number of users required.
As this repository is served for creating training workspace, therefore the users are divided into 2 groups, `Instructors` and `Students`.
The example format of the users are
`student01.databricks.<training-date-yyyyMMdd>@<your Azure domain>`

# Reference
Pre-requisite steps documents are listed in the links below.

## Links
- [Azure Databricks administration introduction - Azure Databricks | Microsoft Learn](https://learn.microsoft.com/en-us/azure/databricks/administration-guide/)
- [Provision a service principal for Azure Databricks automation - Terraform - Azure Databricks | Microsoft Learn](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/service-principals-tools-apis)
- [Databricks Terraform provider - Azure Databricks | Microsoft Learn](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/terraform/)
- [Deploy an Azure Databricks workspace using Terraform - Azure Databricks | Microsoft Learn](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/terraform/azure-workspace)
- [Docs overview | databricks/databricks | Terraform | Terraform Registry](https://registry.terraform.io/providers/databricks/databricks/latest/docs)

## Terraform Providers
- `hashicorp/azuread`
- `hashicorp/azurerm`
- `databricks/databricks`
