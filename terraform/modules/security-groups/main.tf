resource "aws_security_group" "allow_https" {
    name        = "${var.project}-${var.environment}-allow-https"
    description = "Allow HTTPS inbound traffic"
    vpc_id      = var.vpc_id

    tags = {
        Name        = "${var.project}-${var.environment}-allow-https"
        Project     = var.project
        Environment = var.environment
        ManagedBy   = "terraform"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
    security_group_id = aws_security_group.allow_https.id
    cidr_ipv4         = var.allowed_cidr
    from_port         = 443
    ip_protocol       = "tcp"
    to_port           = 443
    description       = "Allow HTTPS inbound from allowed CIDR"
}

resource "aws_vpc_security_group_egress_rule" "allow_https_out" {
  security_group_id = aws_security_group.allow_https.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow HTTPS outbound within VPC CIDR"
}