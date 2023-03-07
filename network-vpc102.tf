############################################
## Network Two AZ Public & Private - Main ##
############################################

# Create the VPC
resource "aws_vpc" "vpc102" {
  cidr_block           = var.vpc102_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc102"
    Environment = var.app_environment
  }
}

# Define the public subnet 1
resource "aws_subnet" "vpc102-public-subnet1" {
  vpc_id            = aws_vpc.vpc102.id
  cidr_block        = var.vpc102_public_subnet_cidr1
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc102-public-subnet1"
    Environment = var.app_environment
  }
}

# Define the public subnet 2
resource "aws_subnet" "vpc102-public-subnet2" {
  vpc_id            = aws_vpc.vpc102.id
  cidr_block        = var.vpc102_public_subnet_cidr2
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc102-public-subnet2"
    Environment = var.app_environment
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "vpc102_gw" {
  vpc_id = aws_vpc.vpc102.id
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc102-igw"
    Environment = var.app_environment
  }
}

# Define the public route table
resource "aws_route_table" "vpc102_public-rt" {
  vpc_id = aws_vpc.vpc102.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc102_gw.id
  }
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc102-public-subnet-rt"
    Environment = var.app_environment
  }
}

# Assign the public route table to the public subnet1
resource "aws_route_table_association" "vpc102_public-rt-association1" {
  subnet_id      = aws_subnet.vpc102-public-subnet1.id
  route_table_id = aws_route_table.vpc102_public-rt.id
}

# Assign the public route table to the public subnet1
resource "aws_route_table_association" "vpc102_public-rt-association2" {
  subnet_id      = aws_subnet.vpc102-public-subnet2.id
  route_table_id = aws_route_table.vpc102_public-rt.id
}


# Define the private subnet 1
resource "aws_subnet" "vpc102_private-subnet1" {
  vpc_id            = aws_vpc.vpc102.id
  cidr_block        = var.vpc102_private_subnet_cidr1
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc102-private-subnet1"
    Environment = var.app_environment
  }
}

# Define the private subnet 2
resource "aws_subnet" "vpc102_private-subnet2" {
  vpc_id            = aws_vpc.vpc102.id
  cidr_block        = var.vpc102_private_subnet_cidr2
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc102-private-subnet2"
    Environment = var.app_environment
  }
}

# Define the private route table
resource "aws_route_table" "vpc102_private-rt" {
  vpc_id = aws_vpc.vpc102.id
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpc102-private-subnet-rt"
    Environment = var.app_environment
  }
}
