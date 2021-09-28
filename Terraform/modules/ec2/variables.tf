################
# Data Sources #
################
data "aws_ami" "amazon_cis_windows" {
    most_recent = true
    owners = ["aws-marketplace"]

    filter {
        name = "manifest-location"
        values = ["aws-marketplace/CIS Microsoft Windows Server 2019 Benchmark v1*"]
    }

    filter {
        name = "platform"
        values = ["windows"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    tags = {
        "TERRAFORM" = "TRUE"
        "BUDGET SUB-CODE" = "6-0418-11"
    }
}

data "aws_ami" "amazon_ubuntu" {
    most_recent = true
    owners = ["099720109477"]

    filter {
        name = "manifest-location"
        values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64*"]
    }

    filter {
        name = "platform"
        values = ["UNIX/Linux"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    tags = {
        "TERRAFORM" = "TRUE"
        "BUDGET SUB-CODE" = "6-0418-11"
    }
}

##########
# Locals #
##########
locals {
  windows = data.aws_ami.amazon_cis_windows.id
  ubuntu = data.aws_ami.amazon_ubuntu.id
}


########################
# Variable declaration #
########################
variable "region" {
  description = "Which region you want to provision your resources?"
  type        = map(string)
  default     = {
    SIT         = "ap-southeast-1"
    UAT         = "ap-southeast-1"
    PROD        = "ap-southeast-1"
    PROD_SYDNEY = "ap-southeast-2"
  }
}

variable "name" {
  description = "Name to be used on all resources as prefix"
  type        = map(any)
  default     = {
    SIT         = [""]
    UAT         = [""]
    PROD        = [""]
    PROD_SYDNEY = [""]
  }
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = map(number)
  default     = {
    SIT         = 1
    UAT         = 1
    PROD        = 1
    PROD_SYDNEY = 1
  }
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = map(any)
  default     = {
    SIT         = ["${local.windows}"]
    UAT         = ["${local.windows}"]
    PROD        = ["${local.windows}"]
    PROD_SYDNEY = ["${local.windows}"]
  }
}

variable "placement_group" {
  description = "The Placement Group to start the instance in"
  type        = map(any)
  default     = {
    SIT         = [""]
    UAT         = [""]
    PROD        = [""]
    PROD_SYDNEY = [""]
  }
}

variable "get_password_data" {
  description = "If true, wait for password data to become available and retrieve it."
  type        = map(list(bool))
  default     = {
    SIT         = [false,]
    UAT         = [false,]
    PROD        = [false,]
    PROD_SYDNEY = [false,]
  }
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  type        = map(list(string))
  default     = {
    SIT         = ["default",]
    UAT         = ["default",]
    PROD        = ["default",]
    PROD_SYDNEY = ["default",]
  }
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = map(list(bool))
  default     = {
    SIT         = [false,]
    UAT         = [false,]
    PROD        = [false,]
    PROD_SYDNEY = [false,]
  }
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  type        = map(list(bool))
  default     = {
    SIT         = [false,]
    UAT         = [false,]
    PROD        = [false,]
    PROD_SYDNEY = [false,]
  }
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance" # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior
  type        = map(list(string))
  default     = {
    SIT         = ["",]
    UAT         = ["",]
    PROD        = ["",]
    PROD_SYDNEY = ["",]
  }
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = map(list(string))
  default     = {
    SIT         = ["",]
    UAT         = ["",]
    PROD        = ["",]
    PROD_SYDNEY = ["",]
  }
}

variable "key_name" {
  description = "The key name to use for the instance"
  type        = map(list(string))
  default     = {
    SIT         = ["",]
    UAT         = ["",]
    PROD        = ["",]
    PROD_SYDNEY = ["",]
  }
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = map(list(bool))
  default     = {
    SIT         = [false,]
    UAT         = [false,]
    PROD        = [false,]
    PROD_SYDNEY = [false,]
  }
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = map(any)
  default     = {
    SIT         = [null,]
    UAT         = [null,]
    PROD        = [null,]
    PROD_SYDNEY = [null,]
  }
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = map(list(string))
  default     = {
    SIT         = ["",]
    UAT         = ["",]
    PROD        = ["",]
    PROD_SYDNEY = ["",]
  }
}

variable "subnet_ids" {
  description = "A list of VPC Subnet IDs to launch in"
  type        = map(any)
  default     = {
    SIT         = ["",]
    UAT         = ["",]
    PROD        = ["",]
    PROD_SYDNEY = ["",]
  }
}

variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
  type        = map(list(bool))
  default     = {
    SIT         = [null,]
    UAT         = [null,]
    PROD        = [null,]
    PROD_SYDNEY = [null,]
  }
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  type        = map(list(string))
  default     = {
    SIT         = [null,]
    UAT         = [null,]
    PROD        = [null,]
    PROD_SYDNEY = [null,]
  }
}

variable "private_ips" {
  description = "A list of private IP address to associate with the instance in a VPC. Should match the number of instances."
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []
  }
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  type        = map(list(bool))
  default     = {
    SIT         = [true,]
    UAT         = [true,]
    PROD        = [true,]
    PROD_SYDNEY = [true,]
  }
}

variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  type        = map(list(string))
  default     = {
    SIT         = [null,]
    UAT         = [null,]
    PROD        = [null,]
    PROD_SYDNEY = [null,]
  }
}

variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption."
  type        = map(list(string))
  default     = {
    SIT         = [null,]
    UAT         = [null,]
    PROD        = [null,]
    PROD_SYDNEY = [null,]
  }
}

variable "iam_instance_profile" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  type        = map(list(string))
  default     = {
    SIT         = ["",]
    UAT         = ["",]
    PROD        = ["",]
    PROD_SYDNEY = ["",]
  }
}

variable "ipv6_address_count" {
  description = "A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet."
  type        = map(number)
  default     = {
    SIT         = null
    UAT         = null
    PROD        = null
    PROD_SYDNEY = null
  }
}

variable "ipv6_addresses" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface"
  type        = map(any)
  default     = {
    SIT         = [null,]
    UAT         = [null,]
    PROD        = [null,]
    PROD_SYDNEY = [null,]
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "enable_volume_tags" {
  description = "Whether to enable volume tags (if enabled it conflicts with root_block_device tags)"
  type        = map(list(bool))
  default     = {
    SIT         = [true,]
    UAT         = [true,]
    PROD        = [true,]
    PROD_SYDNEY = [true,]
  }
}

variable "volume_tags" {
  description = "A mapping of tags to assign to the devices created by the instance at launch time"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []
  }
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []
  }
}

variable "ephemeral_block_device" {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance"
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []
  }
}

variable "network_interface" {
  description = "Customize network interfaces to be attached at instance boot time"
  type        = map(any)
  default     = {
    SIT         = []
    UAT         = []
    PROD        = []
    PROD_SYDNEY = []
  }
}

variable "cpu_credits" {
  description = "The credit option for CPU usage (unlimited or standard)"
  type        = string
  default     = "standard"
}

variable "metadata_options" {
  description = "Customize the metadata options of the instance"
  type        = map(any)
  default     = {
    SIT         = {}
    UAT         = {}
    PROD        = {}
    PROD_SYDNEY = {}
  }
}

variable "use_num_suffix" {
  description = "Always append numerical suffix to instance name, even if instance_count is 1"
  type        = bool
  default     = false
}

variable "num_suffix_format" {
  description = "Numerical suffix format used as the volume and EC2 instance name suffix"
  type        = string
  default     = "-%d"
}