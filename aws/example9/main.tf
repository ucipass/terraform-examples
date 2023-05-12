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


module "palo1" {
  source         = "../../modules/aws/palo"
  palo_name      = "${lower(var.app_name)}-${lower(var.app_environment)}-palo1"
  ssh_key_name   = var.ssh_key_name != "" ? var.ssh_key_name : module.key_pair.ssh_key_name
  vpc_id         = module.vpc100.vpc_id
  mgmt_subnet_id  = module.vpc100.public_subnet1_id
  ip_address_mgmt = ["10.100.11.21"]
  eth1_subnet_id  = module.vpc100.public_subnet1_id
  ip_address_eth1 = ["10.100.11.11","10.100.11.101","10.100.11.102"]
  eth2_subnet_id  = module.vpc100.private_subnet1_id
  ip_address_eth2 = ["10.100.12.11"]

  bootstrap_file  = "bootstrap-palo1.xml"
  initcfg_file    = "init-cfg.txt"
}


module "palo2" {
  source          = "../../modules/aws/palo"
  palo_name       = "${lower(var.app_name)}-${lower(var.app_environment)}-palo2"
  ssh_key_name    = var.ssh_key_name != "" ? var.ssh_key_name : module.key_pair.ssh_key_name
  vpc_id          = module.vpc100.vpc_id
  mgmt_subnet_id  = module.vpc100.public_subnet2_id
  ip_address_mgmt = ["10.100.21.21"]
  eth1_subnet_id  = module.vpc100.public_subnet2_id
  ip_address_eth1 = ["10.100.21.11", "10.100.21.101", "10.100.21.102"]
  eth2_subnet_id  = module.vpc100.private_subnet2_id
  ip_address_eth2 = ["10.100.22.11"]
  bootstrap_file  = "bootstrap-palo2.xml"
  initcfg_file    = "init-cfg.txt"
}

resource "aws_eip" "public_ip_ubuntu1" {
  vpc                       = true
  network_interface         = module.palo1.eth1_int_id
  associate_with_private_ip = "10.100.11.101"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-eip-ubuntu1"
  }
  depends_on = [
    module.palo1
  ]  
}

resource "aws_eip" "public_ip_ubuntu2" {
  vpc                       = true
  network_interface         = module.palo1.eth1_int_id
  associate_with_private_ip = "10.100.11.102"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-eip-ubuntu2"
  }
  depends_on = [
    module.palo1
  ]  
}

resource "aws_route" "local_def_route1" {
  route_table_id         = module.vpc100.private_route_table1_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = module.palo1.eth2_int_id
}

resource "aws_route" "local_def_route2" {
  route_table_id         = module.vpc100.private_route_table2_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id = module.palo1.eth2_int_id
}




module "ubuntu1" {
  source = "../../modules/aws/ubuntu"
  instance_name = "${lower(var.app_name)}-${lower(var.app_environment)}-ubuntu1"
  subnet_id     = module.vpc100.private_subnet1_id
  ip_address    = "10.100.12.100"
  vpc_id        = module.vpc100.vpc_id
  ssh_key_name  = var.ssh_key_name != "" ? var.ssh_key_name : module.key_pair.ssh_key_name
  user_data     = data.template_file.user_data1.rendered
}

module "ubuntu2" {
  source = "../../modules/aws/ubuntu"
  instance_name = "${lower(var.app_name)}-${lower(var.app_environment)}-ubuntu2"
  subnet_id     = module.vpc100.private_subnet2_id
  ip_address    = "10.100.22.100"
  vpc_id        = module.vpc100.vpc_id
  ssh_key_name  = var.ssh_key_name != "" ? var.ssh_key_name : module.key_pair.ssh_key_name
  user_data     = data.template_file.user_data2.rendered
}


data "template_file" "user_data1" {
  template = <<EOF
#!/bin/bash
while ! ping -c 1 google.com >/dev/null 2>&1; do sleep 15; done
sudo apt update -y
sudo apt install nodejs -y
sudo node -e "require('http').createServer((req,res)=>{res.end('My hostname is ${lower(var.app_name)}-${lower(var.app_environment)}-ubuntu1\nYour IP address is: '+req.socket.remoteAddress);}).listen(80,'0.0.0.0');"
EOF
}

data "template_file" "user_data2" {
  template = <<EOF
#!/bin/bash
while ! ping -c 1 google.com >/dev/null 2>&1; do sleep 15; done
sudo apt update -y
sudo apt install nodejs -y
sudo node -e "require('http').createServer((req,res)=>{res.end('My hostname is ${lower(var.app_name)}-${lower(var.app_environment)}-ubuntu2\nYour IP address is: '+req.socket.remoteAddress);}).listen(80,'0.0.0.0');"
EOF
}


output "palo1_mgmt_ip_public" {
  value=module.palo1.mgmt_ip_public

}

output "palo1_eth1_ip_public" {
  value=module.palo1.eth1_ip_public

}

output "palo2_mgmt_ip_public" {
  value=module.palo2.mgmt_ip_public

}

output "palo2_eth1_ip_public" {
  value=module.palo2.eth1_ip_public

}

output "ubuntu1_ip_public" {
  value=aws_eip.public_ip_ubuntu1.public_ip

}

output "ubuntu2_ip_public" {
  value=aws_eip.public_ip_ubuntu2.public_ip

}
