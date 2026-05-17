# cloud-defense-in-depth

A Defense-in-Depth framework for detecting and remediating cloud misconfigurations across multiple security layers. The project demonstrates how layered controls reduce the blast radius of misconfigurations in AWS environments by combining IaC policy enforcement, CSPM tooling, CI/CD security gates, and runtime monitoring.

---

## Architecture

The framework is organized into four sequential defense layers:

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 1 — PREVENTION                                        │
│  Checkov · tfsec · OPA/Rego                                 │
│  Blocks misconfigs in Terraform code before deployment       │
├─────────────────────────────────────────────────────────────┤
│  Layer 2 — DETECTION (CI/CD)                                 │
│  Prowler · Trivy · GitHub Security tab (SARIF)              │
│  Scans IaC and live AWS environment, surfaces findings       │
├─────────────────────────────────────────────────────────────┤
│  Layer 3 — RUNTIME MONITORING                                │
│  AWS Security Hub · EventBridge · SNS                       │
│  Aggregates findings at runtime, alerts on HIGH/CRITICAL     │
├─────────────────────────────────────────────────────────────┤
│  Layer 4 — REMEDIATION                                       │
│  Scenario runbooks · before/after Terraform · IAM guidance  │
│  Actionable fix guidance for each misconfiguration type      │
└─────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Category | Tools |
|---|---|
| Infrastructure / IaC | Terraform |
| Policy Enforcement | OPA (Open Policy Agent), Checkov, tfsec |
| CSPM / Scanning | Prowler, Trivy |
| Runtime Monitoring | AWS Security Hub, EventBridge, SNS |
| CI/CD | GitHub Actions |
| Cloud | AWS (primary) |
| Reporting | SARIF, GitHub Security tab |

---

## Repository Structure

```
.
├── terraform/              # Base AWS demo environment
│   └── security_hub.tf     # AWS Security Hub provisioning
├── opa/                    # OPA/Rego policies and unit tests
│   └── tests/
├── scenarios/              # Misconfiguration test cases
│   ├── s3-public-access/
│   ├── iam-wildcard/
│   └── open-security-group/
├── .github/
│   └── workflows/
│       └── security-gates.yml  # CI/CD scanning pipeline
└── docs/
    ├── architecture.md
    ├── policies.md
    ├── runtime-monitoring.md
    ├── security-tab.md
    ├── remediation-runbooks.md
    └── lessons-learned.md
```

---

## Misconfiguration Scenarios

Each scenario lives in `scenarios/` and includes intentionally misconfigured Terraform, a layer-by-layer breakdown of which tools catch it, and a remediation runbook.

| Scenario | Risk | Caught By |
|---|---|---|
| S3 public access | Data exposure | OPA, Checkov, tfsec, Prowler, Security Hub |
| Overpermissioned IAM role | Privilege escalation | OPA, Checkov, tfsec |
| Open security group (0.0.0.0/0) | Unauthorized access | OPA, Checkov, tfsec, Prowler |

---

## CI/CD Security Gates

The GitHub Actions workflow (`.github/workflows/security-gates.yml`) runs on every push and pull request:

```
push / pull_request
       │
       ├── checkov        → SARIF → GitHub Security tab
       ├── tfsec          → SARIF → GitHub Security tab
       ├── opa            → policy evaluation
       ├── trivy          → SARIF → GitHub Security tab
       └── prowler        → SARIF + HTML artifact
```

Any violation blocks the merge.

---

## Milestones

| # | Milestone | Description |
|---|---|---|
| 1 | Foundation & Architecture | Repo structure, Terraform base, architecture docs, CI skeleton |
| 2 | Preventive Layer | Checkov, tfsec, OPA integrated into CI/CD |
| 3 | Detective Layer | Prowler, Trivy, SARIF consolidated in Security tab |
| 4 | Runtime Monitoring | AWS Security Hub, EventBridge alerting |
| 5 | Scenarios & Remediation | Misconfiguration test cases and runbooks |

---

## Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [Checkov](https://www.checkov.io/) — `pip install checkov`
- [tfsec](https://aquasecurity.github.io/tfsec/) — `brew install tfsec`
- [OPA](https://www.openpolicyagent.org/) — `brew install opa`
- [Prowler](https://docs.prowler.com/) — `pip install prowler`
- [Trivy](https://aquasecurity.github.io/trivy/) — `brew install trivy`

### Run scanners locally

```bash
# Checkov
checkov -d terraform/

# tfsec
tfsec terraform/

# OPA
opa test opa/tests/

# Trivy
trivy config terraform/
```

### Deploy demo environment

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

---

## License

MIT
