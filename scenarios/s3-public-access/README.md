# Scenario: S3 Public Access Misconfiguration

## Real-World Risk

A publicly accessible S3 bucket can expose sensitive data to the entire internet. This is one of the most common causes of cloud data breaches — misconfigured S3 buckets have leaked medical records, financial data, and source code in high-profile incidents (Capital One 2019, GoDaddy 2021).

An attacker only needs to know or guess the bucket name to download all its contents.

---

## What This Scenario Demonstrates

This Terraform configuration intentionally introduces three misconfigurations:

| # | Misconfiguration | Resource |
|---|---|---|
| 1 | Public access block disabled (`block_public_acls = false`) | `aws_s3_bucket_public_access_block` |
| 2 | No server-side encryption | missing `aws_s3_bucket_server_side_encryption_configuration` |
| 3 | No versioning | missing `aws_s3_bucket_versioning` |

---

## Which Defense Layer Catches It

### Layer 1 — Prevention (CI/CD)

| Tool | Rule | What it catches |
|---|---|---|
| **OPA** | `s3.rego` | `block_public_acls != true` |
| **Checkov** | CKV_AWS_53, CKV_AWS_54, CKV_AWS_55, CKV_AWS_56 | All 4 public access block flags |
| **Checkov** | CKV_AWS_19 | Missing server-side encryption |
| **Checkov** | CKV_AWS_21 | Missing versioning |
| **tfsec** | AVD-AWS-0086 to 0089 | Public access block flags |
| **tfsec** | AVD-AWS-0132 | Missing encryption |
| **Trivy** | AVD-AWS-0086 to 0089 | Public access block flags |

### Layer 2 — Runtime Detection

| Tool | What it catches |
|---|---|
| **Prowler** | `s3_bucket_public_access_block_enabled` check in CIS standard |
| **Security Hub** | FSBP: `S3.2`, `S3.3`, `S3.4`, `S3.5` — public access controls |

---

## Expected CI Failure Output

### OPA
```
{
  "msg": "S3 bucket 'aws_s3_bucket_public_access_block.public_data' must have block_public_acls = true"
}
OPA policy violations found!
Error: Process completed with exit code 1
```

### Checkov
```
Check: CKV_AWS_53: "Ensure S3 bucket has block public ACLS enabled"
FAILED for resource: aws_s3_bucket_public_access_block.public_data

Check: CKV_AWS_19: "Ensure the S3 bucket has server-side-encryption enabled"
FAILED for resource: aws_s3_bucket.public_data
```

### tfsec / Trivy
```
AVD-AWS-0086  S3 bucket has public access blocks disabled
CRITICAL  scenarios/s3-public-access/main.tf:17
```

---

## Remediation Runbook

### Step 1 — Enable all public access block settings

```hcl
# BEFORE (misconfigured)
resource "aws_s3_bucket_public_access_block" "public_data" {
  bucket                  = aws_s3_bucket.public_data.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# AFTER (secure)
resource "aws_s3_bucket_public_access_block" "public_data" {
  bucket                  = aws_s3_bucket.public_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### Step 2 — Add server-side encryption with KMS

```hcl
# ADD this resource
resource "aws_s3_bucket_server_side_encryption_configuration" "public_data" {
  bucket = aws_s3_bucket.public_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}
```

### Step 3 — Enable versioning

```hcl
# ADD this resource
resource "aws_s3_bucket_versioning" "public_data" {
  bucket = aws_s3_bucket.public_data.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

### Step 4 — Apply and verify

```bash
terraform plan   # confirm changes look correct
terraform apply  # apply the fix
```

Verify in AWS Console: S3 → bucket → Permissions tab → Block public access: all 4 settings ON.

---

## Secure Configuration (final state)

See `terraform/modules/s3/main.tf` for the correctly configured S3 module used in this project.

---

## Defense-in-Depth Summary

```
Developer commits misconfigured S3
          │
          ▼
    CI Pipeline (PR)
    ├── OPA    → FAIL: block_public_acls != true
    ├── Checkov → FAIL: CKV_AWS_53, CKV_AWS_19, CKV_AWS_21
    ├── tfsec  → FAIL: AVD-AWS-0086, AVD-AWS-0132
    └── Trivy  → FAIL: AVD-AWS-0086

    PR is blocked — misconfiguration never reaches AWS
          │
          │ (if it somehow bypassed CI)
          ▼
    Prowler daily scan → finding: s3_bucket_public_access_block_enabled
    Security Hub → FSBP S3.2 FAILED
    EventBridge → email alert within 5 minutes
```
