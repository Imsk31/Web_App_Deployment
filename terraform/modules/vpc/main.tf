
                    
########################################################################################################################################################
# This module creates a VPC with public and private subnets, an Internet Gateway, and NAT Gateways.                                                    #
# It also sets up route tables for both public and private subnets.                                                                                    #
# The module is designed to be flexible, allowing you to specify the CIDR blocks for the VPC and subnets, as well as the availability zones and tags.  #
########################################################################################################################################################


resource "aws_vpc" "main" {
  region               = var.region
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = merge(
    {
      Name = var.vpc_name
    },
    var.tags
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-igw"
    },
    var.tags
  )
}

data "aws_availability_zones" "azs" {
    state = "available"
}

resource "aws_eip" "nat" {
  count     = length(var.public_subnet_cidrs)
  domain    = "vpc"

  tags = merge(
    {
      Name = "${var.vpc_name}-nat-eip"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "nat" {
  count                 = length(var.public_subnet_cidrs)
  allocation_id         = aws_eip.nat[count.index].id
  subnet_id             = aws_subnet.public_subnet[count.index].id
  connectivity_type     = var.connectivity_type

  tags = merge(
    {
      Name = "${var.vpc_name}-nat"
    },
    var.tags
  )
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  # availability_zone       = var.aws_availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = "${var.vpc_name}-public"
    },
    var.tags
  )
}

resource "aws_route_table" "public" {
  vpc_id      = aws_vpc.main.id
  count       = length(var.public_subnet_cidrs)

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = merge(
    {
      Name = "${var.vpc_name}-public-rt"
    },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  count             = length(aws_subnet.public_subnet)
  route_table_id    = aws_route_table.public[count.index].id
  subnet_id         = aws_subnet.public_subnet[count.index].id
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.azs.names[count.index]

  tags = merge(
    {
      Name = "${var.vpc_name}-private"
    },
    var.tags
  )
}

resource "aws_route_table" "private" {
  count         = length((aws_subnet.private_subnet))
  vpc_id        = aws_vpc.main.id
  route {
    gateway_id  = aws_nat_gateway.nat[count.index].id
    cidr_block  = "0.0.0.0/0"
  }

  tags = merge(
    {
      Name = "${var.vpc_name}-private-rt"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  count           = length(aws_subnet.private_subnet)
  route_table_id  = aws_route_table.private[count.index].id
  subnet_id       = aws_subnet.private_subnet[count.index].id
}