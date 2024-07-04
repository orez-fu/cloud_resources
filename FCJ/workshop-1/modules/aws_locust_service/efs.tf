data "aws_efs_file_system" "efs" {
  creation_token = var.project
  tags = merge({
    "Name" = "${var.project}-efs"
  }, var.tags)
}

resource "aws_efs_access_point" "efs_ap" {
  file_system_id = data.aws_efs_file_system.efs.file_system_id
  root_directory {
    path = "/"
  }
  tags = merge({
    "Name" = "${var.project}-efs-ap"
  }, var.tags)
}

resource "aws_efs_file_system_policy" "efs_policy" {
  file_system_id = data.aws_efs_file_system.efs.file_system_id
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "efs-policy",
    Statement = [
      {
        Sid       = "Statement",
        Effect    = "Allow",
        Principal = "*",
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientRootAccess",
          "elasticfilesystem:ClientWrite"
        ],
        Resource = data.aws_efs_file_system.efs.arn
      }
    ]
  })
}
