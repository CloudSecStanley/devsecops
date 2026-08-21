# GitHub Actions OIDC Identity Provider
resource "aws_iam_openid_connect_provider" "github_actions" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a21852c0022d550d7d3d19814421dd1c73a0"
  ]
}

# IAM Role for GitHub Actions OIDC Authentication
resource "aws_iam_role" "github_actions_role" {
  name = "${var.environment}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:CloudSecStanley/devsecops:*"
          }
        }
      }
    ]
  })
}

# Least-Privilege Scoped Policy for Deployment Pipeline
resource "aws_iam_policy" "github_actions_deployment_policy" {
  #checkov:skip=CKV_AWS_355:"Wildcard dynamic resources required for EC2 and Security Group creation during initial deployment"

  name        = "${var.environment}-github-actions-deployment-policy"
  description = "Scoped IAM policy restricted to EC2 deployment and S3/DynamoDB state management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2ProvisioningPermissions"
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateTags"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMPassRolePermissions"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:PassRole",
          "iam:GetInstanceProfile",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile"
        ]
        Resource = [
          "arn:aws:iam::*:role/${var.environment}-*",
          "arn:aws:iam::*:instance-profile/${var.environment}-*"
        ]
      }
    ]
  })
}

# Correct and Safe Role-Policy Attachment Resource
resource "aws_iam_role_policy_attachment" "github_actions_scoped_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_deployment_policy.arn
}