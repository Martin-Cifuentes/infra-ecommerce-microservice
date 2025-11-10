resource_group_name = "ecom-rg-prod"
location            = "eastus2"
environment         = "prod"

aks_cluster_name = "ecom-aks-prod"
node_count       = 2
min_node_count   = 1
max_node_count   = 5
vm_size          = "Standard_D2s_v3"

create_acr = true
acr_name   = "ecomacrprod1234"   # Debe ser globalmente único