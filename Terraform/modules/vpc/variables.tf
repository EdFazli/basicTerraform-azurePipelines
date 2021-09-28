########################
# Variable declaration #
########################
# variable "region" {
#   description = "Which region you want to provision your resources?"
#   type        = map(any)
#   default     = {
#     SIT         = "ap-southeast-1"
#     UAT         = "ap-southeast-1"
#     PROD        = "ap-southeast-1"
#     PROD_SYDNEY = "ap-southeast-2"
#   }
# }

variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = map(bool)
  default     = {
    SIT         = true
    UAT         = true
    PROD        = true
    PROD_SYDNEY = true  
  }
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = map(string)
  default     = {
    SIT         = "SIT-VPC"
    UAT         = "UAT-VPC"
    PROD        = "PROD-VPC"
    PROD_SYDNEY = "PROD-SYDNEY-VPC"
  }
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = map(any)
  default     = {
    SIT         = "10.210.0.0/16"
    UAT         = "10.220.0.0/16"
    PROD        = "10.101.0.0/16"
    PROD_SYDNEY = "10.110.0.0/16"
  }
}

variable "enable_ipv6" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block."
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false 
  }
}

variable "private_subnet_ipv6_prefixes" {
  description = "Assigns IPv6 private subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []  
  }
}

variable "public_subnet_ipv6_prefixes" {
  description = "Assigns IPv6 public subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []  
  }
}

variable "assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false 
  }
}

variable "private_subnet_assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on private subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = map(bool)
  default     = {
    SIT         = null
    UAT         = null
    PROD        = null
    PROD_SYDNEY = null 
  }
}

variable "public_subnet_assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on public subnet, must be disabled to change IPv6 CIDRs. This is the IPv6 equivalent of map_public_ip_on_launch"
  type        = map(bool)
  default     = {
    SIT         = null
    UAT         = null
    PROD        = null
    PROD_SYDNEY = null 
  }
}

variable "secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []  
  }
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = map(string)
  default     = {
    SIT         = "default"
    UAT         = "default"
    PROD        = "default"
    PROD_SYDNEY = "default"
  }
}

variable "public_subnet_suffix" {
  description = "Suffix to append to public subnets name"
  type        = string
  default     = "PUBLIC"
}

variable "public_subnets_name" {
  description = "List of name for the public subnets"
  type = map(any)
  default = {
    SIT         = ["GATEWAY-NGW", "GATEWAY-NGW", "GATEWAY-SFTP", "GATEWAY-SFTP", "GATEWAY-REVERSEPROXY", "GATEWAY-REVERSEPROXY"]
    UAT         = ["IEGRESS-NLB", "IEGRESS-NLB", "GATEWAY-NGW", "GATEWAY-NGW", "GATEWAY-REVERSEPROXY", "GATEWAY-REVERSEPROXY"]
    PROD        = ["IEGRESS-NLB", "IEGRESS-NLB", "GATEWAY-NGW", "GATEWAY-NGW", "GATEWAY-REVERSEPROXY", "GATEWAY-REVERSEPROXY", "OTHERS-ALB", "OTHERS-ALB"]
    PROD_SYDNEY = ["IEGRESS-NLB", "IEGRESS-NLB", "GATEWAY-NGW", "GATEWAY-NGW"]
  }
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = map(any)
  default     = {
    SIT         = ["10.210.0.0/25", "10.210.0.128/25", "10.210.1.0/25", "10.210.1.128/25", "10.210.2.0/25", "10.210.2.128/25"]
    UAT         = ["10.220.0.0/25", "10.220.0.128/25", "10.220.16.0/25", "10.220.16.128/25", "10.220.18.0/25", "10.220.18.128/25"]
    PROD        = ["10.101.0.0/25", "10.101.0.128/25", "10.101.16.0/25", "10.101.16.128/25", "10.101.18.0/25", "10.101.18.128/25", "10.101.128.0/25", "10.101.128.128/25",]
    PROD_SYDNEY = ["10.110.0.0/25", "10.110.0.128/25", "10.110.16.0/25", "10.110.16.128/25"]
  }
}

