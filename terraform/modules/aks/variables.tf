variable "name"                { type = string }
variable "location"            { type = string }
variable "resource_group_name" { type = string }

variable "node_count"          { type = number }
variable "min_node_count"      { type = number }
variable "max_node_count"      { type = number }
variable "vm_size"             { type = string }

variable "acr_id"              { type = string   default = null }

variable "aci_connector_linux" { type = bool     default = false }
variable "aci_subnet_name"     { type = string   default = null }

variable "tags"                { type = map(string) }