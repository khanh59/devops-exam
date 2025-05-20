module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnet_ids

  eks_managed_node_groups = {
    default = {
      desired_size    = 2
      max_size        = 2
      min_size        = 1
      instance_types  = ["t3.medium"]
      iam_role_arn    = var.node_group_iam_role_arn
    }
  }

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}

