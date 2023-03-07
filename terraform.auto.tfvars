# "aws_access_key" will be provided via TF_VAR_aws_access_key
# "aws_secret_key" will be provided via TF_VAR_aws_secret_key


# Application Definition 
app_name        = "tgwdemo" # Do NOT enter any spaces
app_environment = "dev"       # Dev, Test, Staging, Prod, etc

# AWS Settings
aws_region     = "us-east-2"

## Linux Virtual Machine
#linux_instance_type               = "t2.micro"
#linux_associate_public_ip_address = true
#linux_root_volume_size            = 20
#linux_root_volume_type            = "gp2"
#linux_data_volume_size            = 10
#linux_data_volume_type            = "gp2"
