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

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
    name              = "${var.project}-${var.environment}-vpc-flow-logs"
    retention_in_days = 365
    kms_key_id        = var.kms_key_arn
}

resource "aws_flow_log" "main_vpc_flow_logs" {
    iam_role_arn = aws_iam_role.flow_log_role.arn
    log_destination = aws_cloudwatch_log_group.cloudwatch_log_group.arn
    traffic_type = "ALL"
    vpc_id = aws_vpc.main_vpc.id
    log_destination_type = "cloud_watch_logs"
}

resource "aws_iam_role" "flow_log_role" {
    name = "${var.project}-${var.environment}-flow-log-role"
    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement":[
            {
                "Action":"sts:AssumeRole",
                "Principal":{
                    "Service": "vpc-flow-logs.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid":""
            }
        ]
    })
}

# tfsec:ignore:aws-iam-no-policy-wildcards - logs:CreateLogGroup does not support resource-level permissions in AWS
resource "aws_iam_policy" "flow_log_policy" {
    name = "${var.project}-${var.environment}-flow-log-policy"
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "VPCFlowLogsAccess",
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:DescribeLogGroups",
                    "logs:DescribeLogStreams",
                    "logs:PutLogEvents"
                ],
                "Resource": "*"
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "flow_log_policy_attachment" {
    role = aws_iam_role.flow_log_role.name
    policy_arn = aws_iam_policy.flow_log_policy.arn
}