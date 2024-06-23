

module "aws_locust_ecs_infra" {
  source = "../modules/aws_locust_infra"

  project = "fcj-workshop-1"

  tags = {
    "solution" : "locust"
  }

  ### VPC ### 
  vpc_cidr               = "10.35.0.0/16"
  private_subnets        = ["10.35.0.0/24", "10.35.2.0/24"]
  public_subnets         = ["10.35.1.0/24", "10.35.3.0/24"]
  azs                    = ["us-east-1a", "us-east-1b"]
  igw_enable             = true
  nat_gateway_enable     = true
  bastion_instance_type  = "t2.micro"
  bastion_sg_cidr_blocks = ["0.0.0.0/0"]
  bastion_key_name       = "learning"

}

output "ecs_cluster_id" {
  value = module.aws_locust_ecs_infra.ecs_cluster_id
}

output "efs_id" {
  value = module.aws_locust_ecs_infra.efs_id
}
