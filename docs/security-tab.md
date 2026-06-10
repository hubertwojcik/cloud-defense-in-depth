# GitHub Security Tab — Consolidated Scanner Results

## Where to find results

GitHub → **Security** tab → **Code scanning**

All 4 tools upload results in SARIF format to the same location. Each tool is assigned a distinct `category`, which prevents GitHub from merging results and clearly attributes each finding to its source.

---

## Tools and their categories

| Tool | SARIF Category | Workflow | Trigger |
|---|---|---|---|
| Checkov | `checkov` | `security-gates.yml` | PR / push to main |
| tfsec | `tfsec` | `security-gates.yml` | PR / push to main |
| Trivy | `trivy` | `security-gates.yml` | PR / push to main |
| Prowler | `prowler` | `scan-infrastructure.yaml` | Daily at 06:00 UTC |

---

## Filtering by tool

In the Code scanning tab, use the **Tool** filter on the right side of the alert list:
- `Tool: Checkov` — Terraform plan scan results
- `Tool: tfsec` — static analysis of `.tf` source code
- `Tool: Trivy` — static analysis of `.tf` source code (AVID ruleset)
- `Tool: Prowler` — live scan of deployed AWS infrastructure

---

## How to interpret alerts

### Severity levels

| Level | Meaning |
|---|---|
| `Error` | CRITICAL/HIGH — blocks PR |
| `Warning` | MEDIUM — does not block |
| `Note` | LOW — informational |

### Key columns

- **Alert** — rule name and short description of the violation
- **Tool** — which scanner detected the issue
- **Location** — file and line number
- **Branch** — which branch the alert was detected on

---

## What each tool covers

### Checkov (`category: checkov`)
Scans `terraform plan` output after variable substitution — sees actual runtime values. Catches issues that static analysis misses (e.g., a KMS key ARN that resolves to empty, a missing encryption config on a specific bucket).

### tfsec (`category: tfsec`)
Static analysis of `.tf` source code. Uses Aqua Security AVD rules. Requires no AWS credentials — operates purely on code.

### Trivy (`category: trivy`)
Static analysis of `.tf` source code. Uses the AVID ruleset — a different engine than tfsec, covering different classes of misconfiguration. Complements tfsec without duplicating results.

### Prowler (`category: prowler`)
The only tool that scans **live AWS infrastructure** — not code. Detects configuration drift: cases where the code is correct but the actual AWS state differs (e.g., someone manually changed a setting in the AWS console).

---

## Why OPA does not appear in the Security tab

OPA (Open Policy Agent) enforces custom Rego policies and does not produce output in SARIF format. Its results are visible directly in the `OPA Policy Check` job logs in the Actions tab. A policy violation blocks the PR via exit code 1, but alerts are not sent to Code Scanning.

---

## Suppressions and exceptions

Some alerts are intentionally silenced. Every suppression is documented with justification in the corresponding configuration file:

| File | Tool | What it suppresses |
|---|---|---|
| `.checkov.yaml` | Checkov | False positives and intentional design decisions (e.g., no MFA delete in demo environment) |
| `.tfsec/config.yaml` | tfsec | Rules overlapping with Checkov |
| `.trivyignore` | Trivy | `AVD-AWS-0057` — `Resource:"*"` required by AWS for EC2 Describe, IAM read, and CloudWatch APIs |
