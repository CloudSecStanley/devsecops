# DevSecOps Automated Infrastructure & Static Security Pipeline

A secure, automated Infrastructure as Code (IaC) and container deployment pipeline leveraging **Terraform**, **AWS OIDC Identity Federation**, and **GitHub Actions**.

## 📌 Architecture Overview
* **Infrastructure as Code**: Terraform provisions AWS EC2 compute and Security Group resources.
* **Keyless Authentication**: AWS IAM OIDC integration allows GitHub Actions to assume deployment roles safely without persistent AWS secrets.
* **Security Scanning**: Automated static code scanning using **Checkov** for IaC and **Hadolint** for Dockerfile best practices.
* **Runtime**: Nginx Alpine web server container environment.

---

## 🛠️ Repository Structure
```text
.
├── .github/
│   └── workflows/
│       └── devsecops-ci.yml    # GitHub Actions CI/CD Pipeline
├── terraform/
│   ├── main.tf                 # EC2 & Security Group resources
│   ├── oidc.tf                 # AWS IAM OIDC Identity Provider & Role
│   ├── outputs.tf              # Infrastructure outputs
│   ├── providers.tf            # AWS provider configuration
│   └── variables.tf            # Input variable definitions
├── Dockerfile                  # Nginx container configuration
└── README.md