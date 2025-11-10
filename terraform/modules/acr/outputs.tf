output "acr_id" {
  value       = var.create_acr ? azurerm_container_registry.this[0].id : null
}
output "login_server" {
  value       = var.create_acr ? azurerm_container_registry.this[0].login_server : null
}
output "admin_username" {
  value       = var.create_acr ? azurerm_container_registry.this[0].admin_username : null
  sensitive   = true
}
output "admin_password" {
  value       = var.create_acr ? azurerm_container_registry.this[0].admin_password : null
  sensitive   = true
}