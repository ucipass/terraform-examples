
module "key-pair"{
  source         = "../modules/key-pair"
  ssh_key_name = "${lower(var.app_name)}-${lower(var.app_environment)}-key"
}

module "vpc100" {
  source = "../modules/vpc-2public-2private"
  vpc_name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc100"
  vpc_cidr = "10.100.0.0/16"
  public_subnet_cidr1  = "10.100.11.0/24"
  private_subnet_cidr1 = "10.100.12.0/24"
  public_subnet_cidr2  = "10.100.21.0/24"
  private_subnet_cidr2 = "10.100.22.0/24"
}

# module "tgw" {
#   source     = "../modules/tgw"
#   vpc_ids    = [module.vpc100.vpc_id,module.vpc101.vpc_id]
#   subnet_ids = [    
#     [module.vpc100.private_subnet1_id,module.vpc100.private_subnet2_id],    
#     [module.vpc101.private_subnet1_id,module.vpc101.private_subnet2_id]  
#   ]
# }


module "palo1" {
  source         = "../modules/palo"
  palo_name      = "${lower(var.app_name)}-${lower(var.app_environment)}-palo1"
  ssh_key_name   = module.key-pair.ssh_key_name
  vpc_id         = module.vpc100.vpc_id
  mgmt_subnet_id = module.vpc100.public_subnet2_id
  eth1_subnet_id = module.vpc100.public_subnet2_id
  eth2_subnet_id = module.vpc100.private_subnet2_id
  bootstrap_file = "/home/aarato/github/terraform-examples/bootstrap.xml"
  initcfg_file = "/home/aarato/github/terraform-examples/init-cfg.txt"
}

