variable "instance_name" {
  type = string
}

variable "instance_type" {
  type = string
  default = "c5n.large"
}

variable "ssh_key_name" {
  description = "ssh_key_name"
  type = string
}

variable "vpc_id" {
  description = "vpc_id"
  type = string
}

variable "subnet_id1" {
  type = string
}

variable "ip_address_gi1" {
  type = string
}

variable "subnet_id2" {
  type = string
}

variable "ip_address_gi2" {
  type = string
}

data "aws_ami" "csr1kv" {
  most_recent = true
  owners = ["aws-marketplace"] 

  filter {
    name = "name"
    values = ["Cisco-C8K-17.06.04*"]
  }
  filter {
    name = "product-code"
    values = ["3ycwqehancx46bkpb3xkifiz5"]
  }
  
  # example: aws ec2 describe-images --filters "Name=product-code,Values=3ycwqehancx46bkpb3xkifiz5" Name=name,Values=Cisco-C8K-17.06.04*   --region us-east-2 --output json
}

