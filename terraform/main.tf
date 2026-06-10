module "encryption" {
  source      = "./modules/encryption"
  project     = var.project
  environment = var.environment
}

module "backend" {
  source = "./modules/backend"

  state_bucket_name     = "${var.project}-terraform-state"
  state_lock_table_name = "${var.project}-state-lock"
  project               = var.project
  environment           = var.environment
  kms_key_arn           = module.encryption.key_arn
}

module "iam_ci" {
  source = "./modules/iam-ci"

  project              = var.project
  environment          = var.environment
  state_bucket_arn     = module.backend.state_bucket_arn
  state_lock_table_arn = module.backend.state_lock_table_arn
  kms_key_arn          = module.encryption.key_arn
}

module "vpc" {
  source = "./modules/vpc"

  project     = var.project
  environment = var.environment
  vpc_name    = "${var.project}-${var.environment}"
  vpc_cidr    = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
  subnet_az   = var.subnet_az
  kms_key_arn = module.encryption.key_arn
}

module "s3" {
  source = "./modules/s3"

  project     = var.project
  environment = var.environment
  kms_key_arn = module.encryption.key_arn
}

module "iam" {
  source = "./modules/iam"

  project     = var.project
  environment = var.environment
  bucket_arn  = module.s3.bucket_arn
}

module "security_groups" {
  source = "./modules/security-groups"

  project      = var.project
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
  allowed_cidr = var.allowed_cidr
}