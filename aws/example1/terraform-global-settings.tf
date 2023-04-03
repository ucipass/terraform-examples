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

variable "aws_profile" {
  type        = string
  description = "Application environment"
}

variable "aws_region" {
  type        = string
  description = "Application environment"
}

###################################
## AWS Provider Module & Variables
###################################

# AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
      # version = "3.57.0"
    }
  }
}

provider "aws" {
  profile    = var.aws_profile
  region     = var.aws_region
}

