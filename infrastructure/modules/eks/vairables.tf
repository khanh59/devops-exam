variable "cluster_name" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "node_group_iam_role_arn" {
  description = "IAM role ARN for EKS managed node group"
  type        = string
}