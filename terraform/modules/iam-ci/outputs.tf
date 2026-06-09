output "ci_user_name" {
    value = aws_iam_user.ci_user.name
}

output "ci_user_arn" {
    value = aws_iam_user.ci_user.arn
}
