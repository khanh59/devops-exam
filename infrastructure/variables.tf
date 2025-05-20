variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "name" {
  description = "Base name for resources"
  type        = string
  default     = "learner"
}

variable "ec2_subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "ec2_security_group_ids" {
  description = "List of security group IDs for EC2 instance"
  type        = list(string)
}

variable "ec2_name" {
  description = "Name tag for EC2 instance"
  type        = string
  default     = "learner-dev-ec2"
}

variable "ec2_ami" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}