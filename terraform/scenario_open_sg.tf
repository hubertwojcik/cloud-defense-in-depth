# SCENARIO: Open Security Group Misconfiguration
# Intentionally misconfigured for Defense-in-Depth demonstration.
# This file exists only on the scenario/open-security-group branch.
# DO NOT merge to main.

resource "aws_security_group" "scenario_open" {
  name        = "cloud-defense-in-depth-scenario-open-sg"
  description = "SCENARIO: Open security group - unrestricted SSH and RDP"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Project     = "cloud-defense-in-depth"
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

# MISCONFIGURATION: SSH open to the world — caught by OPA, Checkov, tfsec, Trivy
resource "aws_vpc_security_group_ingress_rule" "scenario_ssh_open" {
  security_group_id = aws_security_group.scenario_open.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"

  tags = {
    Project     = "cloud-defense-in-depth"
    Environment = "demo"
  }
}

# MISCONFIGURATION: RDP open to the world — caught by OPA, Checkov, tfsec, Trivy
resource "aws_vpc_security_group_ingress_rule" "scenario_rdp_open" {
  security_group_id = aws_security_group.scenario_open.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3389
  to_port           = 3389
  ip_protocol       = "tcp"

  tags = {
    Project     = "cloud-defense-in-depth"
    Environment = "demo"
  }
}
