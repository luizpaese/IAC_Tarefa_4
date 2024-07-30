variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Local onde o grupo de recursos sera criado"
}

variable "resource_tags" {
  type        = map(string)
  default     = {
    "Cost-center" = "C1234"
    "Environment" = "PRODUCTION"
    "AssetID"     = "1234"
    "Owner"       = "owner@student.com"
    "Service"     = "Tarefa 4"
  }
}

variable "resource_group_name" {
  type        = string
  default     = "student-rg"
  description = "Nome do Resource Group"
}

variable "vnet_name" {
  type        = string
  default     = "student-vnet"
  description = "Nome da Virtual Network"
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "Espaço de IPs para a Virtual Network"
}

variable "snet_name" {
  type        = string
  default     = "student-subnet"
  description = "Nome da Subnet"
}

variable "snet_address_prefixes" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "Espaço de IPs para a Subnet"
}

variable "pip_name" {
  type        = string
  default     = "student-pip"
  description = "Nome do Public IP"
}

variable "pip_count" {
  type        = number
  default     = 1
  description = "Quantidade de Public IPs"
}

variable "nsg_name" {
  type        = string
  default     = "student-nsg"
  description = "Nome do Network Security Group"
}

variable "nic_name" {
  type        = string
  default     = "student-nic"
  description = "Nome da Network Interface Card"
}

variable "vm_name" {
  type        = string
  default     = "student-vm"
  description = "Nome da Virtual Machine"
}

variable "vm_count" {
  type        = number
  default     = 1
  description = "Quantidade de VMs"
}

variable "vm_size" {
  type        = string
  description = "Tipo de VM"
  default     = "Standard_B1s"
}

variable "vm_username" {
  type        = string
  description = "O usuario que sera usado para nos conectarmos nas VMs"
  default     = "azureuser"
}

variable "vm_admin_password" {
  type        = string
  description = "O usuario que sera usado para nos conectarmos nas VMs. Setado com 'TF_VAR_vm_admin_password=senha'"
}
