resource_group_name = "ecom-rg-dev"
location            = "eastus2"
environment         = "dev"

aks_cluster_name = "ecom-aks-dev"
node_count       = 2
min_node_count   = 1
max_node_count   = 5
vm_size          = "Standard_D2s_v3"

create_acr = true
acr_name   = "ecomacrdev1234"   # Debe ser globalmente único