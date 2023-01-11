terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.30.0"
    }
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = var.name
  location = var.location

}
resource "azurerm_virtual_network" "test" {
  name                = var.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "test3" {
  name                 = var.name
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]

}
resource "azurerm_network_interface" "test3" {
  name                = var.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "${var.name}-nic-ip-config"
    subnet_id                     = azurerm_subnet.test3.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test3.id

  }

}
resource "azurerm_public_ip" "test3" {
  name                = "${var.name}-public-ip"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "test3" {
  name                = "${var.name}-security-group"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_network_security_rule" "test3" {
  name                        = "${var.name}-security-rule"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test3.name
}
resource "azurerm_linux_virtual_machine" "test3" {
  name                            = var.name
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  network_interface_ids           = [azurerm_network_interface.test3.id]
  size                            = "Standard_B1s"
  computer_name                   = "mpssrvm"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  os_disk {
    name                 = "${var.name}-os-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  
  # provisioner "file" {
  #   source      = "files"
  #   destination = "/home/${var.username}/"
  #    connection {
  #     type     = "ssh"
  #     user     = "${var.username}"
  #     password = "${var.password}"
  #     host     = azurerm_public_ip.test3.ip_address
  #   }

 }
 

