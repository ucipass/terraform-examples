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

module "ubuntu1" {
  source = "../modules/ubuntu"
  instance_name = "${lower(var.app_name)}-${lower(var.app_environment)}-ubuntu1"
  subnet_id     = module.vpc100.public_subnet1_id
  vpc_id        = module.vpc100.vpc_id
  ssh_key_name  = module.tempkey.ssh_key_name
}
