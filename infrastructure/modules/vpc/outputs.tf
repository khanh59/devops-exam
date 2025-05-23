output "vpc_id" { value = aws_vpc.this.id }

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}