
# Common variables
variable "region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "us-east-1"
}
variable "tags" {
  description = "A map of tags to assign to the EKS cluster and node groups."
  type        = map(string)
  default     = {}
}

# Dependencies variables
variable "vpc_id" {
  description = "The VPC ID where the EKS cluster will be deployed."
  type        = string
}
variable "subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster will be deployed."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "A list of public subnet IDs where the bastion host will be deployed."
  type        = list(string)
}

# EKS addons variables
variable "cluster_key_pair" {
  description = "The name of the key pair to use for the EKS cluster."
  type        = string
  default     = "lab-eks-keypair"
}

variable "cluster_addons" {
  description = "A list of EKS addons to be installed. Requires name."
  type = list(object({
    name    = string
    content = any
  }))
  default = [
    {
      name = "eks-pod-identity-agent"
      content = {
        most_recent = true
      }
    },
    {
      name = "vpc-cni"
      content = {
        most_recent          = true
        before_compute       = true
        configuration_values = <<-EOT
          env:
            ENABLE_PREFIX_DELEGATION: "true"
        EOT
      }
    }
  ]
}

# Main variables for EKS cluster
variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "lab-eks-cluster"
}

variable "cluster_version" {
  description = "The version of the EKS cluster."
  type        = string
  default     = "1.32"
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS cluster endpoint should be publicly accessible."
  type        = bool
  default     = false
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Whether to enable admin permissions for the cluster creator."
  type        = bool
  default     = false
}

variable "cluster_node_groups" {
  description = "The configuration for the EKS node group."
  type = object({
    name          = string
    desired_size  = number
    max_size      = number
    min_size      = number
    instance_type = string
    # key_name         = string
    ami_type = optional(string, "AL2_x86_64")
  })
  default = {
    name          = "lab-eks-node-group"
    min_size      = 1
    desired_size  = 2
    max_size      = 3
    instance_type = "t3.medium"
    # key_name         = "lab-aws-keypair"
    ami_type = "AL2_x86_64"
  }
}

variable "addons" {
  description = "EKS addons"
  type        = any
  default = {
    enable_aws_load_balancer_controller = false
    enable_aws_argocd                   = false
    enable_karpenter                    = false
  }
}
