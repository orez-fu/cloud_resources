data "aws_caller_identity" "current" {}
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.subnet_ids

  kms_key_administrators = distinct(concat([
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"],
    [data.aws_iam_session_context.current.issuer_arn]
  ))

  cluster_endpoint_public_access           = var.cluster_endpoint_public_access
  cluster_endpoint_private_access          = true
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  access_entries = {
    eks_admin = {
      principal_arn = aws_iam_role.eks_cluster_role.arn
      policy_associations = {
        argocd = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  cluster_addons = {
    for addon in var.cluster_addons :
    addon.name => addon.content
  }

  eks_managed_node_groups = {
    "${var.cluster_node_groups.name}" = {
      desired_size = var.cluster_node_groups.desired_size
      max_size     = var.cluster_node_groups.max_size
      min_size     = var.cluster_node_groups.min_size

      instance_type = var.cluster_node_groups.instance_type
      ami_type      = var.cluster_node_groups.ami_type
      key_name      = aws_key_pair.eks_keypair.key_name

      taints = var.addons.enable_karpenter ? {
        dedicated = {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
          effect   = "NO_SCHEDULE"
        }
      } : {}

      tags = merge(
        var.tags,
        {
          Name = "${var.cluster_name}-${var.cluster_node_groups.name}"
        }
      )
    }
  }

  cluster_security_group_additional_rules = {
    "bastion" = {
      description = "Allow all from bastion to EKS cluster"
      type        = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = var.public_subnet_cidrs
    }
  }

  node_security_group_additional_rules = {
    vpc_cni_metrics_traffic = {
      description                   = "Cluster API to node 61678/tcp vpc cni metrics"
      protocol                      = "tcp"
      from_port                     = 61678
      to_port                       = 61678
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  node_security_group_tags = merge(
    var.tags,
    {
      Name                     = "${var.cluster_name}-node-sg"
      "karpenter.sh/discovery" = var.cluster_name
    }
  )

  create_iam_role = false
  iam_role_arn    = aws_iam_role.eks_cluster_role.arn
}

# Your current user or role does not have access to Kubernetes objects on this EKS cluster

# https://medium.com/@amitmavgupta/cilium-installing-cilium-in-eks-with-no-kube-proxy-86f54a56c360

# Refer: https://awstip.com/creating-and-connecting-to-a-private-amazon-eks-cluster-via-a-bastion-host-ad64dc69494a

# Group role: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2458#issuecomment-1525645999
