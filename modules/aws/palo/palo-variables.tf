# Palo Alto Variables
variable "palo_name" {
  description = "Unique name of the Palo Alto instances."
  type        = string
  default     = "palo1"
}

variable "bootstrap_file" {
  description = "Bootstrap file of the Palo Alto instances."
  type        = string
}

variable "initcfg_file" {
  description = "Init.cfg file of the Palo Alto instances."
  type        = string
}

variable "vpc_id" {
  description = "VPC id of the Palo Alto instances."
  type        = string
}

variable "mgmt_subnet_id" {
  description = "Subnet id for the Palo Alto management interface."
  type        = string
}

variable "ip_address_mgmt" {
  description = "IP address of management interface."
  type        = list
  default     = []
}

variable "eth1_subnet_id" {
  description = "Subnet id for the Palo Alto eth1 interface."
  type        = string
}

variable "ip_address_eth1" {
  description = "IP address of eth1 interface."
  type        = list
  default     = []
}


variable "eth2_subnet_id" {
  description = "Subnet id for the Palo Alto eth2 interface."
  type        = string
}

variable "ip_address_eth2" {
  description = "IP address of eth2 interface."
  type        = list
  default     = []
}


variable "ssh_key_name" {
  description = "Name of AWS keypair to associate with instances."
  type        = string
  # Value is coming from tfvars
}

variable "instance_type" {
  description = "EC2 instance type."
  default     = "m5.2xlarge"
  type        = string
}

resource "random_uuid" "s3postfix" {
}
