variable "project" {
  type    = string
  default = "cloud-defense-in-depth"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "alert_email" {
  type        = string
  description = "Email address to receive Security Hub HIGH/CRITICAL alerts"
}