# Scenario: IAM Wildcard Permissions

## Real-World Risk

An IAM policy with `Action: "*"` and `Resource: "*"` grants full AWS access — equivalent to a root account. If the role is assumed by a compromised EC2 instance, an attacker gains complete control: read all data, delete S3 buckets, create new admin users, exfiltrate credentials, disable CloudTrail.

This violates the Principle of Least Privilege and is one of the most dangerous misconfigurations in AWS.

---

## What This Scenario Demonstrates

| Misconfiguration | Resource |
|---|---|
| `Action: "*"` on `Resource: "*"` | `aws_iam_policy.scenario_wildcard` |

---

## Which Defense Layer Catches It

### Layer 1 — Prevention (CI/CD)

| Tool | Rule | What it catches |
|---|---|---|
| **OPA** | `iam.rego` | `Action == "*"` (string) and `Action[_] == "*"` (array) in tfplan.json |
| **Checkov** | CKV_AWS_290 | Write access without constraints |
| **Checkov** | CKV_AWS_355 | Wildcard resource in IAM policy |
| **tfsec** | AVD-AWS-0057 | IAM policy with wildcard actions |
| **Trivy** | AVD-AWS-0057 | IAM policy with wildcard actions |

### Layer 2 — Runtime Detection

| Tool | Check |
|---|---|
| **Prowler** | `iam_policy_no_full_access_to_all_actions` |
| **Security Hub** | IAM.1 — IAM policies should not allow full `*` administrative privileges |

---

## Expected CI Failure Output

### OPA
```
{
  "msg": "IAM policy 'aws_iam_policy.scenario_wildcard' must not use wildcard Action: \"*\""
}
OPA policy violations found!
Error: Process completed with exit code 1
```

### Checkov
```
Check: CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
FAILED for resource: aws_iam_policy.scenario_wildcard

Check: CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
FAILED for resource: aws_iam_policy.scenario_wildcard
```

### tfsec / Trivy
```
AVD-AWS-0057  IAM policy should avoid use of wildcards
CRITICAL  terraform/scenario_iam_wildcard.tf
```

---

## Remediation Runbook

### Step 1 — Identify what the role actually needs (IAM Access Analyzer)

IAM Access Analyzer generates a least-privilege policy based on real CloudTrail activity:

```bash
# Create Access Analyzer (one-time setup)
aws accessanalyzer create-analyzer \
  --analyzer-name cloud-defense-analyzer \
  --type ACCOUNT \
  --region eu-north-1

# Generate least-privilege policy from last 90 days of CloudTrail
aws accessanalyzer generate-policy \
  --principal-arn arn:aws:iam::ACCOUNT_ID:role/cloud-defense-in-depth-scenario-overpermissioned \
  --region eu-north-1
```

The output is a JSON policy containing only the actions actually invoked — ready to paste into Terraform.

### Step 2 — Replace wildcard with specific actions

**Before (misconfigured):**
```hcl
policy = jsonencode({
  Version = "2012-10-17"
  Statement = [{
    Sid      = "FullAccess"
    Effect   = "Allow"
    Action   = "*"
    Resource = "*"
  }]
})
```

**After (least privilege — EC2 role reading from a specific S3 bucket):**
```hcl
policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Sid    = "S3ReadAccess"
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        "arn:aws:s3:::my-specific-bucket",
        "arn:aws:s3:::my-specific-bucket/*"
      ]
    }
  ]
})
```

### Step 3 — Scope resource ARNs

Always constrain `Resource` to the specific ARN. Use `Resource: "*"` only when AWS does not support resource-level permissions for the action (e.g., `logs:CreateLogGroup` — documented AWS limitation).

### Step 4 — Apply and verify

```bash
terraform plan   # confirm wildcard removed
terraform apply
```

Verify in AWS Console: **IAM → Policies → policy name → JSON tab**. Confirm no `*` in Action or Resource fields.

---

## Secure Configuration Reference

See `terraform/modules/iam/main.tf` — the production module uses specific actions (`s3:GetObject`, `s3:PutObject`, `s3:DeleteObject`, `s3:ListBucket`) scoped to a single bucket ARN.

---

## Defense-in-Depth Flow

```
Developer commits Action:"*" IAM policy
          │
          ▼
    CI Pipeline (PR opened)
    ├── OPA    → FAIL: Action == "*" detected in tfplan.json
    ├── Checkov → FAIL: CKV_AWS_290, CKV_AWS_355
    ├── tfsec  → FAIL: AVD-AWS-0057
    └── Trivy  → FAIL: AVD-AWS-0057

    PR is blocked — overpermissioned role never reaches AWS
          │
          │ (hypothetical: CI bypassed)
          ▼
    Prowler daily scan → iam_policy_no_full_access_to_all_actions FAIL
    Security Hub → IAM.1 CRITICAL finding
    EventBridge rule → triggered
    SNS → email alert within 5 minutes
```
