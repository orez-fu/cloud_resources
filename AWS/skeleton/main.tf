
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

module "bastion" {
  source = "./modules/ec2-bastion"

  vpc_id    = module.network.vpc_id
  subnet_id = module.network.public_subnet_ids[0]

  # tags = {
  #   Environment = "lab"
  #   Project     = "poc"
  #   Owner       = "labor"
  # }
  # region             = "us-east-1"
  # vpc_id             = module.network.vpc_id
  # bastion_name       = "bastion"
  # bastion_ami        = "ami-0c55b159cbfafe1f0"
  # bastion_instance_type = "t2.micro"
}

module "eks" {
  source                                   = "./modules/eks"
  vpc_id                                   = module.network.vpc_id
  subnet_ids                               = module.network.private_subnet_ids
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  public_subnet_cidrs                      = module.network.public_subnet_cidrs
  tags = {
    Environment = "lab"
    Project     = "poc"
    Owner       = "labor"
  }
}


output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}
