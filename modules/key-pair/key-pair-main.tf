resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.ssh_key_name       # Create ssh key to AWS!!
  public_key = tls_private_key.key.public_key_openssh
}


resource "local_file" "foo" {
  content  = tls_private_key.key.private_key_pem
  filename = "./${var.ssh_key_name}.pem"
}