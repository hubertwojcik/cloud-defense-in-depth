package policies.s3

test_s3_block_public_acls_pass if {
    count(violation) == 0 with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket_public_access_block.good_bucket",
                "type": "aws_s3_bucket_public_access_block",
                "change": {
                    "after": {
                        "block_public_acls": true
                    }
                }
            }
        ]
    }
}

test_s3_block_public_acls_fail if {
    count(violation) == 1 with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket_public_access_block.bad_bucket",
                "type": "aws_s3_bucket_public_access_block",
                "change": {
                    "after": {
                        "block_public_acls": false
                    }
                }
            }
        ]
    }
}

test_s3_ignores_other_resources if {
    count(violation) == 0 with input as {
        "resource_changes": [
            {
                "address": "aws_s3_bucket.main",
                "type": "aws_s3_bucket",
                "change": {
                    "after": {}
                }
            }
        ]
    }
}
