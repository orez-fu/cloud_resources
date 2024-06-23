
resource "aws_security_group" "efs_sg" {
  name   = "efs_sg"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.private_subnets
    content {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "Allow EFS access from private subnets"
    }
  }

  dynamic "ingress" {
    for_each = var.public_subnets
    content {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "Allow EFS access from public subnets"
    }
  }

  tags = merge({
    Name = "${var.project}-efs-sg"
    },
    var.tags
  )
}

resource "aws_efs_file_system" "efs" {
  creation_token = var.project
  encrypted      = true

  tags = merge({
    "Name" = "${var.project}-efs"
    },
    var.tags
  )
}

resource "aws_efs_mount_target" "efs_mount_target" {
  count           = length(var.public_subnets)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.public_subnet[count.index].id
  security_groups = [aws_security_group.efs_sg.id]
}
