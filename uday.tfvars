# Azure variables
azure_location = "West US"

# Project variables
project = "persostack"
env     = "dev"

# Resource group variables
create_bastion_server = true
create_docker_server = true
create_devops_server = true
resource_group_name   = "cmp-uw-rg-d" # Ideally, should be different between environments
resource_storage_name = "persostackdevstorage"

public_subnet_name =  "cmppublic-uw-sn-d"
private_subnet_name = "cmprivate-uw-sn-d"
vnet_name = "customermarketingperso-uw-vnet-d"
vnet_resource_group_name = "cmpvnet-uw-rg-d"

# Virtual network variables
vnet_cidr_block           = "10.241.148.0/22"
public_subnet_cidr_block  = "10.241.148.0/25"
private_subnet_cidr_block = "10.241.148.128/25"
whitelist_cidr_blocks = [
    "69.162.0.12/32",
    "139.180.244.246/32",
    "70.165.164.230/32"
]

# VM SSH variables
admin_username = "ubuntu"

# Bastion VM variables
bastion_vm_os_sku = "20_04-lts-gen2"
bastion_vm_size = "Standard_E8s_v3"
bastion_vm_os_disk_size_gb = 128
bastion_vm_disk_size_gb = 128

# Docker server VM variables
docker_server_vm_os_sku = "20_04-lts-gen2"
docker_server_vm_size = "Standard_E8s_v3"
docker_server_vm_os_disk_size_gb = 256
docker_server_vm_disk_size_gb = 512
docker_server_vm_user_assigned_identity_id = ""

# DevOps server VM variables
devops_server_vm_os_sku = "20_04-lts-gen2"
devops_server_vm_size = "Standard_E8s_v3"
devops_server_vm_os_disk_size_gb = 256
devops_server_vm_disk_size_gb = 512
devops_server_vm_user_assigned_identity_id = ""
