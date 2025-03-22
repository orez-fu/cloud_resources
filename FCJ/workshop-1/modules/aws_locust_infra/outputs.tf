
output "ecs_cluster_id" {
  value = aws_ecs_cluster.ecs_cluster.id
}

output "efs_id" {
  value = aws_efs_file_system.efs.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_username" {
  value = "ubuntu"
}
