variable "vpc_cidr_block" { type = string }
variable "vpc_name" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "public_subnet_name" { type = string }
variable "availability_zone" { type = string }
variable "sg_name" { type = string }
variable "private_subnet_cidrs" {
  type = list(string)
}
variable "availability_zones" {
  type = list(string)
}