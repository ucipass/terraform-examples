data "aws_ami" "this" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["PA-VM-AWS-10.2.2-h2*"]
  }
  filter {
    name   = "product-code"
    values = ["6njl1pau431dv1qxipg63mvah"]
    # https://docs.paloaltonetworks.com/vm-series/10-2/vm-series-deployment/set-up-the-vm-series-firewall-on-aws/deploy-the-vm-series-firewall-on-aws/obtain-the-ami/get-amazon-machine-image-ids
  }
}


# Create PA VM-series instances
resource "aws_instance" "palo" {

  ami                                  = data.aws_ami.this.id  #"ami-04faf011af88eb8e7"
  instance_type                        = var.instance_type
  key_name                             = var.ssh_key_name
  iam_instance_profile                 = aws_iam_instance_profile.palo.id
  disable_api_termination              = false
  ebs_optimized                        = true
  instance_initiated_shutdown_behavior = "stop"
  monitoring                           = false

  network_interface {
    network_interface_id = aws_network_interface.mgmt.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.eth1.id
    device_index         = 1
  }
  network_interface {
    network_interface_id = aws_network_interface.eth2.id
    device_index         = 2
  }

  user_data = <<EOF
    vmseries-bootstrap-aws-s3bucket=${lower(var.palo_name)}-${resource.random_uuid.s3postfix.result}
  EOF

  root_block_device {
    delete_on_termination = true
    encrypted             = false
  }

  tags = {
    Name        = "${lower(var.palo_name)}"
  }

}


resource "aws_eip" "public_ip_mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.mgmt.id
  # associate_with_private_ip = "10.1.1.10"
  tags = {
    Name = "${lower(var.palo_name)}-eip-mgmt"
  }
  depends_on = [
    aws_instance.palo
  ]  

}

resource "aws_eip" "public_ip_eth1" {
  vpc                       = true
  network_interface         = aws_network_interface.eth1.id
  # associate_with_private_ip = "10.1.1.10"
  tags = {
    Name = "${lower(var.palo_name)}-eip-eth1"
    
  }
  depends_on = [
    aws_instance.palo
  ]  

}

resource "aws_network_interface" "mgmt" {
  subnet_id         = var.mgmt_subnet_id
  # private_ips       = [ var.private_ip2 ]
  security_groups   =  [aws_security_group.aws-palo-sg.id]
  source_dest_check = false
  tags = {
    Name = "${lower(var.palo_name)}-mgmt"
    
  }
}

resource "aws_network_interface" "eth1" {
  subnet_id         = var.eth1_subnet_id
  # private_ips       = [ var.private_ip2 ]
  security_groups   =  [aws_security_group.aws-palo-sg.id]
  source_dest_check = false
  tags = {
    Name = "${lower(var.palo_name)}-eth1"
    
  }

}

resource "aws_network_interface" "eth2" {
  subnet_id         = var.eth2_subnet_id
  # private_ips       = [ var.private_ip2 ]
  security_groups   =  [aws_security_group.aws-palo-sg.id]
  source_dest_check = false
  tags = {
    Name = "${lower(var.palo_name)}-eth2"
    
  }

}




# Define the security group for the Palo Alto FIrewall
resource "aws_security_group" "aws-palo-sg" {
  name        = "${lower(var.palo_name)}-palo-sg"
  description = "Allow incoming HTTP connections"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming ICMP connections"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTPS connections"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming SSH connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${lower(var.palo_name)}-sg"
  }
}


