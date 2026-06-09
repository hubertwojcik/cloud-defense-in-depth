variable "vpc_cidr" {
    type = string
}

variable "project"  {
    type = string
}

variable "environment" {
    type = string
}

variable "vpc_name" {
    type = string    
}

variable "subnet_cidr" {
    type = list(string)
}

variable "subnet_az" {
    type = list(string)
}