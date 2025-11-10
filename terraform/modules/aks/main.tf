resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.name}-dns"

  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = var.vm_size
    enable_auto_scaling = true
    min_count           = var.min_node_count
    max_count           = var.max_node_count
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "aci_connector_linux" {
    for_each = var.aci_connector_linux == true ? [1] : []
    content {
      subnet_name = var.aci_subnet_name
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "azure"
  }

  tags = var.tags
}

# Role assignment only if ACR id provided
resource "azurerm_role_assignment" "acr_pull" {
  count                = var.acr_id != null ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = var.acr_id
}