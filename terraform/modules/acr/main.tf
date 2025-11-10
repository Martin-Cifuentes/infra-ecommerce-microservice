resource "azurerm_container_registry" "this" {
  count               = var.create_acr ? 1 : 0
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
  tags                = var.tags
}