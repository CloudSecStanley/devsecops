# Default VPC lookup 
data "aws_vpc" "default" {
  default = true
}

# Security group for nginx server 

resource "aws_security_group" "app_server_sg" {
  name        = "${var.environment}-app-server-sg"
  description = "Security group for nginx server"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_http_cidr}"
  }

  ingress {
    description = "allow SSH access for administrative purpose"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ssh_cidr}"]
  }

  egress {
    description = "Allow HTTPS outbound traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_http_cidr}"
  }

   egress {
    description = "Allow HTTP outbound traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-nginx-sg"
    Environment = var.environment
  }
}

# IAM Role and Instance Profile for EC2 instance to access S3 and DynamoDB

resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AWS systems Manager (SSM) policy for secure terminal session management 

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile 

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# APP SERVER/ EC2 INSTANCE 

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]

  ebs_optimized = true
  monitoring    = true

  # Instance metadata service v2 enabled for enhanced security
  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
  }

  # Encrypted EBS volume for root device
  root_block_device {
    volume_type = "gp3"
    encrypted   = true
  }

  # Startup script to install and start docker to run nginx server container
  user_data = <<-EOF
                #!/bin/bash
                sudo dnf update -y
                sudo dnf install -y docker
                sudo systemctl enable docker
                sudo systemctl start docker
                sudo usermod -aG docker ec2-user

                # Launch nginx server container
                sudo docker run -d --name nginx-app -p 80:80 --restart always nginx:latest
                EOF

  tags = {
    Name        = "${var.environment}-nginx-server"
    Environment = var.environment
  }
}