

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = merge({
    "Name" = "${var.project}-vpc"
    },
    var.tags
  )
}

### AWS Subnet

resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = merge({
    "Name" = "${var.project}-private-subnet-${count.index}"
    },
    var.tags
  )
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge({
    "Name" = "${var.project}-public-subnet-${count.index}"
    },
    var.tags
  )
}

### AWS Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    "Name" = "${var.project}-igw"
    },
    var.tags
  )
}

resource "aws_eip" "nat_gw_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = merge({
    "Name" = "${var.project}-nat-gw-eip"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "vpc_nat_gw" {

  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  depends_on = [aws_internet_gateway.igw]

  tags = merge({
    "Name" = "${var.project}-nat-gw"
    },
    var.tags
  )
}

### AWS Route table private

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    "Name" = "${var.project}-private-route-table"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc_nat_gw.id
}

### AWS Route table public
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    "Name" = "${var.project}-public-route-table"
    },
    var.tags
  )
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
