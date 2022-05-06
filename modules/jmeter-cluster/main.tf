resource "azurerm_resource_group" "jmeter" {
  name     = "jmeter-resources"
  location = var.location
}

resource "azurerm_virtual_network" "jmeter" {
  name                = "jmeter-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.jmeter.location
  resource_group_name = azurerm_resource_group.jmeter.name
}

resource "azurerm_subnet" "jmeter" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.jmeter.name
  virtual_network_name = azurerm_virtual_network.jmeter.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "static_ip" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.jmeter.name
  location            = azurerm_resource_group.jmeter.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "jmeter" {
  name                = "jmeter-nic"
  location            = azurerm_resource_group.jmeter.location
  resource_group_name = azurerm_resource_group.jmeter.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jmeter.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.static_ip.id
  }
}

resource "random_string" "random" {
  length  = 16
  special = false
}

resource "azurerm_linux_virtual_machine" "jmeter" {
  name                = "jmeter-machine"
  resource_group_name = azurerm_resource_group.jmeter.name
  location            = azurerm_resource_group.jmeter.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.jmeter.id,
  ]
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_virtual_machine_extension" "jmeter-apt-get" {
  depends_on           = [azurerm_linux_virtual_machine.jmeter]
  name                 = "${random_string.random.result}-vm-extension"
  virtual_machine_id   = azurerm_linux_virtual_machine.jmeter.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  protected_settings   = <<PROTECTED_SETTINGS
      {
          "script": "${base64encode(file("${path.module}/install-jmeter.sh"))}"
      }
      PROTECTED_SETTINGS
}

resource "azurerm_network_security_group" "jmeter" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.jmeter.location
  resource_group_name = azurerm_resource_group.jmeter.name
}

resource "azurerm_network_security_rule" "SSH" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.jmeter.name
  network_security_group_name = azurerm_network_security_group.jmeter.name
}

resource "azurerm_subnet_network_security_group_association" "jmeter" {
  subnet_id                 = azurerm_subnet.jmeter.id
  network_security_group_id = azurerm_network_security_group.jmeter.id
}


# provisioner "file" {
#   source      = "conf/myapp.conf"
#   destination = "/etc/myapp.conf"
#   connection {
#     type     = "ssh"
#     user     = "root"
#     password = var.root_password
#     host     = var.host
#   }
# }
