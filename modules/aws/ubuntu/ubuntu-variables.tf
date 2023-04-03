variable "instance_name" {
  description = "instance name used for taggin and naming purposes"
  type = string
}

variable "subnet_id" {
  description = "subnet_id"
  type = string
}

variable "vpc_id" {
  description = "vpc_id"
  type = string
}

variable "ssh_key_name" {
  description = "ssh_key_name"
  type = string
}

variable "instance_type" {
  description = "instance_type"
  type = string
  default = "t2.micro"
}

variable "user_data" {
  description = "ssh_key_name"
  type = string
  default = ""
}
