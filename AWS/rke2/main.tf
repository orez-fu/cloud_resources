resource "tls_private_key" "control_plane_keypair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "control_plane_key" {
  key_name   = "control_plane_key"
  public_key = tls_private_key.control_plane_keypair.public_key_openssh
}
resource "local_file" "control_plane_private_key" {
  filename = "${path.module}/keys/control_plane_key.pem"
  content  = tls_private_key.control_plane_keypair.private_key_pem

  # Set permissions to read-only for the owner
  file_permission = "0400"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eks-vpc"
  cidr = "10.22.0.0/16"

  azs            = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets = ["10.22.1.0/24", "10.22.2.0/24", "10.22.3.0/24"]

  enable_nat_gateway      = false
  map_public_ip_on_launch = true
}

resource "aws_network_interface" "control_plane_nic" {
  subnet_id       = element(module.vpc.public_subnets, 0)
  security_groups = [aws_security_group.control_plane_sg.id]

  tags = {
    Name = "control-plane-nic"
  }
}

resource "aws_network_interface_attachment" "control_plane_attachment" {
  instance_id          = aws_instance.control_plane.id
  network_interface_id = aws_network_interface.control_plane_nic.id
  device_index         = 1
}

resource "aws_instance" "control_plane" {
  ami           = data.aws_ami.bastion_ami.id
  instance_type = "t3.large"

  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [aws_security_group.control_plane_sg.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.control_plane_key.key_name

  user_data = templatefile("scripts/control_plane_user_data.sh.tpl", {
    RKE2_TOKEN     = var.rke2_token
    RKE2_SERVER_IP = aws_network_interface.control_plane_nic.private_ip
    RKE2_NODE_NAME = "control-plane"
  })

  root_block_device {
    volume_size = 80
    volume_type = "gp3"
  }

  #   ebs_block_device {
  #   device_name           = "/dev/xvdf"
  #   volume_type           = "gp2"
  #   volume_size           = 16
  #   delete_on_termination = true
  #   encrypted             = true
  #   iops                  = 0
  #   snapshot_id           = ""
  #   no_device             = false
  # }

  depends_on = [aws_network_interface.control_plane_nic]

  tags = {
    Name = "control-plane"
  }
}


resource "aws_security_group" "control_plane_sg" {
  name        = "control-plane-sg"
  description = "Security group for control plane instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "worker_nodes" {
  count                  = 3
  ami                    = data.aws_ami.bastion_ami.id
  instance_type          = "t3.medium"
  subnet_id              = element(module.vpc.public_subnets, count.index % length(module.vpc.public_subnets))
  key_name               = aws_key_pair.control_plane_key.key_name
  vpc_security_group_ids = [aws_security_group.worker_nodes_sg.id]

  user_data = templatefile("scripts/worker_user_data.sh.tpl", {
    RKE2_TOKEN     = var.rke2_token
    RKE2_SERVER_IP = aws_network_interface.control_plane_nic.private_ip
    RKE2_NODE_NAME = "worker-node-${count.index + 1}"
  })

  associate_public_ip_address = true

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  depends_on = [aws_instance.control_plane]

  tags = {
    Name = "worker-node-${count.index + 1}"
  }
}

resource "aws_security_group" "worker_nodes_sg" {
  name        = "worker-nodes-sg"
  description = "Security group for worker nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "worker-nodes-sg"
  }
}
