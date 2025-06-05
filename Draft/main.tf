
module "network" {
  source = "./vpc"

  tags = {
    Environment = "workshop"
    Project     = "lab"
    Owner       = "phuhv"
  }
  region   = "us-east-1"
  vpc_name = "workshop-vpc"
  vpc_cidr = "10.0.0.0/16"
  vpc_public_subnets = [
    {
      az   = "us-east-1a"
      cidr = "10.0.0.0/22"
      name = "AZ-A public subnet"
    },
    {
      az   = "us-east-1b",
      cidr = "10.0.4.0/22"
      name = "AZ-B public subnet"
    },
    {
      az   = "us-east-1c",
      cidr = "10.0.8.0/22"
      name = "AZ-C public subnet"
    }
  ]
  vpc_private_subnets = [
    {
      az   = "us-east-1a"
      cidr = "10.0.12.0/22"
      name = "AZ-A private subnet"
    },
    {
      az   = "us-east-1b"
      cidr = "10.0.16.0/22"
      name = "AZ-B private subnet"
    },
    {
      az   = "us-east-1c"
      cidr = "10.0.20.0/22"
      name = "AZ-C private subnet"
    }
  ]
}

module "eks" {
  source                                   = "./eks"
  vpc_id                                   = module.network.vpc_id
  subnet_ids                               = module.network.private_subnet_ids
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  public_subnet_cidrs                      = module.network.public_subnet_cidrs
  cluster_node_groups = {
    name          = "eks-ng"
    min_size      = 3
    desired_size  = 3
    max_size      = 10
    instance_type = "t3.medium"
    ami_type      = "AL2_x86_64"
  }
  tags = {
    Environment = "lab"
    Project     = "poc"
    Owner       = "labor"
  }
}


# output "bastion_public_ip" {
#   value = module.bastion.bastion_public_ip
# }

output "private_subnets" {
  value = module.network.private_subnet_ids
}

output "public_subnets" {
  value = module.network.public_subnet_ids
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "configure_kubectl" {
  value       = <<EOT
  aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name} --alias ${module.eks.cluster_name}
EOT
  description = "Configure kubectl to use the EKS cluster"
}
output "cluster_name" {
  value       = module.eks.cluster_name
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
  value       = module.eks.cluster_node_security_group_id
  description = "The security group ID for the EKS cluster nodes"
}
output "cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  description = "The certificate authority data for the EKS cluster"
}
