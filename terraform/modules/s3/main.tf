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