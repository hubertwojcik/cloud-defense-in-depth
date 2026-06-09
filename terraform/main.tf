module "backend" {
  source = "./modules/backend"

  state_bucket_name     = "cloud-defense-in-depth-terraform-state"
  state_lock_table_name = "cloud-defense-in-depth-state-lock"
  project               = "cloud-defense-in-depth"
  environment           = "dev"

}