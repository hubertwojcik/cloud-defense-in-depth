# SCENARIO: Open Security Group Misconfiguration
# Intentionally misconfigured for Defense-in-Depth demonstration.
# DO NOT deploy this configuration to production.

variable "vpc_id" {
  type        = string
  description = "VPC ID to attach the security group to"
  default     = "vpc-00000000000000000"
}

# MISCONFIGURATION: SSH (port 22) and RDP (port 3389) open to the entire internet
# Caught by: OPA (security_group.rego), Checkov (CKV_AWS_25, CKV_AWS_27), tfsec (AVD-AWS-0105), Trivy
resource "aws_security_group" "open_sg" {
  name        = "cloud-defense-in-depth-demo-open-sg"
  description = "SCENARIO: Open security group - unrestricted SSH and RDP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH open to the world"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RDP open to the world"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}
