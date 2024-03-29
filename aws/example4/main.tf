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
  source          = "../../modules/aws/palo"
  palo_name       = "${lower(var.app_name)}-${lower(var.app_environment)}-palo1"
  ssh_key_name    = var.ssh_key_name != "" ? var.ssh_key_name : module.key_pair.ssh_key_name
  vpc_id          = module.vpc100.vpc_id
  mgmt_subnet_id  = module.vpc100.public_subnet2_id
  ip_address_mgmt = "10.100.21.12"
  eth1_subnet_id  = module.vpc100.public_subnet2_id
  ip_address_eth1 = "10.100.21.11"
  eth2_subnet_id  = module.vpc100.private_subnet2_id
  ip_address_eth2 = "10.100.22.11"
  bootstrap_file  = "/home/aarato/github/terraform-examples/bootstrap.xml"
  initcfg_file    = "/home/aarato/github/terraform-examples/init-cfg.txt"
}

output "mgmt_ip_public" {
  value=module.palo1.mgmt_ip_public

}

output "eth1_ip_public" {
  value=module.palo1.eth1_ip_public

}