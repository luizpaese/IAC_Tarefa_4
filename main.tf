locals {
  resources_prefix = "student"
}

# Cria resource group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
  tags     = var.resource_tags
}

# Cria vnet
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags
  depends_on          = [azurerm_resource_group.rg]
}

# Cria subnets
resource "azurerm_subnet" "subnet" {
  name                 = var.snet_name
  address_prefixes     = var.snet_address_prefixes
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  depends_on           = [azurerm_virtual_network.vnet]
}

# Cria IPs publicos
resource "azurerm_public_ip" "public_ips" {
  count               = var.pip_count
  name                = var.pip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  tags                = var.resource_tags
  depends_on          = [azurerm_subnet.subnet]
}

# Cria SG e uma regra de SSH
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Cria NIC
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = var.nic_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.resource_tags
  depends_on          = [azurerm_subnet.subnet]

  ip_configuration {
    name                          = "${var.nic_name}_configuration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ips[count.index].id
  }
}

# Conecta SG com NIC
resource "azurerm_network_interface_security_group_association" "nic-nsg-association" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on                = [azurerm_subnet.subnet, azurerm_network_interface.nic]
}


# Cria a maquina virtual
resource "azurerm_linux_virtual_machine" "vm" {
  count                 = var.vm_count
  name                  = var.vm_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  size                  = var.vm_size
  tags                  = var.resource_tags
  depends_on            = [azurerm_network_interface.nic]

  os_disk {
    name                 = "${local.resources_prefix}-os-disk-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = var.vm_name
  admin_username                  = var.vm_username
  admin_password                  = var.vm_admin_password
  disable_password_authentication = false

}

# Gerar um inventario das VMs
resource "local_file" "hosts_cfg" {
  content = templatefile("inventory.tpl",
    {
      vms      = azurerm_linux_virtual_machine.vm
      username = var.vm_username
    }
  )
  filename = "./ansible/inventory.ini"
}

