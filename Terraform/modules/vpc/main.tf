####################
# define terraform #
####################
terraform {
    required_version = ">=1.0"
}

####################
# define resources #
####################
locals {

  env = terraform.workspace
  max_subnet_length = max(
    length("${var.private_subnets[local.env]}")
  )
  nat_gateway_count = "${var.single_nat_gateway[local.env]}" ? 1 : "${var.one_nat_gateway_per_az[local.env]}" ? length("${var.azs[local.env]}") : local.max_subnet_length

  # Use `local.vpc_id` to give a hint to Terraform that subnets should be deleted before secondary CIDR blocks can be free!
  vpc_id = element(
    concat(
      aws_vpc_ipv4_cidr_block_association.this.*.vpc_id,
      aws_vpc.this.*.id,
      [""],
    ),
    0,
  )
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  count = "${var.create_vpc[local.env]}" ? 1 : 0

  cidr_block                       = "${var.cidr[local.env]}"
  instance_tenancy                 = "${var.instance_tenancy[local.env]}"
  enable_dns_hostnames             = "${var.enable_dns_hostnames[local.env]}"
  enable_dns_support               = "${var.enable_dns_support[local.env]}"
  enable_classiclink               = "${var.enable_classiclink[local.env]}"
  enable_classiclink_dns_support   = "${var.enable_classiclink_dns_support[local.env]}"
  assign_generated_ipv6_cidr_block = "${var.enable_ipv6[local.env]}"

  tags = merge(
    {
      "Name" = format("%s", "${local.env}-VPC")
    },
    "${var.tags[local.env]}",
    "${var.vpc_tags[local.env]}",
  )

  lifecycle {
    prevent_destroy = "${var.prevent_destroy_vpc[local.env]}"
    create_before_destroy = "${var.create_before_destroy_vpc[local.env]}"
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = "${var.create_vpc[local.env]}" && length("${var.secondary_cidr_blocks[local.env]}") > 0 ? length("${var.secondary_cidr_blocks[local.env]}") : 0

  vpc_id = aws_vpc.this[0].id

  cidr_block = element("${var.secondary_cidr_blocks[local.env]}", count.index)
}

resource "aws_default_security_group" "this" {
  count = "${var.create_vpc[local.env]}" && "${var.manage_default_security_group[local.env]}" ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  dynamic "ingress" {
    for_each = "${var.default_security_group_ingress[local.env]}"
    content {
      self             = lookup(ingress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(ingress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(ingress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(ingress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(ingress.value, "security_groups", "")))
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", 0)
      to_port          = lookup(ingress.value, "to_port", 0)
      protocol         = lookup(ingress.value, "protocol", "-1")
    }
  }

  dynamic "egress" {
    for_each = "${var.default_security_group_egress[local.env]}"
    content {
      self             = lookup(egress.value, "self", null)
      cidr_blocks      = compact(split(",", lookup(egress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(egress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(egress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(egress.value, "security_groups", "")))
      description      = lookup(egress.value, "description", null)
      from_port        = lookup(egress.value, "from_port", 0)
      to_port          = lookup(egress.value, "to_port", 0)
      protocol         = lookup(egress.value, "protocol", "-1")
    }
  }

  tags = merge(
    {
      "Name" = format("%s", "${var.default_security_group_name[local.env]}")
    },
    "${var.tags[local.env]}",
    "${var.default_security_group_tags[local.env]}",
  )
}

################################################################################
# DHCP Options Set
################################################################################

resource "aws_vpc_dhcp_options" "this" {
  count = "${var.create_vpc[local.env]}" && "${var.enable_dhcp_options[local.env]}" ? 1 : 0

  domain_name          = "${var.dhcp_options_domain_name[local.env]}"
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = "${var.dhcp_options_ntp_servers[local.env]}"
  netbios_name_servers = "${var.dhcp_options_netbios_name_servers[local.env]}"
  netbios_node_type    = "${var.dhcp_options_netbios_node_type[local.env]}"

  tags = merge(
    {
      "Name" = format("%s", "${local.env}-VPC")
    },
    "${var.tags[local.env]}",
    "${var.dhcp_options_tags[local.env]}",
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = "${var.create_vpc[local.env]}" && "${var.enable_dhcp_options[local.env]}" ? 1 : 0

  vpc_id          = local.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = "${var.create_vpc[local.env]}" && "${var.create_igw[local.env]}" && length("${var.public_subnets[local.env]}") > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format("%s", "${local.env}-VPC")
    },
    "${var.tags[local.env]}",
    "${var.igw_tags[local.env]}",
  )
}

resource "aws_egress_only_internet_gateway" "this" {
  count = "${var.create_vpc[local.env]}" && "${var.create_egress_only_igw[local.env]}" && "${var.enable_ipv6[local.env]}" && local.max_subnet_length > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format("%s", "${local.env}-VPC")
    },
    "${var.tags[local.env]}",
    "${var.igw_tags[local.env]}",
  )
}

################################################################################
# Default route
################################################################################

resource "aws_default_route_table" "default" {
  count = "${var.create_vpc[local.env]}" && "${var.manage_default_route_table[local.env]}" ? 1 : 0

  default_route_table_id = aws_vpc.this[0].default_route_table_id
  propagating_vgws       = "${var.default_route_table_propagating_vgws[local.env]}"

  dynamic "route" {
    for_each = "${var.default_route_table_routes[local.env]}"
    content {
      # One of the following destinations must be provided
      cidr_block      = route.value.cidr_block
      ipv6_cidr_block = lookup(route.value, "ipv6_cidr_block", null)

      # One of the following targets must be provided
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                = lookup(route.value, "gateway_id", null)
      instance_id               = lookup(route.value, "instance_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = merge(
    { "Name" = "${local.env}-VPC" },
    "${var.tags[local.env]}",
    "${var.default_route_table_tags[local.env]}",
  )
}

################################################################################
# Publiс routes
################################################################################

resource "aws_route_table" "public" {
  count = "${var.create_vpc[local.env]}" && length("${var.public_subnets[local.env]}") > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format("%s-${var.public_subnet_suffix}", "${local.env}-VPC")
    },
    "${var.tags[local.env]}",
    "${var.public_route_table_tags[local.env]}",
  )
}

resource "aws_route" "public_internet_gateway" {
  count = "${var.create_vpc[local.env]}" && "${var.create_igw[local.env]}" && length("${var.public_subnets[local.env]}") > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "public_internet_gateway_ipv6" {
  count = "${var.create_vpc[local.env]}" && "${var.create_igw[local.env]}" && "${var.enable_ipv6[local.env]}" && length("${var.public_subnets[local.env]}") > 0 ? 1 : 0

  route_table_id              = aws_route_table.public[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.this[0].id
}

################################################################################
# Private routes
# There are as many routing tables as the number of NAT gateways
################################################################################

resource "aws_route_table" "private" {
  count = "${var.create_vpc[local.env]}" && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = "${var.single_nat_gateway[local.env]}" ? "${local.env}-VPC-${var.private_subnet_suffix}" : format(
        "%s-${var.private_subnet_suffix}-%s",
        "${var.name[local.env]}",
        element("${var.azs[local.env]}", count.index),
      )
    },
    "${var.tags[local.env]}",
    "${var.private_route_table_tags[local.env]}",
  )
}

################################################################################
# Public subnet
################################################################################

resource "aws_subnet" "public" {
  count = "${var.create_vpc[local.env]}" && length("${var.public_subnets[local.env]}") > 0 && (false == "${var.one_nat_gateway_per_az[local.env]}" || length("${var.public_subnets[local.env]}") >= length("${var.azs[local.env]}")) ? length("${var.public_subnets[local.env]}") : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = element(concat("${var.public_subnets[local.env]}", [""]), count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element("${var.azs[local.env]}", count.index))) > 0 ? element("${var.azs[local.env]}", count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element("${var.azs[local.env]}", count.index))) == 0 ? element("${var.azs[local.env]}", count.index) : null
  map_public_ip_on_launch         = "${var.map_public_ip_on_launch[local.env]}"
  assign_ipv6_address_on_creation = "${var.public_subnet_assign_ipv6_address_on_creation[local.env]}" == null ? "${var.assign_ipv6_address_on_creation[local.env]}" : "${var.public_subnet_assign_ipv6_address_on_creation[local.env]}"

  ipv6_cidr_block = "${var.enable_ipv6[local.env]}" && length("${var.public_subnet_ipv6_prefixes[local.env]}") > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, "${var.public_subnet_ipv6_prefixes[local.env]}"[count.index]) : null

  tags = merge(
    {
      "Name" = format(
        "%s-${var.public_subnet_suffix}-%s",
        element("${var.public_subnets_name[local.env]}", count.index),
        element("${var.azs[local.env]}", count.index),
      )
    },
    "${var.tags[local.env]}",
    "${var.public_subnet_tags[local.env]}",
  )
}

