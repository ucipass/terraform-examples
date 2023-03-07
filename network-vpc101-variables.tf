##############################################
## Network Single AZ Public Only - Variables #
##############################################

# AWS AZ
#variable "aws_az" {
#  type        = string
#  description = "AWS AZ"
#  default     = "eu-west-1c"
#}

# VPC Variables
variable "vpc101_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.101.0.0/16"
}

# Subnet Variables
variable "vpc101_public_subnet_cidr1" {
  type        = string
  description = "CIDR for the public subnet"
  default     = "10.101.11.0/24"
}

# Subnet Variables
variable "vpc101_public_subnet_cidr2" {
  type        = string
  description = "CIDR for the public subnet"
  default     = "10.101.12.0/24"
}

# Subnet Variables
variable "vpc101_private_subnet_cidr1" {
  type        = string
  description = "CIDR for the public subnet"
  default     = "10.101.21.0/24"
}

# Subnet Variables
variable "vpc101_private_subnet_cidr2" {
  type        = string
  description = "CIDR for the public subnet"
  default     = "10.101.22.0/24"
}