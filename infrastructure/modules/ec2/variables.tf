variable "ec2_name" { type = string }
variable "instance_type" { type = string }
variable "subnet_id" { type = string }
variable "security_group_id" { type = string }
variable "user_data" { type = string }
variable "tags" { type = map(string) }
variable "iam_role_name" { type = string }
variable "iam_instance_profile_name" { type = string }