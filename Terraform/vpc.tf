provider "aws" {
  region = var.region
}

resource "aws_vpc" "team2_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "team2-vpc"
  }
}

resource "aws_subnet" "team2_public_subnet" {
  vpc_id                  = aws_vpc.team2_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "team2-public-subnet"
  }
}

resource "aws_subnet" "team2_private_subnet" {
  vpc_id            = aws_vpc.team2_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}c"

  tags = {
    Name = "team2-private-subnet"
  }
}

resource "aws_internet_gateway" "team2_igw" {
  vpc_id = aws_vpc.team2_vpc.id

  tags = {
    Name = "team2-igw"
  }
}

resource "aws_route_table" "team2_public_rt" {
  vpc_id = aws_vpc.team2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.team2_igw.id
  }

  tags = {
    Name = "team2-public-rt"
  }
}

resource "aws_route_table_association" "team2_public_rt_assoc" {
  subnet_id      = aws_subnet.team2_public_subnet.id
  route_table_id = aws_route_table.team2_public_rt.id
}

resource "aws_eip" "team2_eip" {
  domain = "vpc"

  tags = {
    Name = "team2-eip"
  }
}

resource "aws_nat_gateway" "team2_nat_gateway" {
  allocation_id = aws_eip.team2_eip.id
  subnet_id     = aws_subnet.team2_public_subnet.id

  tags = {
    Name = "team2-nat-gateway"
  }
}

resource "aws_route_table" "team2_private_rt" {
  vpc_id = aws_vpc.team2_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.team2_nat_gateway.id
  }

  tags = {
    Name = "team2-private-rt"
  }
}

resource "aws_route_table_association" "team2_private_rt_assoc" {
  subnet_id      = aws_subnet.team2_private_subnet.id
  route_table_id = aws_route_table.team2_private_rt.id
}
