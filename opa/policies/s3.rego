package policies.s3

violation contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    resource.change.after.block_public_acls != true
    msg := sprintf(
        "S3 bucket '%s' must have block_public_acls = true",
        [resource.address]
    )
}