################################################################################
# Private subnet
################################################################################

resource "aws_subnet" "private" {
  count = "${var.create_vpc[local.env]}" && length("${var.private_subnets[local.env]}") > 0 ? length("${var.private_subnets[local.env]}") : 0

  vpc_id                          = local.vpc_id
  cidr_block                      = "${var.private_subnets[local.env]}"[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element("${var.azs[local.env]}", count.index))) > 0 ? element("${var.azs[local.env]}", count.index) : null
  availability_zone_id            = length(regexall("^[a-z]{2}-", element("${var.azs[local.env]}", count.index))) == 0 ? element("${var.azs[local.env]}", count.index) : null
  assign_ipv6_address_on_creation = "${var.private_subnet_assign_ipv6_address_on_creation[local.env]}" == null ? "${var.assign_ipv6_address_on_creation[local.env]}" : "${var.private_subnet_assign_ipv6_address_on_creation[local.env]}"

  ipv6_cidr_block = "${var.enable_ipv6[local.env]}" && length("${var.private_subnet_ipv6_prefixes[local.env]}") > 0 ? cidrsubnet(aws_vpc.this[0].ipv6_cidr_block, 8, "${var.private_subnet_ipv6_prefixes[local.env]}"[count.index]) : null

  tags = merge(
    {
      "Name" = format(
        "%s-${var.private_subnet_suffix}-%s",
        element("${var.private_subnets_name[local.env]}", count.index),
        element("${var.azs[local.env]}", count.index),
      )
    },
    "${var.tags[local.env]}",
    "${var.private_subnet_tags[local.env]}",
  )
}