variable "private_subnet_suffix" {
  description = "Suffix to append to private subnets name"
  type        = string
  default     = "PRIVATE"
}

variable "private_subnets_name" {
  description = "List of name for the private subnets"
  type = map(any)
  default = {
    SIT         = [
      "ECOMM-ALB", "ECOMM-ALB", "ECOMM-WEB", "ECOMM-WEB", "ECOMM-API", "ECOMM-API", "ECOMM-ADMIN", "ECOMM-ADMIN", "ECOMM-STORAGE", "ECOMM-STORAGE", "ECOMM-REDIS", "ECOMM-REDIS", "ECOMM-DB", "ECOMM-DB",
      "CRM-ALB", "CRM-ALB", "CRM-WEB", "CRM-WEB", "CRM-API", "CRM-API", "CRM-STORAGE", "CRM-STORAGE", "CRM-REDIS", "CRM-REDIS", "CRM-DB", "CRM-DB",
      "MMS-ALB", "MMS-ALB", "MMS-WEB", "MMS-WEB", "MMS-LAMBDA", "MMS-LAMBDA", "MMS-STORAGE", "MMS-STORAGE", "MMS-REDIS", "MMS-REDIS", "MMS-DB", "MMS-DB",
    ]
    UAT         = [
      "IEGRESS-NGFW", "IGRESS-NGFW",
      "GATEWAY-SFTP", "GATEWAY-SFTP",
      "OTHERS-ALB", "OTHERS-ALB", "OTHERS-WEB", "OTHERS-WEB", "OTHERS-DB", "OTHERS-DB",
    ]
    PROD        = [
      "IEGRESS-NGFW", "IGRESS-NGFW",
      "GATEWAY-SFTP", "GATEWAY-SFTP",
      "OTHERS-WEB", "OTHERS-WEB", "OTHERS-DB", "OTHERS-DB",
    ]
    PROD_SYDNEY = [
      "IEGRESS-NGFW", "IGRESS-NGFW",
      "GATEWAY-SFTP", "GATEWAY-SFTP",
      "CRM-ALB", "CRM-ALB", "CRM-WEB", "CRM-WEB", "CRM-API", "CRM-API", "CRM-STORAGE", "CRM-STORAGE", "CRM-REDIS", "CRM-REDIS", "CRM-DB", "CRM-DB",
      "OTHERS-ALB", "OTHERS-ALB", "OTHERS-WEB", "OTHERS-WEB",
    ]
  }
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = map(any)
  default     = {
    SIT         = [
      "10.210.16.0/25", "10.210.16.128/25", "10.210.17.0/25", "10.210.17.128/25", "10.210.18.0/25", "10.210.18.128/25", "10.210.19.0/25", "10.210.19.128/25", "10.210.29.0/25", "10.210.29.128/25", "10.210.30.0/25", "10.210.30.128/25", "10.210.31.0/25", "10.210.131.128/25",
      "10.210.32.0/25", "10.210.32.128/25", "10.210.33.0/25", "10.210.33.128/25", "10.210.34.0/25", "10.210.34.128/25", "10.210.45.0/25", "10.210.45.128/25", "10.210.46.0/25", "10.210.46.128/25", "10.210.47.0/25", "10.210.47.128/25",
      "10.210.48.0/25", "10.210.48.128/25", "10.210.49.0/25", "10.210.49.128/25", "10.210.50.0/25", "10.210.50.128/25", "10.210.61.0/25", "10.210.61.128/25", "10.210.62.0/25", "10.210.62.128/25", "10.210.63.0/25", "10.210.63.128/25",
    ]
    UAT         = [
      "10.220.1.0/25", "10.220.1.128/25",
      "10.220.17.0/25", "10.220.17.128/25",
      "10.220.128.0/25", "10.220.128.128/25", "10.220.129.0/25", "10.220.129.128/25", "10.220.143.0/25", "10.220.143.128/25",
    ]
    PROD        = [
      "10.101.1.0/25", "10.101.1.128/25",
      "10.101.17.0/25", "10.101.17.128/25",
      "10.101.129.0/25", "10.101.129.128/25", "10.101.143.0/25", "10.101.143.128/25",
    ]
    PROD_SYDNEY = [
      "10.110.1.0/25", "10.110.1.128/25",
      "10.110.17.0/25", "10.110.17.128/25",
      "10.110.48.0/25", "10.110.48.128/25", "10.110.49.0/25", "10.110.49.128/25", "10.110.49.0/25", "10.110.49.128/25", "10.110.50.0/25", "10.110.50.128/25", "10.110.61.0/25", "10.110.61.128/25", "10.110.62.0/25", "10.110.62.128/25", "10.110.63.0/25", "10.110.63.128/25",
      "10.110.128.0/25", "10.110.128.128/25", "10.110.129.0/25", "10.110.129.128/25",
    ]
  }
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = map(any)
  default     = {
    SIT         = ["ap-southeast-1a", "ap-southeast-1b"]
    UAT         = ["ap-southeast-1a", "ap-southeast-1b"]
    PROD        = ["ap-southeast-1a", "ap-southeast-1b"]
    PROD_SYDNEY = ["ap-southeast-2a", "ap-southeast-2b"]
  }
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = map(bool)
  default     = {
    SIT         = true
    UAT         = true
    PROD        = true
    PROD_SYDNEY = true
  }
}

