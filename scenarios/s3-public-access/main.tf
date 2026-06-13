# SCENARIO: S3 Public Access Misconfiguration
# This file intentionally contains security misconfigurations for demonstration purposes.
# DO NOT deploy this configuration to production.

resource "aws_s3_bucket" "public_data" {
  bucket = "cloud-defense-in-depth-public-demo"

  tags = {
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

# MISCONFIGURATION 1: Public access explicitly enabled
# Caught by: OPA (s3.rego), Checkov (CKV_AWS_53-56), tfsec (AVD-AWS-0086/0087/0088/0089)
resource "aws_s3_bucket_public_access_block" "public_data" {
  bucket = aws_s3_bucket.public_data.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# MISCONFIGURATION 2: No server-side encryption
# Caught by: Checkov (CKV_AWS_19), tfsec (AVD-AWS-0132), Trivy (AVD-AWS-0132)
# (aws_s3_bucket_server_side_encryption_configuration intentionally omitted)

# MISCONFIGURATION 3: No versioning
# Caught by: Checkov (CKV_AWS_21), tfsec (AVD-AWS-0090)
# (aws_s3_bucket_versioning intentionally omitted)
