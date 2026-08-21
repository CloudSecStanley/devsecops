variable "aws_region" {
  description = "AWS default region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for app server"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "allowed SSH access for administrative purpose"
  type        = string
  default     = "102.215.34.120/32"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "devsecops"
}