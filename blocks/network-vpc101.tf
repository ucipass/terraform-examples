############################################
## Network Two AZ Public & Private - Main ##
############################################

# Create the VPC
resource "aws_vpc" "vpc101" {
  cidr_block           = var.vpc101_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc101"
    Environment = var.app_environment
  }
}

# Define the public subnet 1
resource "aws_subnet" "vpc101-public-subnet1" {
  vpc_id            = aws_vpc.vpc101.id
  cidr_block        = var.vpc101_public_subnet_cidr1
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc101-public-subnet1"
    Environment = var.app_environment
  }
}

# Define the public subnet 2
resource "aws_subnet" "vpc101-public-subnet2" {
  vpc_id            = aws_vpc.vpc101.id
  cidr_block        = var.vpc101_public_subnet_cidr2
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc101-public-subnet2"
    Environment = var.app_environment
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "vpc101_gw" {
  vpc_id = aws_vpc.vpc101.id
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc101-igw"
    Environment = var.app_environment
  }
}

# Define the public route table
resource "aws_route_table" "vpc101_public-rt" {
  vpc_id = aws_vpc.vpc101.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc101_gw.id
  }
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc101-public-subnet-rt"
    Environment = var.app_environment
  }
}

# Assign the public route table to the public subnet1
resource "aws_route_table_association" "vpc101_public-rt-association1" {
  subnet_id      = aws_subnet.vpc101-public-subnet1.id
  route_table_id = aws_route_table.vpc101_public-rt.id
}

# Assign the public route table to the public subnet1
resource "aws_route_table_association" "vpc101_public-rt-association2" {
  subnet_id      = aws_subnet.vpc101-public-subnet2.id
  route_table_id = aws_route_table.vpc101_public-rt.id
}


# Define the private subnet 1
resource "aws_subnet" "vpc101_private-subnet1" {
  vpc_id            = aws_vpc.vpc101.id
  cidr_block        = var.vpc101_private_subnet_cidr1
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc101-private-subnet1"
    Environment = var.app_environment
  }
}

# Define the private subnet 2
resource "aws_subnet" "vpc101_private-subnet2" {
  vpc_id            = aws_vpc.vpc101.id
  cidr_block        = var.vpc101_private_subnet_cidr2
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc101-private-subnet2"
    Environment = var.app_environment
  }
}

# Define the private route table
resource "aws_route_table" "vpc101_private-rt" {
  vpc_id = aws_vpc.vpc101.id
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc101-private-subnet-rt"
    Environment = var.app_environment
  }
}
