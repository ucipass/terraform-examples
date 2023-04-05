####################################
## Application Module - Variables ##
####################################

# Application definition

variable "app_name" {
  type        = string
  description = "Application name"
}

variable "app_environment" {
  type        = string
  description = "Application environment"
}

variable "ssh_key_name" {
  type        = string
  description = "Application environment"
}


#####################################
## Azure Provider Module & Variables
#####################################

provider "azurerm" {
  features {}
}

