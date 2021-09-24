####################
# define terraform #
####################
terraform {
    required_version = ">=1.0"
}

#Create VPC 
resource "aws_vpc" "this" {
  cidr_block = lookup(var.vpc, local.env)
  tags = {
    Name = "VPC-${local.env}"
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "this" {
  count                   = length(lookup(var.private_subnets, local.env))
  cidr_block              = lookup(var.private_subnets, local.env)[count.index]
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${local.env}-subnet-${count.index + 1}"
  }
}
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    "Name" = "${local.env}-main-igw"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    "Name" = "${local.env}-main-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  count          = length(aws_subnet.this)
  subnet_id      = aws_subnet.this[count.index].id
  route_table_id = aws_route_table.this.id

}