package policies.iam

test_iam_specific_actions_pass if {
    count(violation) == 0 with input as {
        "resource_changes": [
            {
                "address": "aws_iam_policy.good_policy",
                "type": "aws_iam_policy",
                "change": {
                    "after": {
                        "policy": "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"s3:GetObject\",\"s3:PutObject\"],\"Resource\":\"*\"}]}"
                    }
                }
            }
        ]
    }
}

test_iam_wildcard_action_string_fail if {
    count(violation) == 1 with input as {
        "resource_changes": [
            {
                "address": "aws_iam_policy.bad_policy",
                "type": "aws_iam_policy",
                "change": {
                    "after": {
                        "policy": "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"*\",\"Resource\":\"*\"}]}"
                    }
                }
            }
        ]
    }
}

test_iam_wildcard_action_array_fail if {
    count(violation) == 1 with input as {
        "resource_changes": [
            {
                "address": "aws_iam_policy.bad_policy_array",
                "type": "aws_iam_policy",
                "change": {
                    "after": {
                        "policy": "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"*\"],\"Resource\":\"*\"}]}"
                    }
                }
            }
        ]
    }
}

test_iam_ignores_other_resources if {
    count(violation) == 0 with input as {
        "resource_changes": [
            {
                "address": "aws_iam_role.demo_role",
                "type": "aws_iam_role",
                "change": {
                    "after": {}
                }
            }
        ]
    }
}
