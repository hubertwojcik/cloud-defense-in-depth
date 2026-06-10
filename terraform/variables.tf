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

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "subnet_az" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "allowed_cidr" {
  type        = string
  description = "CIDR allowed for HTTPS ingress to security group"
  default     = "10.0.0.0/16"
}
