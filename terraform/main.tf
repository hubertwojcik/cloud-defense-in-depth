module "encryption" {
  source      = "./modules/encryption"
  project     = "cloud-defense-in-depth"
  environment = "dev"
}

module "backend" {
  source = "./modules/backend"

  state_bucket_name     = "cloud-defense-in-depth-terraform-state"
  state_lock_table_name = "cloud-defense-in-depth-state-lock"
  project               = "cloud-defense-in-depth"
  environment           = "dev"
  kms_key_arn           = module.encryption.key_arn
}

module "iam_ci" {
  source = "./modules/iam-ci"

  project              = "cloud-defense-in-depth"
  environment          = "dev"
  state_bucket_arn     = module.backend.state_bucket_arn
  state_lock_table_arn = module.backend.state_lock_table_arn
  kms_key_arn          = module.encryption.key_arn
}