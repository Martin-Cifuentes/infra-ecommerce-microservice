resource_group_name = "ecom-rg-stage"
location            = "eastus2"
environment         = "stage"

aks_cluster_name = "ecom-aks-stage"
node_count       = 2
min_node_count   = 1
max_node_count   = 5
vm_size          = "Standard_D2s_v3"

create_acr = true
acr_name   = "ecomacrstage1234"   # Debe ser globalmente único