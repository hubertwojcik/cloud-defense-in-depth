package policies.security_group

test_sg_allows_https if {
    count(violation) == 0 with input as {
        "resource_changes": [
            {
                "address": "aws_vpc_security_group_ingress_rule.allow_https",
                "type": "aws_vpc_security_group_ingress_rule",
                "change": {
                    "after": {
                        "cidr_ipv4": "10.0.0.0/8",
                        "from_port": 443
                    }
                }
            }
        ]
    }
}

test_sg_blocks_ssh_open_to_world if {
    count(violation) == 1 with input as {
        "resource_changes": [
            {
                "address": "aws_vpc_security_group_ingress_rule.bad_ssh",
                "type": "aws_vpc_security_group_ingress_rule",
                "change": {
                    "after": {
                        "cidr_ipv4": "0.0.0.0/0",
                        "from_port": 22
                    }
                }
            }
        ]
    }
}

test_sg_blocks_rdp_open_to_world if {
    count(violation) == 1 with input as {
        "resource_changes": [
            {
                "address": "aws_vpc_security_group_ingress_rule.bad_rdp",
                "type": "aws_vpc_security_group_ingress_rule",
                "change": {
                    "after": {
                        "cidr_ipv4": "0.0.0.0/0",
                        "from_port": 3389
                    }
                }
            }
        ]
    }
}

test_sg_ignores_other_resources if {
    count(violation) == 0 with input as {
        "resource_changes": [
            {
                "address": "aws_security_group.main",
                "type": "aws_security_group",
                "change": {
                    "after": {
                        "cidr_ipv4": "0.0.0.0/0",
                        "from_port": 22
                    }
                }
            }
        ]
    }
}