variable "enable_classiclink" {
  description = "Should be true to enable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic."
  type        = map(bool)
  default     = {
    SIT         = null
    UAT         = null
    PROD        = null
    PROD_SYDNEY = null 
  }
}

variable "enable_classiclink_dns_support" {
  description = "Should be true to enable ClassicLink DNS Support for the VPC. Only valid in regions and accounts that support EC2 Classic."
  type        = map(bool)
  default     = {
    SIT         = null
    UAT         = null
    PROD        = null
    PROD_SYDNEY = null 
  }
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "reuse_nat_ips" {
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_nat_ips)"
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []
  }
}

variable "external_nat_ips" {
  description = "List of EIPs to be used for `nat_public_ips` output (used in combination with reuse_nat_ips and external_nat_ip_ids)"
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []
  }
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  type        = map(bool)
  default     = {
    SIT         = true
    UAT         = true
    PROD        = true
    PROD_SYDNEY = true
  }
}

variable "customer_gateways" {
  description = "Maps of Customer Gateway's attributes (BGP ASN and Gateway's Internet-routable external IP address)"
  type        = map(any)
  default     = {
    SIT         = {
      "CGW-ASCENTIS-SG-DC" = {
        bgp_asn = 65000
        ip_address = "61.14.147.113"
      }
    }
    UAT         = {
      "CGW-ASCENTIS-SG-DC" = {
        bgp_asn = 65000
        ip_address = "61.14.147.113"
      }
    }
    PROD        = {
      "CGW-ASCENTIS-SG-DC" = {
        bgp_asn = 65000
        ip_address = "61.14.147.113"
      }
    }
    PROD_SYDNEY = {
      "CGW-ASCENTIS-SG-DC" = {
        bgp_asn = 65000
        ip_address = "61.14.147.113"
      }
    }
  }
}

variable "enable_vpn_gateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "vpn_gateway_id" {
  description = "ID of VPN Gateway to attach to the VPC"
  type        = map(string)
  default     = {
    SIT         = ""
    UAT         = ""
    PROD        = ""
    PROD_SYDNEY = ""
  }
}

variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the virtual private gateway is created with the current default Amazon ASN."
  type        = string
  default     = "64512"
}

