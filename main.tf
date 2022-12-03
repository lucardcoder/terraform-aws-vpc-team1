data "aws_availability_zones" "all" {}

locals {
  az1 = data.aws_availability_zones.all.names[0]
  az2 = data.aws_availability_zones.all.names[1]
  az3 = data.aws_availability_zones.all.names[2]
}


resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = var.enableDnsHostnames
  enable_dns_support   = true
  tags                 = var.tags
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet1
  availability_zone = local.az1
  tags              = var.tags

  map_public_ip_on_launch = true
}
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet2
  availability_zone       = local.az2
  tags                    = var.tags
  map_public_ip_on_launch = true
}
resource "aws_subnet" "public3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet3
  availability_zone       = local.az3
  tags                    = var.tags
  map_public_ip_on_launch = true
}
resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet1
  availability_zone       = local.az1
  tags                    = var.tags
  map_public_ip_on_launch = false
}
resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet2
  availability_zone       = local.az2
  tags                    = var.tags
  map_public_ip_on_launch = false
}
resource "aws_subnet" "private3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet3
  availability_zone       = local.az3
  tags                    = var.tags
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = var.tags
}


resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.example.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.example.id
}
resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.example.id
}


resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0
  vpc   = true
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public1.id
  depends_on    = [aws_internet_gateway.gw]
  tags          = var.tags
}

resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this[0].id
  }

  tags = var.tags
}

resource "aws_route_table" "private2" {
  count  = var.enable_nat_gateway ? 0 : 1
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private2[0].id
}
resource "aws_route_table_association" "private2" {
  #count          = var.enable_nat_gateway ? 1 : 0
  subnet_id      = aws_subnet.private2.id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private2[0].id
}
resource "aws_route_table_association" "private3" {
  #count          = var.enable_nat_gateway ? 1 : 0
  subnet_id      = aws_subnet.private3.id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private2[0].id
}

