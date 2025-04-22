output "public_subnet_ids" {
  description = "The subnet IDs of the public subnets"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "The subnet IDs of the private subnets"
  value       = aws_subnet.private_subnets[*].id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}
