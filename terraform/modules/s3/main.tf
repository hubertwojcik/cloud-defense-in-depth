resource "aws_s3_bucket" "main_bucket" {
    bucket = "${var.project}-${var.environment}-cloud-defense-in-depth-hubert-wojcik"

    tags = {    
        Environment = var.environment
        Project = var.project
        ManagedBy = "terraform"
    }
}

resource "aws_s3_bucket_public_access_block" "main_bucket_public_access_blc" {
    bucket = aws_s3_bucket.main_bucket.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "main_bucket_versioning" {
    bucket = aws_s3_bucket.main_bucket.id

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_server_side_encryption_config" {
    bucket = aws_s3_bucket.main_bucket.id

    rule {
        apply_server_side_encryption_by_default {
            kms_master_key_id = var.kms_key_arn
            sse_algorithm = "aws:kms"
        }
    }
}