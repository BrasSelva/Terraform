variable "resource_group_name" {
  type    = string
  default = "rg-flask-tf"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "storage_account_prefix" {
  type    = string
  default = "flaskstor"
}

variable "container_name" {
  type    = string
  default = "staticfiles"
}
