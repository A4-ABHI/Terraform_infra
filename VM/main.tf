provider "azurerm" {
version = "2.12.0"
}
# Resource group

resource "azurerm_resource_group" "TEST" {
name = "RG01"
location = var.location

# Virtual Network

resource "azurerm_virtual_network" "TEST"{
name					= "$(var.prefix)-vnet"
address_space			= ["10.0.0.0/16"]
location				= var.location
resource_group_name		= azurerm_resource_group.TEST.name
}

# Sunet

resource "azurerm_subnet" "TEST"{
name					= "$(var.prefix)-subnet1"
resource_group_name		= azurerm_resource_group.TEST.name
virtual_network_name	= azurerm_virtual_network.TEST.name
address_prefix			= ["10.0.2.0/24"]
}

#Public IP

resource "azurerm_public_ip" "TEST"{
name					= "tstPIP"
resource_group_name		= azurerm_resource_group.TEST.name
location				= var.location
allocation_method		= "Static"
}

# NIC card

resource "azurerm_network_interface" "TEST"{
name					= "$(var.prefix)-NIC"
location				= var.location
resource_group_name		= azurerm_resource_group.TEST.name

ip_configuration {

name							= "internal"
subnet_id						= azurerm_subnet.TEST.id
private_ip_address_allocation	= "Dynamic"
public_ip_address_id			= azurerm_public_ip.TEST.id 
}
}


# Virtual Machine

resource "azurerm_virtual_machine" "TEST"{
name					= "$(var.prefix)-VM"
location				= var.location
resource_group_name		= azurerm_resource_group.TEST.name
network_interface_ids	= [azurerm_network_interface.TEST.id]
size					= "Standard_A1_V2"
admin_username			= var.username
admin_password			= var.password

os_disk{
 caching				= "ReadWrite"
 storage_account_type	= "Standard_LRS"
 }
 
 source_image_reference {
 
 publisher				= "MicrosoftWindowsServer"
 offer					= "WindowsServer"
 sku					= "2016-datacenter"
 version				= "latest"
 }
 

delete_os_disk_on_termination	= TRUE
delete_data_disk_on_termination	= TRUE

}






