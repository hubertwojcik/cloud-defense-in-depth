# Runtime Monitoring — EventBridge + SNS Alerting

## Overview

This layer detects misconfigurations in live AWS infrastructure and delivers email alerts within minutes. It complements the CI/CD prevention layer (Checkov, tfsec, OPA, Trivy) by catching issues that occur outside of the deployment pipeline — such as manual changes in the AWS console or configuration drift over time.

---

## Architecture

```
AWS Security Hub
      │
      │  finding imported (HIGH or CRITICAL, ACTIVE)
      ▼
EventBridge Rule
(cloud-defense-in-depth-dev-securityhub-findings)
      │
      │  matched event → formatted message
      ▼
SNS Topic
(cloud-defense-in-depth-dev-security-alerts)
      │
      │  email protocol
      ▼
Email inbox (alert_email variable)
```

---

## Components

### EventBridge Rule

Listens for Security Hub findings matching:
- **Source**: `aws.securityhub`
- **Detail type**: `Security Hub Findings - Imported`
- **Severity**: `HIGH` or `CRITICAL`
- **Record state**: `ACTIVE`

Only active, newly imported findings trigger the rule. Archived or suppressed findings are ignored.

### Input Transformer

EventBridge extracts fields from the finding JSON and formats a human-readable email:

```
Security Hub Alert

Severity : CRITICAL
Title    : S3 bucket does not have server access logging enabled
Resource : arn:aws:s3:::my-bucket
Account  : 123456789012
Region   : eu-north-1
Finding  : arn:aws:securityhub:eu-north-1:123456789012:subscription/...

View findings: https://console.aws.amazon.com/securityhub/
```

### SNS Topic

Encrypted at rest with KMS. Only EventBridge (scoped to the account via `AWS:SourceAccount` condition) can publish to this topic.

### Email Subscription

Configured via `var.alert_email` in `terraform/terraform.tfvars`. After `terraform apply`, AWS sends a confirmation email — the subscription is inactive until confirmed.

---

## How to Test

### 1. Deploy the infrastructure

```bash
cd terraform
terraform apply
```

Confirm the SNS subscription email that arrives in your inbox.

### 2. Introduce a misconfiguration

Create a public S3 bucket or disable encryption on an existing resource. Security Hub will detect it within 1-5 minutes and import a finding.

Alternatively, trigger a finding manually using the AWS CLI:

```bash
aws securityhub send-findings-import --findings file://test-finding.json --region eu-north-1
```

### 3. Confirm the alert

Check your inbox. The alert should arrive within 5 minutes of the finding being imported into Security Hub.

---

## Terraform Resources

| Resource | Type | Purpose |
|---|---|---|
| `aws_sns_topic.security_alerts` | SNS | Alert delivery channel, KMS encrypted |
| `aws_sns_topic_subscription.email` | SNS subscription | Email endpoint |
| `aws_sns_topic_policy.security_alerts` | SNS policy | Allow EventBridge to publish |
| `aws_cloudwatch_event_rule.security_hub_findings` | EventBridge rule | Filter HIGH/CRITICAL findings |
| `aws_cloudwatch_event_target.sns` | EventBridge target | Route finding to SNS with formatted message |

---

## Defense-in-Depth Layer

| Layer | Tool | When |
|---|---|---|
| Prevention | Checkov, tfsec, OPA, Trivy | Before deploy (PR gate) |
| Detection | Prowler | Daily scheduled scan |
| **Runtime alerting** | **EventBridge + SNS** | **Within minutes of finding** |

The key difference from Prowler: Prowler runs on a schedule. EventBridge fires the moment Security Hub imports a finding — whether that finding comes from Prowler, AWS Config, or a third-party integration.
