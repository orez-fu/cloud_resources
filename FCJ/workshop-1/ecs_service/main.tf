
module "aws_locust_ecs_service" {
  source = "../modules/aws_locust_service"

  project = "fcj-workshop-1"

  tags = {
    "solution" : "locust"
  }

  ecs_task_locust_version = "2.29.0"
  ecs_task_locust_file    = "sample_locust/site_dantri/locustfile.py"
}

output "alb_dns_name" {
  value = module.aws_locust_ecs_service.alb_dns_name
}

output "aws_service_master_name" {
  value = module.aws_locust_ecs_service.aws_service_master_name
}
