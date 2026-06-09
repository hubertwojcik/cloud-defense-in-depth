resource "aws_iam_role" "demo_role" {
    name = "${var.project}-${var.environment}-demo-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        Project     = var.project
        Environment = var.environment
        ManagedBy   = "terraform"
    }
}

resource "aws_iam_policy" "s3_read_write_policy" {
    name = "${var.project}-${var.environment}-s3-read-write-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid    = "S3ReadWrite"
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:DeleteObject",
                    "s3:ListBucket"
                ]
                Resource = [
                    var.bucket_arn,
                    "${var.bucket_arn}/*"
                ]
            }
        ]
    })

    tags = {
        Project     = var.project
        Environment = var.environment
        ManagedBy   = "terraform"
    }
}

resource "aws_iam_role_policy_attachment" "demo_role_policy_attachment" {
    role       = aws_iam_role.demo_role.name
    policy_arn = aws_iam_policy.s3_read_write_policy.arn
}