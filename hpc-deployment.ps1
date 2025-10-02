# az login
az account set -s "da883fd8-76c8-4ca5-a7e6-8567ae83ce10"

# Deploy cluster inside a pre-existing resource group
# az group create -l uksouth -n rg-hpcuk-cluster

az deployment group create `
    --name hpc-2019-cluster-deployment `
    --resource-group rg-hpcuk-cluster `
    --template-file .\hpc-cluster-template.json `
    --parameters .\hpc-cluster-params.json