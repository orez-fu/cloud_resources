
resource "aws_vpc" "vpc" {
  cidr_block                           = var.vpc_cidr
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  assign_generated_ipv6_cidr_block     = false
  enable_network_address_usage_metrics = false
  instance_tenancy                     = "default"

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}"
    }
  )
}

## Define the subnets

resource "aws_subnet" "public_subnets" {
  count = length(var.vpc_public_subnets)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_public_subnets[count.index].cidr
  availability_zone       = var.vpc_public_subnets[count.index].az
  map_public_ip_on_launch = var.vpc_map_public_ip_on_launch

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_public_subnets[count.index].name}"
    }
  )
}

resource "aws_subnet" "private_subnets" {
  count = length(var.vpc_private_subnets)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_private_subnets[count.index].cidr
  availability_zone       = var.vpc_private_subnets[count.index].az
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_private_subnets[count.index].name}"
    }
  )
}

## End define the subnets


## Define the NAT gateway and route tables

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.vpc.id
  # dynamic "route" {
  #   for_each = var.vpc_public_subnets

  #   content {
  #     cidr_block       = route.value.cidr
  #     local_gateway_id = "local"
  #   }
  # }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    var.tags,
    {
      Name = "Public Route Table"
    }
  )
}

resource "aws_route_table_association" "public_subnet_association" {
  count = length(var.vpc_public_subnets)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
  associate_with_private_ip = null

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_public_subnets[0].name}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = merge(
    var.tags,
    {
      Name = "Nat Gateway"
    }
  )
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  # dynamic "route" {
  #   for_each = var.vpc_private_subnets
  #   content {
  #     cidr_block       = route.value.cidr
  #     local_gateway_id = "local"
  #   }
  # }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(
    var.tags,
    {
      Name = "Private Route Table"
    }
  )
}

resource "aws_route_table_association" "service_subnet_association" {
  count = length(var.vpc_private_subnets)

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
