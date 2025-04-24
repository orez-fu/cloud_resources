resource "tls_private_key" "bastion_keypair" {
  count     = var.create_key_pair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion_key" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.key_name
  public_key = tls_private_key.bastion_keypair[0].public_key_openssh
}

resource "local_file" "bastion_private_key" {
  count    = var.create_key_pair ? 1 : 0
  filename = "${path.module}/keys/${var.key_name}.pem"
  content  = tls_private_key.bastion_keypair[0].private_key_pem

  # Set permissions to read-only for the owner
  file_permission = "0400"
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.instance_name}-sg"
  }, var.tags)
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.bastion_ami.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name


  user_data = file("${path.module}/scripts/user_data.sh")

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )
}
