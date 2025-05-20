output "public_subnet_ids" {
  value = [for s in aws_subnet.learner_public : s.id]
}

output "ec2_security_group_id" {
  value = aws_security_group.learner_ec2.id
}

output "ec2_public_ip" {
  value       = terraform.workspace == "dev" ? module.ec2_instance[0].public_ip : null
  description = "Public IP of the dev EC2 instance"
}