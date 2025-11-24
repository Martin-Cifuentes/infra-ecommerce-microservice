variable "resource_group_name" {
  description = "Name of the Azure Resource Group where all resources will be deployed."
  type        = string
  default     = "ecommerce-microservices-rg"
  validation {
    condition     = length(var.resource_group_name) > 2
    error_message = "Resource group name must be at least 3 characters."
  }
}

variable "location" {
  description = "Azure region where resources will be created. Example: eastus, westeurope."
  type        = string
  default     = "eastus"
  validation {
    condition     = can(regex("^[a-z]+[a-z0-9]*$", var.location))
    error_message = "Location must be a valid Azure region name (lowercase, no spaces)."
  }
}

variable "environment" {
  description = "Environment name (dev, stage, prod)."
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be one of: dev, stage, prod."
  }
}

variable "aks_cluster_name" {
  description = "Name of the Azure Kubernetes Service (AKS) cluster."
  type        = string
  default     = "ecommerce-aks-cluster"
  validation {
    condition     = length(var.aks_cluster_name) > 2
    error_message = "AKS cluster name must be at least 3 characters."
  }
}

variable "node_count" {
  description = "Initial number of nodes in the AKS cluster."
  type        = number
  default     = 2
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "Node count must be between 1 and 10."
  }
}

variable "min_node_count" {
  description = "Minimum number of nodes for AKS auto-scaling."
  type        = number
  default     = 1
  validation {
    condition     = var.min_node_count >= 1
    error_message = "Minimum node count must be at least 1."
  }
}

variable "max_node_count" {
  description = "Maximum number of nodes for AKS auto-scaling."
  type        = number
  default     = 5
  validation {
    condition     = var.max_node_count >= var.min_node_count
    error_message = "Maximum node count must be greater than or equal to minimum node count."
  }
}

variable "vm_size" {
  description = "Size of the VMs in the AKS node pool. Example: Standard_D2s_v3."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "create_acr" {
  description = "Whether to create an Azure Container Registry (ACR). If false, Docker Hub will be used."
  type        = bool
  default     = false
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique)."
  type        = string
  default     = "ecommerceacr"
  validation {
    condition     = length(var.acr_name) > 2
    error_message = "ACR name must be at least 3 characters."
  }
}
