###################################
## Virtual Machine Module - Main ##
###################################

# Bootstrapping PowerShell Script

# data "template_file" "windows-userdata" {
#   template = <<EOF
# <powershell>
# # Rename Machine
# Rename-Computer -NewName "${var.windows_instance_name}" -Force;
# # Install IIS
# Install-WindowsFeature -name Web-Server -IncludeManagementTools;
# # Restart machine
# shutdown -r -t 10;
# </powershell>
# EOF
# }

# user_data                   = data.template_file.windows-userdata.rendered


# Create EC2 Instance
resource "aws_instance" "windows-server" {
  ami                         = data.aws_ami.windows-2019.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.aws-windows-sg.id]
  associate_public_ip_address = var.associate_public_ip_address
  source_dest_check           = false
  key_name                    = var.ssh_key_name
  # user_data                   = data.template_file.windows-userdata.rendered
  user_data                   = var.user_data
  get_password_data           = true

  # root disk
  root_block_device {
    volume_size           = var.windows_root_volume_size
    volume_type           = var.windows_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }

  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.windows_data_volume_size
    volume_type           = var.windows_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }
  
  tags = {
    Name = "${lower(var.instance_name)}"
  }
}

# Create Elastic IP for the EC2 instance
resource "aws_eip" "windows-eip" {
  vpc  = true
  tags = {
    Name        = "${lower(var.instance_name)}-eip"

  }
}

# Associate Elastic IP to Windows Server
resource "aws_eip_association" "windows-eip-association" {
  instance_id   = aws_instance.windows-server.id
  allocation_id = aws_eip.windows-eip.id
}

# Define the security group for the Windows server
resource "aws_security_group" "aws-windows-sg" {
  name        = "${lower(var.instance_name)}-sg"
  description = "Allow incoming connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming RDP connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${lower(var.instance_name)}-sg"

  }
}