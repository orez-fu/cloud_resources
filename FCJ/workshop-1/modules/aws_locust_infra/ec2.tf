
data "aws_ami" "bastion_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = merge({
    Name = "${var.project}-bastion-eip"
    },
    var.tags
  )
}

resource "aws_security_group" "bastion_sg" {
  name   = "bastion_sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_sg_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.project}-bastion-sg"
    },
    var.tags
  )
}

resource "aws_instance" "bastion" {
  lifecycle {
    ignore_changes = [ami]
  }

  ami                         = data.aws_ami.bastion_ami.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = aws_subnet.public_subnet[0].id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = var.bastion_key_name

  user_data = <<-EOF
              #!/bin/bash 
              sudo apt-get update
              sudo apt-get install -y nfs-common
              sudo mkdir -p /mnt/efs
              sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs.dns_name}:/ /mnt/efs
              EOF

  tags = merge({
    Name = "${var.project}-bastion"
    },
    var.tags
  )

  depends_on = [aws_efs_file_system.efs, aws_efs_mount_target.efs_mount_target]
}
