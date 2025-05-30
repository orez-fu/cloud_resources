resource "tls_private_key" "eks_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "eks_keypair" {
  key_name   = "${var.cluster_name}_keypair"
  public_key = tls_private_key.eks_private_key.public_key_openssh
}

resource "local_file" "bastion_private_key" {
  filename = "${path.module}/keys/${var.cluster_name}_keypair.pem"
  content  = tls_private_key.eks_private_key.private_key_pem

  # Set permissions to read-only for the owner
  file_permission = "0400"
}
