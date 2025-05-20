# This is the main Terraform configuration file for the infrastructure setup.
data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "postgres" {
  name = "prod-postgres-credentials"
}

data "aws_secretsmanager_secret_version" "postgres" {
  secret_id = data.aws_secretsmanager_secret.postgres.id
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.postgres.secret_string)
}

resource "aws_subnet" "learner_public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.learner.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "learner-public-${count.index}"
  }
}

resource "aws_security_group" "learner_ec2" {
  name        = "learner-ec2-sg"
  description = "Allow SSH and web"
  vpc_id      = aws_vpc.learner.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH, restrict for production!
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "learner-ec2-sg" }
}

resource "aws_vpc" "learner" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "learner-vpc"
  }
}

resource "aws_iam_role" "ec2_ecr_role" {
  count = terraform.workspace == "dev" ? 1 : 0
  name = "${var.name}-ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_full_access" {
  count       = terraform.workspace == "dev" ? 1 : 0
  role       = aws_iam_role.ec2_ecr_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  count = terraform.workspace == "dev" ? 1 : 0
  name = "${var.name}-ec2-ecr-instance-profile"
  role = aws_iam_role.ec2_ecr_role[0].name
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr_block       = var.vpc_cidr_block
  vpc_name             = "learner-vpc"
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  public_subnet_name   = "learner-public-subnet"
  availability_zone    = "ap-southeast-1a"
  sg_name              = "learner-ec2-sg"
}

module "ec2_instance" {
  count  = terraform.workspace == "dev" ? 1 : 0
  source = "terraform-aws-modules/ec2-instance/aws"

  name           = "${var.name}-${terraform.workspace}"
  key_name       = "my-key"
  instance_type  = "t3.micro" # Use t3.micro for Free Tier
  monitoring     = true
  subnet_id      = module.vpc.public_subnet_ids[0]   # Use the first public subnet

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance to access ECR"
  iam_role_policies = {
    AmazonEC2ContainerRegistryFullAccess = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    AmazonS3FullAccess                   = "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_profile[0].name

  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y docker
                systemctl enable docker
                systemctl start docker
                usermod -aG docker ec2-user
                curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                chmod +x /usr/local/bin/docker-compose
                docker --version
                docker-compose --version
              EOF

  tags = {
    Terraform   = "true"
    Environment = "${var.name}-dev"
  }
}

resource "aws_iam_role" "eks_node_role" {
  name = "${var.name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = "prod-eks"
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_group_iam_role_arn = aws_iam_role.eks_node_role.arn
}

module "rds" {
  source             = "./modules/rds"
  db_identifier      = "prod-postgres"
  db_username        = local.db_creds["POSTGRES_USER"]
  db_password        = local.db_creds["POSTGRES_PASSWORD"]
  db_name            = local.db_creds["POSTGRES_DB"]
  db_sg_id           = module.vpc.ec2_security_group_id
  private_subnet_ids = module.vpc.private_subnet_ids
}