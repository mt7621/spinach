resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "keypair" {
  key_name = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = var.key_filename
  content = tls_private_key.private_key.private_key_pem
}