############################################
## Transit Gateway and Attachments        ##
############################################

variable "tgw_name" {
  description = "Unique name of the TGW instances."
  type        = string
  default     = "terraform_tgw1"
}

variable "vpc_ids" {
  description = "List of VPC Ids routed by TGW"
  type        = list
}

variable "subnet_ids" {
  description = "List of Subnet Ids for each VPC association by TGW"
  type        = list
}
