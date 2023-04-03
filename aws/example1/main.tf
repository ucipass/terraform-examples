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

module "win2019" {
  source = "../../modules/aws/win2019"
  instance_name = "${lower(var.app_name)}-${lower(var.app_environment)}-win2019"
  subnet_id     = module.vpc100.public_subnet1_id
  vpc_id        = module.vpc100.vpc_id
  ssh_key_name  = module.key_pair.ssh_key_name
  user_data     = data.template_file.windows_user_data.rendered
}

# Bootstrapping PowerShell Script
data "template_file" "windows_user_data" {
  template = <<EOF
<powershell>
# Rename Machine
Rename-Computer -NewName "${lower(var.app_name)}-${lower(var.app_environment)}-win2019" -Force;
# Install IIS
Install-WindowsFeature -name Web-Server -IncludeManagementTools;
# Restart machine
shutdown -r -t 10;
</powershell>
EOF
}


output "public_ip" {
  value = module.win2019.aws_instance.public_ip
}

output "password" {
  value = rsadecrypt(module.win2019.aws_instance.password_data, nonsensitive(module.key_pair.private_key_pem))
}

