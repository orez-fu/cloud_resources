
output "cluster_name" {
  value       = var.cluster_name
  description = "The name of the EKS cluster"
}
output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "The endpoint of the EKS cluster"
}
output "cluster_version" {
  value       = module.eks.cluster_version
  description = "The version of the EKS cluster"
}
output "cluster_node_security_group_id" {
  value       = module.eks.node_security_group_id
  description = "The security group ID for the EKS cluster nodes"
}

output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "The certificate authority data for the EKS cluster"
}
