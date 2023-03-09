# Create PA VM-series instances
resource "aws_instance" "palo1" {

  ami                                  = "ami-04faf011af88eb8e7"
  vpc_security_group_ids      = [aws_security_group.aws-palo-sg.id]
  instance_type                        = var.instance_type
  key_name                             = var.ssh_key_name
  subnet_id = aws_subnet.vpcmain-public-subnet1.id
  disable_api_termination              = false
  ebs_optimized                        = true
  instance_initiated_shutdown_behavior = "stop"
  monitoring                           = false

  user_data = <<EOF
    type=dhcp-client
    ip-address=
    default-gateway=
    netmask=
    ipv6-address=
    ipv6-default-gateway=
    hostname=Ca-FW-DC1
    tplname=FINANCE_TG4
    dgname=finance_dg
    dns-primary=8.8.8.8
    dns-secondary=8.8.4.4
    op-command-modes=jumbo-frame,mgmt-interface-swap**
    op-cmd-dpdk-pkt-io=***
    plugin-op-commands=
    dhcp-send-hostname=yes
    dhcp-send-client-id=yes
    dhcp-accept-server-hostname=yes
    dhcp-accept-server-domain=yes
  EOF


  root_block_device {
    delete_on_termination = true
    encrypted             = false
  }
  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-palo1"
    Environment = var.app_environment
  }

}

# Create Elastic IP for the EC2 instance
resource "aws_eip" "palo-eip" {
  vpc  = true
  tags = {
    Name        = "${lower(var.app_name)}-${var.app_environment}-palo-eip"
    Environment = var.app_environment
  }
  
}

# Associate Elastic IP to Palo Alto
resource "aws_eip_association" "palo-eip-association" {
  instance_id   = aws_instance.palo1.id
  allocation_id = aws_eip.palo-eip.id
  depends_on = [
    aws_instance.palo1
  ]  
}



# Define the security group for the Palo Alto FIrewall
resource "aws_security_group" "aws-palo-sg" {
  name        = "${lower(var.app_name)}-${var.app_environment}-palo-sg"
  description = "Allow incoming HTTP connections"
  vpc_id      = aws_vpc.vpcmain.id

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
    Name        = "${lower(var.app_name)}-${var.app_environment}-palo-sg"
    Environment = var.app_environment
  }
}