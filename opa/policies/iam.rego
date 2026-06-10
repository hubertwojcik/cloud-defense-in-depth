package policies.iam

violation contains msg if {
    resource := input.resource_changes[_]

    resource.type == "aws_iam_policy"

    policy := json.unmarshal(resource.change.after.policy)

    statement := policy.Statement[_]
    
    statement.Action == "*"

    msg := sprintf(
        "IAM policy '%s' must not use wildcard Action: \"*\"",
        [resource.address]
    )
}

violation contains msg if {
    resource := input.resource_changes[_]

    resource.type == "aws_iam_policy"

    policy := json.unmarshal(resource.change.after.policy)
    statement := policy.Statement[_]

    statement.Action[_] == "*"

    msg := sprintf(
        "IAM policy '%s' must not use wildcard Action: \"*\"",
        [resource.address]
    )
}