variable "vpn_gateway_az" {
  description = "The Availability Zone for the VPN Gateway"
  type        = map(string)
  default     = {
    SIT         = null
    UAT         = null
    PROD        = null
    PROD_SYDNEY = null
  }
}

variable "propagate_private_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "propagate_public_route_tables_vgw" {
  description = "Should be true if you want route table propagation"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "manage_default_route_table" {
  description = "Should be true to manage default route table"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "default_route_table_propagating_vgws" {
  description = "List of virtual gateways for propagation"
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []
  }
}

variable "default_route_table_routes" {
  description = "Configuration block of routes. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table#route"
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []
  }
}

variable "default_route_table_tags" {
  description = "Additional tags for the default route table"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "igw_tags" {
  description = "Additional tags for the internet gateway"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "public_route_table_tags" {
  description = "Additional tags for the public route tables"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "private_route_table_tags" {
  description = "Additional tags for the private route tables"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "public_acl_tags" {
  description = "Additional tags for the public subnets network ACL"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "private_acl_tags" {
  description = "Additional tags for the private subnets network ACL"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "dhcp_options_tags" {
  description = "Additional tags for the DHCP option set (requires enable_dhcp_options set to true)"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "nat_gateway_tags" {
  description = "Additional tags for the NAT gateways"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "nat_eip_tags" {
  description = "Additional tags for the NAT EIP"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "customer_gateway_tags" {
  description = "Additional tags for the Customer Gateway"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "vpn_gateway_tags" {
  description = "Additional tags for the VPN gateway"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "vpc_flow_log_tags" {
  description = "Additional tags for the VPC Flow Logs"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "vpc_flow_log_permissions_boundary" {
  description = "The ARN of the Permissions Boundary for the VPC Flow Log IAM Role"
  type        = map(string)
  default     = {
    SIT         = null
    UAT         = null
    PROD        = null
    PROD_SYDNEY = null
  }
}

variable "enable_dhcp_options" {
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)"
  type        = map(string)
  default     = {
    SIT         = ""
    UAT         = ""
    PROD        = ""
    PROD_SYDNEY = ""
  }
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []
  }
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true)"
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []
  }
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true)"
  type        = map(string)
  default     = {
    SIT         = ""
    UAT         = ""
    PROD        = ""
    PROD_SYDNEY = ""
  }
}

variable "manage_default_vpc" {
  description = "Should be true to adopt and manage Default VPC"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "default_vpc_name" {
  description = "Name to be used on the Default VPC"
  type        = map(string)
  default     = {
    SIT         = "default"
    UAT         = "default"
    PROD        = "default"
    PROD_SYDNEY = "default"
  }
}

variable "default_vpc_enable_dns_support" {
  description = "Should be true to enable DNS support in the Default VPC"
  type        = map(bool)
  default     = {
    SIT         = true
    UAT         = true
    PROD        = true
    PROD_SYDNEY = true
  }
}

variable "default_vpc_enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the Default VPC"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "default_vpc_enable_classiclink" {
  description = "Should be true to enable ClassicLink in the Default VPC"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "default_vpc_tags" {
  description = "Additional tags for the Default VPC"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "manage_default_network_acl" {
  description = "Should be true to adopt and manage Default Network ACL"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "default_network_acl_name" {
  description = "Name to be used on the Default Network ACL"
  type        = map(string)
  default     = {
    SIT         = ""
    UAT         = ""
    PROD        = ""
    PROD_SYDNEY = ""
  }
}

variable "default_network_acl_tags" {
  description = "Additional tags for the Default Network ACL"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "public_dedicated_network_acl" {
  description = "Whether to use dedicated network ACL (not default) and custom rules for public subnets"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "private_dedicated_network_acl" {
  description = "Whether to use dedicated network ACL (not default) and custom rules for private subnets"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "default_network_acl_ingress" {
  description = "List of maps of ingress rules to set on the Default Network ACL"
  type        = map(any)

  default = {
    SIT = [
      {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
      },
      {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
      }
    ]
    UAT = [
      {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
      },
      {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
      }
    ]
    PROD = [
      {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
      },
      {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
      }
    ]
    PROD_SYDNEY = [
      {
      rule_no    = 100
      action     = "allow"
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_block = "0.0.0.0/0"
      },
      {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
      }
    ]

  }
}

variable "default_network_acl_egress" {
  description = "List of maps of egress rules to set on the Default Network ACL"
  type        = map(any)

  default = {
    SIT = [
      {
        rule_no    = 100
        action     = "allow"
        from_port  = 0
        to_port    = 0
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
      },
      {
        rule_no         = 101
        action          = "allow"
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        ipv6_cidr_block = "::/0"
      }
    ]
    UAT = [
      {
        rule_no    = 100
        action     = "allow"
        from_port  = 0
        to_port    = 0
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
      },
      {
        rule_no         = 101
        action          = "allow"
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        ipv6_cidr_block = "::/0"
      }
    ]
    PROD = [
      {
        rule_no    = 100
        action     = "allow"
        from_port  = 0
        to_port    = 0
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
      },
      {
        rule_no         = 101
        action          = "allow"
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        ipv6_cidr_block = "::/0"
      }
    ]
    PROD_SYDNEY = [
      {
        rule_no    = 100
        action     = "allow"
        from_port  = 0
        to_port    = 0
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
      },
      {
        rule_no         = 101
        action          = "allow"
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        ipv6_cidr_block = "::/0"
      }
    ]

  }
}

variable "public_inbound_acl_rules" {
  description = "Public subnets inbound network ACLs"
  type        = map(any)

  default = {
    SIT = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    UAT = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    PROD = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    PROD_SYDNEY = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]

  }
}

variable "public_outbound_acl_rules" {
  description = "Public subnets outbound network ACLs"
  type        = map(any)

  default = {
    SIT = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    UAT = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    PROD = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    PROD_SYDNEY = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]

  }
}

variable "private_inbound_acl_rules" {
  description = "Private subnets inbound network ACLs"
  type        = map(any)

  default = {
    SIT = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    UAT = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    PROD = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    PROD_SYDNEY = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]

  }
}

variable "private_outbound_acl_rules" {
  description = "Private subnets outbound network ACLs"
  type        = map(any)

  default = {
    SIT = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    UAT = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    PROD = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    PROD_SYDNEY = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = "0.0.0.0/0"
      },
    ]

  }
}

variable "manage_default_security_group" {
  description = "Should be true to adopt and manage default security group"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "default_security_group_name" {
  description = "Name to be used on the default security group"
  type        = map(string)
  default     = {
    SIT         = "default"
    UAT         = "default"
    PROD        = "default"
    PROD_SYDNEY = "default"
  }
}

variable "default_security_group_ingress" {
  description = "List of maps of ingress rules to set on the default security group"
  type        = map(any)
  default     = {
    SIT         = null
    UAT         = null
    PROD        = null
    PROD_SYDNEY = null
  }
}

variable "enable_flow_log" {
  description = "Whether or not to enable VPC Flow Logs"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "default_security_group_egress" {
  description = "List of maps of egress rules to set on the default security group"
  type        = map(any)
  default     = {
    SIT         = null
    UAT         = null
    PROD        = null
    PROD_SYDNEY = null
  }
}

variable "default_security_group_tags" {
  description = "Additional tags for the default security group"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "create_flow_log_cloudwatch_log_group" {
  description = "Whether to create CloudWatch log group for VPC Flow Logs"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "create_flow_log_cloudwatch_iam_role" {
  description = "Whether to create IAM role for VPC Flow Logs"
  type        = map(bool)
  default     = {
    SIT         = false
    UAT         = false
    PROD        = false
    PROD_SYDNEY = false
  }
}

variable "flow_log_traffic_type" {
  description = "The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL."
  type        = map(string)
  default     = {
    SIT         = "ALL"
    UAT         = "ALL"
    PROD        = "ALL"
    PROD_SYDNEY = "ALL"
  }
}

variable "flow_log_destination_type" {
  description = "Type of flow log destination. Can be s3 or cloud-watch-logs."
  type        = map(string)
  default     = {
    SIT         = "cloud-watch-logs"
    UAT         = "cloud-watch-logs"
    PROD        = "cloud-watch-logs"
    PROD_SYDNEY = "cloud-watch-logs"
  }
}

variable "flow_log_log_format" {
  description = "The fields to include in the flow log record, in the order in which they should appear."
  type        = map(string)
  default     = {
    SIT         = null
    UAT         = null
    PROD        = null
    PROD_SYDNEY = null
  }
}

variable "flow_log_destination_arn" {
  description = "The ARN of the CloudWatch log group or S3 bucket where VPC Flow Logs will be pushed. If this ARN is a S3 bucket the appropriate permissions need to be set on that bucket's policy. When create_flow_log_cloudwatch_log_group is set to false this argument must be provided."
  type        = map(string)
  default     = {
    SIT         = ""
    UAT         = ""
    PROD        = ""
    PROD_SYDNEY = ""
  }
}

variable "flow_log_cloudwatch_iam_role_arn" {
  description = "The ARN for the IAM role that's used to post flow logs to a CloudWatch Logs log group. When flow_log_destination_arn is set to ARN of Cloudwatch Logs, this argument needs to be provided."
  type        = map(string)
  default     = {
    SIT         = ""
    UAT         = ""
    PROD        = ""
    PROD_SYDNEY = ""
  }
}

variable "flow_log_cloudwatch_log_group_name_prefix" {
  description = "Specifies the name prefix of CloudWatch Log Group for VPC flow logs."
  type        = map(string)
  default     = {
    SIT         = "/aws/vpc-flow-log/"
    UAT         = "/aws/vpc-flow-log/"
    PROD        = "/aws/vpc-flow-log/"
    PROD_SYDNEY = "/aws/vpc-flow-log/"
  }
}

variable "flow_log_cloudwatch_log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group for VPC flow logs."
  type        = map(number)
  default     = {
    SIT         = null
    UAT         = null
    PROD        = null
    PROD_SYDNEY = null
  }
}

variable "flow_log_cloudwatch_log_group_kms_key_id" {
  description = "The ARN of the KMS Key to use when encrypting log data for VPC flow logs."
  type        = map(string)
  default     = {
    SIT         = null
    UAT         = null
    PROD        = null
    PROD_SYDNEY = null
  }
}

variable "flow_log_max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds."
  type        = map(number)
  default     = {
    SIT         = 600
    UAT         = 600
    PROD        = 600
    PROD_SYDNEY = 600
  }
}

variable "create_igw" {
  description = "Controls if an Internet Gateway is created for public subnets and the related routes that connect them."
  type        = map(bool)
  default     = {
    SIT         = true
    UAT         = true
    PROD        = true
    PROD_SYDNEY = true
  }
}

variable "create_egress_only_igw" {
  description = "Controls if an Egress Only Internet Gateway is created and its related routes."
  type        = map(bool)
  default     = {
    SIT         = true
    UAT         = true
    PROD        = true
    PROD_SYDNEY = true
  }
}

variable "prevent_destroy_vpc" {
    description = "Controls the prevent_destroy lifecycle for VPC"
    type = map(bool)
    default = {
    SIT         = true
    UAT         = true
    PROD        = true
    PROD_SYDNEY = true
  }
}

variable "create_before_destroy_vpc" {
    description = "Controls the create_before__destroy lifecycle for VPC"
    type = map(bool)
    default = {
    SIT         = true
    UAT         = true
    PROD        = true
    PROD_SYDNEY = true
  }
}
