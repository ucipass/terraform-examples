
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu*20.04*amd64*server*"]
  }
}

resource "aws_network_interface" "eth0" {
  subnet_id   = var.subnet_id
  private_ips = [var.ip_address]
  security_groups = [aws_security_group.ub_sg.id]

  tags = {
    Name = "${lower(var.instance_name)}-eth0"
  }
}

# resource "aws_network_interface_attachment" "eth0" {
#   instance_id          = aws_instance.ubuntu.id
#   network_interface_id = aws_network_interface.eth0.id
#   device_index         = 0
# }

resource "aws_instance" "ubuntu" {
  ami  = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = var.ssh_key_name

  network_interface {
    network_interface_id = aws_network_interface.eth0.id
    device_index         = 0
  }

  user_data = var.user_data
    # user_data = file("./script.sh")
  # provisioner "remote-exec" {
  #   inline = [ "cloud-init status --wait" ]
  # }

  tags = {
    Name = "${lower(var.instance_name)}"
  }

}


# Define the security group for the Palo Alto FIrewall
resource "aws_security_group" "ub_sg" {
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
