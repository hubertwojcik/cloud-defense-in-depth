# SCENARIO: IAM Wildcard Permissions Misconfiguration
# Intentionally misconfigured for Defense-in-Depth demonstration.
# This file exists only on the scenario/iam-wildcard branch.
# DO NOT merge to main.

resource "aws_iam_role" "scenario_overpermissioned" {
  name = "cloud-defense-in-depth-scenario-overpermissioned"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Project     = "cloud-defense-in-depth"
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

resource "aws_iam_policy" "scenario_wildcard" {
  name = "cloud-defense-in-depth-scenario-wildcard-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "FullAccess"
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "scenario_wildcard" {
  role       = aws_iam_role.scenario_overpermissioned.name
  policy_arn = aws_iam_policy.scenario_wildcard.arn
}
