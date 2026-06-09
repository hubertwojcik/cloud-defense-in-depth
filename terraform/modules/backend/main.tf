resource "aws_s3_bucket" "terraform_state" {
    bucket = var.state_bucket_name

    tags = {
        Name = var.state_bucket_name
        Project = var.project
        Environment = var.environment
        ManagedBy = "terraform"
    }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm     = "aws:kms"
            kms_master_key_id = var.kms_key_arn
        }
    }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_dynamodb_table" "terraform_lock" {
    name         = var.state_lock_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }

    point_in_time_recovery {
        enabled = true
    }

    server_side_encryption {
        enabled     = true
        kms_key_arn = var.kms_key_arn
    }

    tags = {
        Project     = var.project
        Environment = var.environment
        ManagedBy   = "terraform"
    }
}