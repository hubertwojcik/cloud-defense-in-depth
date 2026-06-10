# SCENARIO: S3 Public Access Misconfiguration
# Intentionally misconfigured for Defense-in-Depth demonstration.
# This file exists only on the scenario/s3-public-access branch.
# DO NOT merge to main.

resource "aws_s3_bucket" "scenario_public" {
  bucket = "cloud-defense-in-depth-scenario-public"

  tags = {
    Project     = "cloud-defense-in-depth"
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "scenario_public" {
  bucket = aws_s3_bucket.scenario_public.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