################################################################################
# Default Network ACLs
################################################################################

resource "aws_default_network_acl" "this" {
  count = "${var.create_vpc[local.env]}" && "${var.manage_default_network_acl[local.env]}" ? 1 : 0

  default_network_acl_id = element(concat(aws_vpc.this.*.default_network_acl_id, [""]), 0)

  # The value of subnet_ids should be any subnet IDs that are not set as subnet_ids
  #   for any of the non-default network ACLs
  subnet_ids = setsubtract(
    compact(flatten([
      aws_subnet.public.*.id,
      aws_subnet.private.*.id,
    ])),
    compact(flatten([
      aws_network_acl.public.*.subnet_ids,
      aws_network_acl.private.*.subnet_ids,
    ]))
  )

  dynamic "ingress" {
    for_each = "${var.default_network_acl_ingress[local.env]}"
    content {
      action          = ingress.value.action
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      from_port       = ingress.value.from_port
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
      protocol        = ingress.value.protocol
      rule_no         = ingress.value.rule_no
      to_port         = ingress.value.to_port
    }
  }
  dynamic "egress" {
    for_each = "${var.default_network_acl_egress[local.env]}"
    content {
      action          = egress.value.action
      cidr_block      = lookup(egress.value, "cidr_block", null)
      from_port       = egress.value.from_port
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
      protocol        = egress.value.protocol
      rule_no         = egress.value.rule_no
      to_port         = egress.value.to_port
    }
  }

  tags = merge(
    {
      "Name" = format("%s", var.default_network_acl_name)
    },
    "${var.tags[local.env]}",
    "${var.default_network_acl_tags[local.env]}",
  )
}

################################################################################
# Public Network ACLs
################################################################################

