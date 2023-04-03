module "vpc100" {
  source = "../../modules/aws/vpc"
  vpc_name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc100"
  vpc_cidr = "10.100.0.0/16"
  public_subnet_cidr1  = "10.100.11.0/24"
  private_subnet_cidr1 = "10.100.12.0/24"
  public_subnet_cidr2  = "10.100.21.0/24"
  private_subnet_cidr2 = "10.100.22.0/24"
}

module "key_pair"{
  source         = "../../modules/aws/key-pair"
  ssh_key_name = "${lower(var.app_name)}-${lower(var.app_environment)}-key2"
}

module "ubuntu" {
  source = "../../modules/aws/ubuntu"
  instance_name = "${lower(var.app_name)}-${lower(var.app_environment)}-ubuntu1"
  subnet_id     = module.vpc100.public_subnet1_id
  vpc_id        = module.vpc100.vpc_id
  ssh_key_name  = module.key_pair.ssh_key_name
  user_data     = data.template_file.windows_user_data.rendered
}

# Bootstrapping PowerShell Script
data "template_file" "windows_user_data" {
  template = <<EOF
#!/bin/bash

sudo apt update -y
sudo apt install nginx -y

EOF
}


output "public_ip" {
  value = module.ubuntu.aws_instance.public_ip
}