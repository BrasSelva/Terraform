# Groupe de ressources
resource "azurerm_resource_group" "rg" {
  name     = "rg-flask-tf2"
  location = var.location
}

# ID random pour suffixe du nom de stockage
resource "random_id" "storage_suffix" {
  byte_length = 4
}

# Compte de stockage Azure
resource "azurerm_storage_account" "storage" {
  name                     = "${var.storage_account_prefix}${random_id.storage_suffix.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Conteneur de stockage pour les fichiers statiques
resource "azurerm_storage_container" "static_files" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}
# Réseau virtuel (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "flask-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Sous-réseau (Subnet)
resource "azurerm_subnet" "subnet" {
  name                 = "flask-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# IP publique dynamique
resource "azurerm_public_ip" "public_ip" {
  name                = "flask-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"  # Changement de dynamique à statique
  sku                  = "Standard"  # Spécifie le SKU Standard
}
# Interface réseau (NIC)
resource "azurerm_network_interface" "nic" {
  name                = "flask-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Machine virtuelle Ubuntu avec Flask
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "flask-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1ms"
  admin_username      = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")  # Remplace par le chemin vers ta clé publique
  }
  disable_password_authentication = true  # Désactive l'authentification par mot de passe
network_interface_ids           = [azurerm_network_interface.nic.id]
  tags = {
    environment = "Terraform"
  }

  # Définition du disque principal (os_disk)
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Définition de l'image source pour la VM
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # Pour la personnalisation de la VM, ajout du cloud-init
  custom_data = base64encode(file("cloud-init-flask.yaml"))
}
resource "azurerm_network_security_group" "flask_nsg" {
  name                = "flask-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    direction                  = "Inbound"
    priority                  = 1000
    access                    = "Allow"
    protocol                  = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "22"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    direction                  = "Inbound"
    priority                  = 1001
    access                    = "Allow"
    protocol                  = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "80"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.flask_nsg.id
}
