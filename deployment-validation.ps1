Test-AzResourceGroupDeployment `
  -ResourceGroupName "rg-hpcuk-cluster" `
  -TemplateFile ".\hpc-cluster-template.json" `
  -TemplateParameterFile ".\hpc-cluster-params.json"
