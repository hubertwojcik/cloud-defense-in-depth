variable "state_bucket_name" {
    type = string
}

variable "state_lock_table_name" {
    type = string
    default = "terraform-lock-state"
}

variable "project"  {
    type = string
    default = "cloud-defense-in-depth"
}

variable "environment" {
    type = string
    default = "dev"
}