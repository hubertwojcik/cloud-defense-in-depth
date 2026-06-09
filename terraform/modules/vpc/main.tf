resource "aws_vpc" "main_vpc" {
    cidr_block = var.vpc_cidr

    tags = {
        Name = var.vpc_name
        Project = var.project
        Environment = var.environment
        ManagedBy = "terraform"
    }
}

resource "aws_subnet" "first_subnet" {
    vpc_id = aws_vpc.main_vpc.id
    availability_zone = var.subnet_az[0]

    cidr_block = var.subnet_cidr[0]
}

resource "aws_subnet" "second_subnet" {
    vpc_id = aws_vpc.main_vpc.id
    availability_zone = var.subnet_az[1]
    
    cidr_block = var.subnet_cidr[1]
}