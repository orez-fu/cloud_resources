
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "aws_service_master_name" {
  value = aws_ecs_service.ecs_service_master.name
}
