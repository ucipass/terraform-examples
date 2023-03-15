module "tempkey"{
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

module "c8000v-1" {
  source = "../modules/c8000v"
  vpc_id = module.vpc100.vpc_id
  instance_name = "${lower(var.app_name)}-${lower(var.app_environment)}-c8000v-1"
  subnet_id1     = module.vpc100.public_subnet1_id
  subnet_id2     = module.vpc100.private_subnet1_id
  ip_address_gi1 = "10.100.11.11"
  ip_address_gi2 = "10.100.12.11"
  ssh_key_name   = module.tempkey.ssh_key_name
}

output "c8000v_public_ip" {
  value=module.c8000v-1.public_ip
}