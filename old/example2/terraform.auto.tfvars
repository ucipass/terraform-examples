# Application Definition 
app_name        = "example2" # Do NOT enter any spaces
app_environment = "dev"       # Dev, Test, Staging, Prod, etc

# AWS Settings
aws_region     = "us-east-2"
# aws_access_key = will be provided via TF_VAR_aws_access_key environment variable
# aws_secret_key = will be provided via TF_VAR_aws_secret_key environment variable
# export TF_VAR_aws_access_key=
# export TF_VAR_aws_access_key=

# SSH Key
ssh_key_name   = "AA"


## Linux Virtual Machine
#linux_instance_type               = "t2.micro"
#linux_associate_public_ip_address = true
#linux_root_volume_size            = 20
#linux_root_volume_type            = "gp2"
#linux_data_volume_size            = 10
#linux_data_volume_type            = "gp2"
