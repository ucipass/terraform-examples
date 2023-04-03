resource "aws_eip" "public_ip" {
  vpc                       = true
  network_interface         = "${aws_network_interface.Gi1.id}"
  # associate_with_private_ip = "10.1.1.10"
}

resource "aws_network_interface" "Gi1" {
  subnet_id         = var.subnet_id1
  private_ips       = [ var.ip_address_gi1 ]
  security_groups   = [ aws_security_group.allow_all.id ]
  source_dest_check = false
  
  tags = {
    Name = "Gi1"
  }
}

resource "aws_network_interface" "Gi2" {
  subnet_id         = var.subnet_id2
  private_ips       = [ var.ip_address_gi2 ]
  security_groups   = [ aws_security_group.allow_all.id ]
  source_dest_check = false

  tags = {
    Name = "Gi2"
  }
}

resource "aws_instance" "c8000v" {
  #ssh -i mykeypair.pem ec2-user@myhostname.compute-1.amazonaws.com
  ami           = "${data.aws_ami.csr1kv.id}"
  instance_type = var.instance_type # or c5.xlarge for 8GB
  key_name = var.ssh_key_name

  network_interface {
    network_interface_id = aws_network_interface.Gi1.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.Gi2.id
    device_index         = 1
  }

  user_data = file("./config.txt")
  tags = {
    Name = var.instance_name
  }

}

resource "aws_security_group" "allow_all" {
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
    Name        = "${lower(var.instance_name)}-sg-allow-all"
  }
}


