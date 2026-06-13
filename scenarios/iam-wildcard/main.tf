# SCENARIO: IAM Wildcard Permissions Misconfiguration
# Intentionally misconfigured for Defense-in-Depth demonstration.
# DO NOT deploy this configuration to production.

resource "aws_iam_role" "overpermissioned_role" {
  name = "cloud-defense-in-depth-demo-overpermissioned"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

# MISCONFIGURATION: Action:"*" on Resource:"*" — full AWS access granted
# Caught by: OPA (iam.rego), Checkov (CKV_AWS_290, CKV_AWS_355), tfsec (AVD-AWS-0057), Trivy
resource "aws_iam_policy" "wildcard_policy" {
  name = "cloud-defense-in-depth-demo-wildcard-policy"

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

resource "aws_iam_role_policy_attachment" "wildcard_attachment" {
  role       = aws_iam_role.overpermissioned_role.name
  policy_arn = aws_iam_policy.wildcard_policy.arn
}
