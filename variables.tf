variable "resource_group_name" {
  type    = string
  default = "rg-flask-tf"
}
variable "container_name" {
  description = "Nom du conteneur de stockage pour les fichiers statiques"
  type        = string
  default     = "staticfiles"
}

variable "location" {
  default = "East US"
}

variable "vm_admin_username" {
  default = "azureuser"
}

variable "vm_admin_password" {
  description = "Password for the VM"
  sensitive   = true
}

variable "vm_name" {
  default = "flask-vm"
}

variable "storage_account_prefix" {
  default = "flaskstorage"
}

variable "flask_port" {
  description = "Port sur lequel l'application Flask écoute"
  type        = number
  default     = 5000
}

variable "connection_string" {
  description = "Azure Storage Connection String"
  sensitive = true
}
