output "ec2_public_ip" {
  description = "public IP for the EC2 application server"
  value = aws_instance.app_server.public_ip
}

output "ec2_public_dns" {
  description = "public DNS for the EC2 application server"
  value = aws_instance.app_server.public_dns
}

output "ec2_instance_id" {
  description = "ID of the provisioned EC2 Instance"
  value = aws_instance.app_server.id
}

output "security_group_id" {
  description = "ID of the NGINX server"
  value = aws_security_group.app_server_sg
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for github actions OIDC authentication"
  value = aws_iam_role.github_actions_role.arn
}