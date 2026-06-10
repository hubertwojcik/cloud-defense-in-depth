resource "aws_sns_topic" "security_alerts" {
  name              = "cloud-defense-in-depth-dev-security-alerts"
  kms_master_key_id = module.encryption.key_arn

  tags = {
    Project     = "cloud-defense-in-depth"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_sns_topic_policy" "security_alerts" {
  arn = aws_sns_topic.security_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEventBridgePublish"
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.security_alerts.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/*"
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "security_hub_findings" {
  name        = "cloud-defense-in-depth-dev-securityhub-findings"
  description = "Trigger on Security Hub HIGH and CRITICAL findings"

  event_pattern = jsonencode({
    source      = ["aws.securityhub"]
    "detail-type" = ["Security Hub Findings - Imported"]
    detail = {
      findings = {
        Severity    = { Label = ["HIGH", "CRITICAL"] }
        RecordState = ["ACTIVE"]
      }
    }
  })

  tags = {
    Project     = "cloud-defense-in-depth"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.security_hub_findings.name
  target_id = "SecurityAlertsSNS"
  arn       = aws_sns_topic.security_alerts.arn

  input_transformer {
    input_paths = {
      title      = "$.detail.findings[0].Title"
      severity   = "$.detail.findings[0].Severity.Label"
      resourceId = "$.detail.findings[0].Resources[0].Id"
      findingId  = "$.detail.findings[0].Id"
      account    = "$.detail.findings[0].AwsAccountId"
      region     = "$.region"
    }
    input_template = "\"Security Hub Alert\\n\\nSeverity : <severity>\\nTitle    : <title>\\nResource : <resourceId>\\nAccount  : <account>\\nRegion   : <region>\\nFinding  : <findingId>\\n\\nView findings: https://console.aws.amazon.com/securityhub/\""
  }
}
