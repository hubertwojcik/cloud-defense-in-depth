# Scenario: Open Security Group (SSH/RDP Exposed to Internet)

## Real-World Risk

A security group allowing `0.0.0.0/0` on port 22 (SSH) or port 3389 (RDP) exposes EC2 instances directly to the entire internet. This is one of the most exploited misconfigurations in cloud environments:

- Automated bots scan the entire internet for open SSH/RDP within minutes of deployment
- Brute-force and credential stuffing attacks begin immediately
- If credentials are weak or a vulnerability exists, attacker gets shell access to the instance
- From there: lateral movement inside the VPC, metadata service abuse (IMDSv1 → role credential theft), data exfiltration

AWS Security Hub and CIS benchmark both flag this as a critical finding.

---

## What This Scenario Demonstrates

| Misconfiguration | Resource |
|---|---|
| SSH (port 22) open to `0.0.0.0/0` | `aws_vpc_security_group_ingress_rule.scenario_ssh_open` |
| RDP (port 3389) open to `0.0.0.0/0` | `aws_vpc_security_group_ingress_rule.scenario_rdp_open` |

---

## Which Defense Layer Catches It

### Layer 1 — Prevention (CI/CD)

| Tool | Rule | What it catches |
|---|---|---|
| **OPA** | `security_group.rego` | `cidr_ipv4 == "0.0.0.0/0"` on port 22 or 3389 |
| **Checkov** | CKV_AWS_25 | Security group allows 0.0.0.0/0 on port 22 |
| **Checkov** | CKV_AWS_27 | Security group allows 0.0.0.0/0 on port 3389 |
| **tfsec** | AVD-AWS-0105 | Security group rule allows ingress from 0.0.0.0/0 |
| **Trivy** | AVD-AWS-0105 | Security group rule allows ingress from 0.0.0.0/0 |

### Layer 2 — Runtime Detection

| Tool | Check |
|---|---|
| **Prowler** | `ec2_securitygroup_allow_ingress_from_internet_to_port_22` |
| **Prowler** | `ec2_securitygroup_allow_ingress_from_internet_to_tcp_port_3389` |
| **Security Hub** | EC2.19 — Security groups should not allow unrestricted access to high-risk ports |

---

## Expected CI Failure Output

### OPA
```
{
  "msg": "Security groups 'aws_vpc_security_group_ingress_rule.scenario_ssh_open' must not allow 0.0.0.0/0 on port 22/3389"
}
{
  "msg": "Security groups 'aws_vpc_security_group_ingress_rule.scenario_rdp_open' must not allow 0.0.0.0/0 on port 22/3389"
}
OPA policy violations found!
Error: Process completed with exit code 1
```

### Checkov
```
Check: CKV_AWS_25: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 22"
FAILED for resource: aws_vpc_security_group_ingress_rule.scenario_ssh_open

Check: CKV_AWS_27: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 3389"
FAILED for resource: aws_vpc_security_group_ingress_rule.scenario_rdp_open
```

### tfsec / Trivy
```
AVD-AWS-0105  Security group rule allows ingress from public internet
CRITICAL  terraform/scenario_open_sg.tf (scenario_ssh_open)
CRITICAL  terraform/scenario_open_sg.tf (scenario_rdp_open)
```

---

## Remediation Runbook

### Option A — Restrict SSH to known CIDR ranges

Use this when SSH access is genuinely required (e.g., bastion host) and the source IP is predictable.

**Before (misconfigured):**
```hcl
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}
```

**After (restricted):**
```hcl
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  cidr_ipv4   = var.allowed_cidr   # e.g. "203.0.113.10/32" — office IP
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}
```

For dynamic IPs, use a prefix list managed by your VPN or Zero Trust gateway instead of a static CIDR.

---

### Option B — Remove SSH entirely, use AWS Systems Manager Session Manager

This is the recommended approach for production. SSM Session Manager provides shell access without any open inbound ports:

1. **Attach the SSM managed policy to the EC2 instance role:**
```hcl
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
```

2. **Remove all SSH/RDP ingress rules** — the security group needs no inbound rules at all.

3. **Connect via AWS CLI:**
```bash
aws ssm start-session --target i-0123456789abcdef0 --region eu-north-1
```

Or via the AWS Console: **EC2 → Instances → Connect → Session Manager**.

**Advantages over SSH:**
- No open ports on the security group
- No SSH keys to manage or rotate
- All sessions logged to CloudTrail and optionally to S3/CloudWatch
- IAM-controlled access (not key-based)

---

## Fixed Terraform (Option B — no SSH)

```hcl
resource "aws_security_group" "ec2_sg" {
  name        = "cloud-defense-in-depth-ec2-sg"
  description = "EC2 security group - no inbound access required (SSM used for access)"
  vpc_id      = module.vpc.vpc_id

  # No ingress rules — SSM Session Manager requires no open ports

  egress {
    description = "HTTPS to AWS services (SSM, S3, EC2 metadata)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = "cloud-defense-in-depth"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
```

---

## Defense-in-Depth Flow

```
Developer commits 0.0.0.0/0 on port 22/3389
          │
          ▼
    CI Pipeline (PR opened)
    ├── OPA    → FAIL: 0.0.0.0/0 on port 22 detected in tfplan.json
    ├── Checkov → FAIL: CKV_AWS_25, CKV_AWS_27
    ├── tfsec  → FAIL: AVD-AWS-0105 (x2)
    └── Trivy  → FAIL: AVD-AWS-0105 (x2)

    PR is blocked — open SG never reaches AWS
          │
          │ (hypothetical: CI bypassed)
          ▼
    Prowler daily scan → ec2_securitygroup_allow_ingress_from_internet_to_port_22 FAIL
    Security Hub → EC2.19 CRITICAL finding
    EventBridge rule → triggered
    SNS → email alert within 5 minutes
```