resource "aws_network_acl" "public" {
  count = "${var.create_vpc[local.env]}" && "${var.public_dedicated_network_acl[local.env]}" && length("${var.public_subnets[local.env]}") > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.this.*.id, [""]), 0)
  subnet_ids = aws_subnet.public.*.id

  tags = merge(
    {
      "Name" = format("%s-${var.public_subnet_suffix}", "${local.env}-VPC")
    },
    "${var.tags[local.env]}",
    "${var.public_acl_tags[local.env]}",
  )
}

resource "aws_network_acl_rule" "public_inbound" {
  count = "${var.create_vpc[local.env]}" && "${var.public_dedicated_network_acl[local.env]}" && length("${var.public_subnets[local.env]}") > 0 ? length("${var.public_inbound_acl_rules[local.env]}") : 0

  network_acl_id = aws_network_acl.public[0].id

  egress          = false
  rule_number     = "${var.public_inbound_acl_rules[local.env]}"[count.index]["rule_number"]
  rule_action     = "${var.public_inbound_acl_rules[local.env]}"[count.index]["rule_action"]
  from_port       = lookup("${var.public_inbound_acl_rules[local.env]}"[count.index], "from_port", null)
  to_port         = lookup("${var.public_inbound_acl_rules[local.env]}"[count.index], "to_port", null)
  icmp_code       = lookup("${var.public_inbound_acl_rules[local.env]}"[count.index], "icmp_code", null)
  icmp_type       = lookup("${var.public_inbound_acl_rules[local.env]}"[count.index], "icmp_type", null)
  protocol        = "${var.public_inbound_acl_rules[local.env]}"[count.index]["protocol"]
  cidr_block      = lookup("${var.public_inbound_acl_rules[local.env]}"[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup("${var.public_inbound_acl_rules[local.env]}"[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "public_outbound" {
  count = "${var.create_vpc[local.env]}" && "${var.public_dedicated_network_acl[local.env]}" && length("${var.public_subnets[local.env]}") > 0 ? length("${var.public_outbound_acl_rules[local.env]}") : 0

  network_acl_id = aws_network_acl.public[0].id

  egress          = true
  rule_number     = "${var.public_outbound_acl_rules[local.env]}"[count.index]["rule_number"]
  rule_action     = "${var.public_outbound_acl_rules[local.env]}"[count.index]["rule_action"]
  from_port       = lookup("${var.public_outbound_acl_rules[local.env]}"[count.index], "from_port", null)
  to_port         = lookup("${var.public_outbound_acl_rules[local.env]}"[count.index], "to_port", null)
  icmp_code       = lookup("${var.public_outbound_acl_rules[local.env]}"[count.index], "icmp_code", null)
  icmp_type       = lookup("${var.public_outbound_acl_rules[local.env]}"[count.index], "icmp_type", null)
  protocol        = "${var.public_outbound_acl_rules[local.env]}"[count.index]["protocol"]
  cidr_block      = lookup("${var.public_outbound_acl_rules[local.env]}"[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup("${var.public_outbound_acl_rules[local.env]}"[count.index], "ipv6_cidr_block", null)
}

################################################################################
# Private Network ACLs
################################################################################

resource "aws_network_acl" "private" {
  count = "${var.create_vpc[local.env]}" && "${var.private_dedicated_network_acl[local.env]}" && length("${var.private_subnets[local.env]}") > 0 ? 1 : 0

  vpc_id     = element(concat(aws_vpc.this.*.id, [""]), 0)
  subnet_ids = aws_subnet.private.*.id

  tags = merge(
    {
      "Name" = format("%s-${var.private_subnet_suffix}", "${local.env}-VPC")
    },
    "${var.tags[local.env]}",
    "${var.private_acl_tags[local.env]}",
  )
}

resource "aws_network_acl_rule" "private_inbound" {
  count = "${var.create_vpc[local.env]}" && "${var.private_dedicated_network_acl[local.env]}" && length("${var.private_subnets[local.env]}") > 0 ? length("${var.private_inbound_acl_rules[local.env]}") : 0

  network_acl_id = aws_network_acl.private[0].id

  egress          = false
  rule_number     = "${var.private_inbound_acl_rules[local.env]}"[count.index]["rule_number"]
  rule_action     = "${var.private_inbound_acl_rules[local.env]}"[count.index]["rule_action"]
  from_port       = lookup("${var.private_inbound_acl_rules[local.env]}"[count.index], "from_port", null)
  to_port         = lookup("${var.private_inbound_acl_rules[local.env]}"[count.index], "to_port", null)
  icmp_code       = lookup("${var.private_inbound_acl_rules[local.env]}"[count.index], "icmp_code", null)
  icmp_type       = lookup("${var.private_inbound_acl_rules[local.env]}"[count.index], "icmp_type", null)
  protocol        = "${var.private_inbound_acl_rules[local.env]}"[count.index]["protocol"]
  cidr_block      = lookup("${var.private_inbound_acl_rules[local.env]}"[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup("${var.private_inbound_acl_rules[local.env]}"[count.index], "ipv6_cidr_block", null)
}

resource "aws_network_acl_rule" "private_outbound" {
  count = "${var.create_vpc[local.env]}" && "${var.private_dedicated_network_acl[local.env]}" && length("${var.private_subnets[local.env]}") > 0 ? length("${var.private_outbound_acl_rules[local.env]}") : 0

  network_acl_id = aws_network_acl.private[0].id

  egress          = true
  rule_number     = "${var.private_outbound_acl_rules[local.env]}"[count.index]["rule_number"]
  rule_action     = "${var.private_outbound_acl_rules[local.env]}"[count.index]["rule_action"]
  from_port       = lookup("${var.private_outbound_acl_rules[local.env]}"[count.index], "from_port", null)
  to_port         = lookup("${var.private_outbound_acl_rules[local.env]}"[count.index], "to_port", null)
  icmp_code       = lookup("${var.private_outbound_acl_rules[local.env]}"[count.index], "icmp_code", null)
  icmp_type       = lookup("${var.private_outbound_acl_rules[local.env]}"[count.index], "icmp_type", null)
  protocol        = "${var.private_outbound_acl_rules[local.env]}"[count.index]["protocol"]
  cidr_block      = lookup("${var.private_outbound_acl_rules[local.env]}"[count.index], "cidr_block", null)
  ipv6_cidr_block = lookup("${var.private_outbound_acl_rules[local.env]}"[count.index], "ipv6_cidr_block", null)
}

################################################################################
# NAT Gateway
################################################################################

# Workaround for interpolation not being able to "short-circuit" the evaluation of the conditional branch that doesn't end up being used
# Source: https://github.com/hashicorp/terraform/issues/11566#issuecomment-289417805
#
# The logical expression would be
#
#    nat_gateway_ips = var.reuse_nat_ips ? var.external_nat_ip_ids : aws_eip.nat.*.id
#
# but then when count of aws_eip.nat.*.id is zero, this would throw a resource not found error on aws_eip.nat.*.id.
locals {
  nat_gateway_ips = split(
    ",",
    "${var.reuse_nat_ips[local.env]}" ? join(",", "${var.external_nat_ip_ids[local.env]}") : join(",", aws_eip.nat.*.id),
  )
}

resource "aws_eip" "nat" {
  count = "${var.create_vpc[local.env]}" && "${var.enable_nat_gateway[local.env]}" && false == "${var.reuse_nat_ips[local.env]}" ? local.nat_gateway_count : 0

  vpc = true

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        "GATEWAY-NGW-EIP",
        element("${var.azs[local.env]}", "${var.single_nat_gateway[local.env]}" ? 0 : count.index),
      )
    },
    "${var.tags[local.env]}",
    "${var.nat_eip_tags[local.env]}",
  )
}

resource "aws_nat_gateway" "this" {
  count = "${var.create_vpc[local.env]}" && "${var.enable_nat_gateway[local.env]}" ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    "${var.single_nat_gateway[local.env]}" ? 0 : count.index + 2,
  )
  subnet_id = element(
    aws_subnet.public.*.id,
    "${var.single_nat_gateway[local.env]}" ? 0 : count.index + 2,
  )

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        "GATEWAY-NGW",
        element("${var.azs[local.env]}", "${var.single_nat_gateway[local.env]}" ? 0 : count.index),
      )
    },
    "${var.tags[local.env]}",
    "${var.nat_gateway_tags[local.env]}",
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat_gateway" {
  count = "${var.create_vpc[local.env]}" && "${var.enable_nat_gateway[local.env]}" ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "private_ipv6_egress" {
  count = "${var.create_vpc[local.env]}" && "${var.create_egress_only_igw[local.env]}" && "${var.enable_ipv6[local.env]}" ? length("${var.private_subnets[local.env]}") : 0

  route_table_id              = element(aws_route_table.private.*.id, count.index)
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = element(aws_egress_only_internet_gateway.this.*.id, 0)
}

################################################################################
# Route table association
################################################################################

resource "aws_route_table_association" "private" {
  count = "${var.create_vpc[local.env]}" && length("${var.private_subnets[local.env]}") > 0 ? length("${var.private_subnets[local.env]}") : 0

  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(
    aws_route_table.private.*.id,
    "${var.single_nat_gateway[local.env]}" ? 0 : count.index,
  )
}

resource "aws_route_table_association" "public" {
  count = "${var.create_vpc[local.env]}" && length("${var.public_subnets[local.env]}") > 0 ? length("${var.public_subnets[local.env]}") : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

################################################################################
# Customer Gateways
################################################################################

resource "aws_customer_gateway" "this" {
  for_each = var.customer_gateways

  bgp_asn    = each.value["bgp_asn"]
  ip_address = each.value["ip_address"]
  type       = "ipsec.1"

  tags = merge(
    {
      Name = each.key
    },
    "${var.tags[local.env]}",
    var.customer_gateway_tags,
  )
}

################################################################################
# VPN Gateway
################################################################################

resource "aws_vpn_gateway" "this" {
  count = "${var.create_vpc[local.env]}" && var.enable_vpn_gateway ? 1 : 0

  vpc_id            = local.vpc_id
  amazon_side_asn   = var.amazon_side_asn
  availability_zone = var.vpn_gateway_az

  tags = merge(
    {
      "Name" = "VGW-${local.env}-VPC"
    },
    "${var.tags[local.env]}",
    var.vpn_gateway_tags,
  )
}

resource "aws_vpn_gateway_attachment" "this" {
  count = var.vpn_gateway_id != "" ? 1 : 0

  vpc_id         = local.vpc_id
  vpn_gateway_id = var.vpn_gateway_id
}

resource "aws_vpn_gateway_route_propagation" "public" {
  count = "${var.create_vpc[local.env]}" && var.propagate_public_route_tables_vgw && (var.enable_vpn_gateway || var.vpn_gateway_id != "") ? 1 : 0

  route_table_id = element(aws_route_table.public.*.id, count.index)
  vpn_gateway_id = element(
    concat(
      aws_vpn_gateway.this.*.id,
      aws_vpn_gateway_attachment.this.*.vpn_gateway_id,
    ),
    count.index,
  )
}

resource "aws_vpn_gateway_route_propagation" "private" {
  count = "${var.create_vpc[local.env]}" && var.propagate_private_route_tables_vgw && (var.enable_vpn_gateway || var.vpn_gateway_id != "") ? length("${var.private_subnets[local.env]}") : 0

  route_table_id = element(aws_route_table.private.*.id, count.index)
  vpn_gateway_id = element(
    concat(
      aws_vpn_gateway.this.*.id,
      aws_vpn_gateway_attachment.this.*.vpn_gateway_id,
    ),
    count.index,
  )
}

################################################################################
# Defaults
################################################################################

resource "aws_default_vpc" "this" {
  count = var.manage_default_vpc ? 1 : 0

  enable_dns_support   = var.default_vpc_enable_dns_support
  enable_dns_hostnames = var.default_vpc_enable_dns_hostnames
  enable_classiclink   = var.default_vpc_enable_classiclink

  tags = merge(
    {
      "Name" = format("%s", var.default_vpc_name)
    },
    "${var.tags[local.env]}",
    var.default_vpc_tags,
  )
}