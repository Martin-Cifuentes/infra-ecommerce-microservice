output "name"       { value = azurerm_kubernetes_cluster.this.name }
output "id"         { value = azurerm_kubernetes_cluster.this.id }
output "kubeconfig" { value = azurerm_kubernetes_cluster.this.kube_config_raw sensitive = true }
output "fqdn"       { value = azurerm_kubernetes_cluster.this.fqdn }