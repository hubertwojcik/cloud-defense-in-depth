resource "aws_iam_user" "ci_user" {
    name = "${var.project}-${var.environment}-ci-user"

    tags = {
        Project     = var.project
        Environment = var.environment
        ManagedBy   = "terraform"
    }
}

resource "aws_iam_policy" "ci_policy" {
    name = "${var.project}-${var.environment}-ci-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid    = "TerraformStateS3"
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:ListBucket",
                    "s3:GetBucketPolicy",
                    "s3:GetBucketAcl",
                    "s3:GetBucketLocation",
                    "s3:GetEncryptionConfiguration",
                    "s3:GetBucketVersioning",
                    "s3:GetBucketPublicAccessBlock"
                ]
                Resource = [
                    var.state_bucket_arn,
                    "${var.state_bucket_arn}/*"
                ]
            },
            {
                Sid    = "TerraformStateLock"
                Effect = "Allow"
                Action = [
                    "dynamodb:GetItem",
                    "dynamodb:PutItem",
                    "dynamodb:DeleteItem"
                ]
                Resource = var.state_lock_table_arn
            },
            {
                Sid    = "KMSAccess"
                Effect = "Allow"
                Action = [
                    "kms:Decrypt",
                    "kms:GenerateDataKey",
                    "kms:DescribeKey"
                ]
                Resource = var.kms_key_arn
            },
            {
                Sid    = "EC2ReadOnly"
                Effect = "Allow"
                Action = [
                    "ec2:Describe*"
                ]
                Resource = "*"
            },
            {
                Sid    = "VPCReadOnly"
                Effect = "Allow"
                Action = [
                    "ec2:DescribeVpcs",
                    "ec2:DescribeSubnets",
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeFlowLogs"
                ]
                Resource = "*"
            },
            {
                Sid    = "IAMReadOnly"
                Effect = "Allow"
                Action = [
                    "iam:Get*",
                    "iam:List*"
                ]
                Resource = "*"
            },
            {
                Sid    = "CloudWatchReadOnly"
                Effect = "Allow"
                Action = [
                    "logs:DescribeLogGroups",
                    "logs:DescribeLogStreams"
                ]
                Resource = "*"
            }
        ]
    })

    tags = {
        Project     = var.project
        Environment = var.environment
        ManagedBy   = "terraform"
    }
}

resource "aws_iam_user_policy_attachment" "ci_user_policy" {
    user       = aws_iam_user.ci_user.name
    policy_arn = aws_iam_policy.ci_policy.arn
}
