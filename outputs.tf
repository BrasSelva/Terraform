output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "container_name" {
  value = azurerm_storage_container.static_files.name
}

output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "flask_app_url" {
  description = "URL de l'application Flask"
  value       = "http://${azurerm_public_ip.public_ip.ip_address}:${var.flask_port}/"
}
