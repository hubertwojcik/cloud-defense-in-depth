resource "aws_s3_bucket" "terraform_state" {
    bucket = var.state_bucket_name

    tags = {
        Name = var.state_bucket_name
        Project = var.project
        Environment = var.environment
        ManagedBy = "terraform"
    }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_dynamodb_table" "terraform_lock" {
    name = var.state_lock_table_name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }

    tags = {
        Project = var.project
        Environment = var.environment
        ManagedBy = "terraform"
    }
}