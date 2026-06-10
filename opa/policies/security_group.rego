package policies.security_group

violation[msg] {
    resource := input.resource_changes[_]

    resource.type == "aws_vpc_security_group_ingress_rule"

    resource.change.after.cidr_ipv4 == "0.0.0.0/0"

    blocked_ports := {22, 3389}
    blocked_ports[resource.change.after.from_port]

        msg := sprintf(
        "Security groups '%s' must not allow 0.0.0.0/0 on port 22/3389",
        [resource.address]
    )
}