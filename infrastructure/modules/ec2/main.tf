module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr_block       = var.vpc_cidr_block
  vpc_name             = "learner-vpc"
  public_subnet_cidrs  = var.public_subnet_cidrs
  public_subnet_name   = "learner-public-subnet"
  availability_zone    = "ap-southeast-1a"
  sg_name              = "learner-ec2-sg"
}

module "ec2" {
  source                    = "./modules/ec2"
  ec2_name                  = "${var.name}-${terraform.workspace}"
  instance_type             = "t3.micro"
  subnet_id                 = module.vpc.public_subnet_ids[0]   # Use the first public subnet
  security_group_id         = module.vpc.ec2_security_group_id
  user_data                 = file("${path.module}/prepare_ec2.sh")
  tags                      = {
    Terraform   = "true"
    Environment = "${var.name}-dev"
  }
  iam_role_name             = "${var.name}-ec2-ecr-role"
  iam_instance_profile_name = "${var.name}-ec2-ecr-instance-profile"
}