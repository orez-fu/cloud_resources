
module "network" {
  source = "./modules/vpc"

  # tags = {
  #   Environment = "lab"
  #   Project     = "poc"
  #   Owner       = "labor"
  # }
  # region             = "us-east-1"
  # vpc_name           = "Lab VPC"
  # vpc_cidr           = "10.1.0.0/16"
  # vpc_public_subnets = [
  #   {
  #     az   = "us-east-1a"
  #     cidr = "10.1.1.0/24"
  #     name = "AZ-A public subnet"
  #   },
}
