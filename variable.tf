##
## Azure variables
variable "azure_location" {
  type        = string
  description = "The Azure location to deploy into (e.g. West US)."
}

##
## Project variables
variable "project" {
  type        = string
  description = "The name of the project (used as a prefix for naming resources)"
}

variable "env" {
  type        = string
  description = "The name of the env (used as a prefix for naming resources)"
}

##
## Azure resource group variables
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to create or use"
}

variable "resource_storage_name" {
  type        = string
  description = "Name of the resource group to create or use"
}

##
## Virtual network variables
variable "vnet_cidr_block" {
  type        = string
  description = "CIDR block to use for the virtual network (e.g. 10.0.0.0/16)"
}

variable "public_subnet_cidr_block" {
  type        = string
  description = "CIDR block for the public subnet"
}

variable "public_subnet_service_endpoints" {
  type        = list(string)
  description = "The list of Service endpoints to associate with the public subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql and Microsoft.Storage."
  default     = []
}

variable "private_subnet_cidr_block" {
  type        = string
  description = "CIDR block for the private subnet (containing the airflow server)"
}

variable "private_subnet_service_endpoints" {
  type        = list(string)
  description = "The list of Service endpoints to associate with the private subnet. Possible values include: Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql and Microsoft.Storage."
  default     = ["Microsoft.Storage"]
}

variable "whitelist_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks to whitelist"
  default     = ["0.0.0.0/0"]
}

variable "public_subnet_name" {
  type        = string
  description = "Public subnet name"
}

variable "private_subnet_name" {
  type        = string
  description = "Private subnet name"
}

variable "vnet_name" {
  type        = string
  description = "Virtual Network Name"
}

variable "vnet_resource_group_name" {
  type        = string
  description = "Virtual Network Resource Group name"
}


##
## VM SSH variables
variable "admin_username" {
  type        = string
  description = "Name of the admin user to create and associate SSH access with variable `admin_user_pub_key_path`"
  default     = "ubuntu"
}

variable "ssh_public_key_name" {
  type        = string
  description = "Name of the ssh key need to be read from azure which is used in VM configuration"
  default     = "persostack_dev"
}

variable "user" {
  type        = string
  description = "Name of the user"
  default     = "testuser"
}


variable "databricks_instance_url" {
  type        = string
  description = "Name of the databricks instance url"
  default     = "https://adb-3835854084621288.8.azuredatabricks.net/"
}

##
## what VMs needed
variable "create_docker_server" {
  type        = bool
  description = "Whether to create a docker server or skip"
  default     = false
}

variable "create_bastion_server" {
  type        = bool
  description = "Whether to create a bastion server or skip"
  default     = false
}

variable "create_devops_server" {
  type        = bool
  description = "Whether to create a devops server or skip"
  default     = false
}

##
## Bastion VM variables

variable "bastion_vm_os_publisher" {
  type        = string
  description = "OS publisher for the VM (currently assuming Ubuntu)"
  default     = "Canonical"
}

variable "bastion_vm_os_offer" {
  type        = string
  description = "OS offerfor the VM (currently assuming Ubuntu)"
  default     = "0001-com-ubuntu-server-focal"
}

variable "bastion_vm_os_sku" {
  type        = string
  description = "OS SKU for the VM (currently assuming Ubuntu)"
  default     = "18.04-LTS"
}

variable "bastion_vm_size" {
  type        = string
  description = "Instance size of the bastion VM"
  default     = "Standard_DS2_v2"
}

variable "bastion_vm_os_disk_size_gb" {
  type        = number
  description = "Size (GB) of the boot disk on the bastion"
  default     = 128
}

variable "bastion_vm_disk_size_gb" {
  type        = number
  description = "Size (GB) of the boot disk on the bastion"
  default     = 128
}

##
## Docker server variables

variable "docker_server_vm_os_publisher" {
  type        = string
  description = "OS publisher for the VM (currently assuming Ubuntu)"
  default     = "Canonical"
}

variable "docker_server_vm_os_offer" {
  type        = string
  description = "OS offerfor the VM (currently assuming Ubuntu)"
  default     = "0001-com-ubuntu-server-focal"
}

variable "docker_server_vm_os_sku" {
  type        = string
  description = "OS SKU for the VM (currently assuming Ubuntu)"
  default     = "18.04-LTS"
}

variable "docker_server_vm_size" {
  type        = string
  description = "Instance size of the docker server VM"
  default     = "Standard_DS2_v2"
}

variable "docker_server_vm_disk_size_gb" {
  type        = number
  description = "Size (GB) of the boot disk on the docker server VM"
  default     = 256
}

variable "docker_server_vm_os_disk_size_gb" {
  type        = number
  description = "Size (GB) of the boot disk on the devops server VM"
  default     = 256
}

variable "docker_server_vm_user_assigned_identity_id" {
  type        = string
  description = "ID of the user assigned identity to assign to the docker server VM"
  default     = ""
}

##
## DevOps server variables

variable "devops_server_vm_os_publisher" {
  type        = string
  description = "OS publisher for the VM (currently assuming Ubuntu)"
  default     = "Canonical"
}

variable "devops_server_vm_os_offer" {
  type        = string
  description = "OS offerfor the VM (currently assuming Ubuntu)"
  default     = "0001-com-ubuntu-server-focal"
}

variable "devops_server_vm_os_sku" {
  type        = string
  description = "OS SKU for the VM (currently assuming Ubuntu)"
  default     = "18.04-LTS"
}

variable "devops_server_vm_size" {
  type        = string
  description = "Instance size of the devops server VM"
  default     = "Standard_DS2_v2"
}

variable "devops_server_vm_disk_size_gb" {
  type        = number
  description = "Size (GB) of the boot disk on the devops server VM"
  default     = 256
}

variable "devops_server_vm_os_disk_size_gb" {
  type        = number
  description = "Size (GB) of the boot disk on the devops server VM"
  default     = 256
}


variable "devops_server_vm_user_assigned_identity_id" {
  type        = string
  description = "ID of the user assigned identity to assign to the devops server VM"
  default     = ""
}
