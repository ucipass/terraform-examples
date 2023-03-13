resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.ssh_key_name       # Create ssh key to AWS!!
  public_key = tls_private_key.key.public_key_openssh

  provisioner "local-exec" { # Create "<ssh_key_name>.pem" to your computer!!
    command = "echo '${tls_private_key.key.private_key_pem}' > ./${var.ssh_key_name}.pem"
  }
}