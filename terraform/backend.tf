terraform {
    backend "s3" {
        bucket = "cloud-defense-in-depth-terraform-state"
        key = "terraform.tfstate"
        region = "eu-north-1"
        dynamodb_table = "cloud-defense-in-depth-state-lock"
        encrypt = true       
    }
}