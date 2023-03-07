############################################
## Network Two AZ Public & Private - Main ##
############################################

# Create the VPC
resource "aws_vpc" "vpcmain" {
  cidr_block           = var.vpcmain_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpcmain"
    Environment = var.app_environment
  }
}

# Define the public subnet 1
resource "aws_subnet" "vpcmain-public-subnet1" {
  vpc_id            = aws_vpc.vpcmain.id
  cidr_block        = var.vpcmain_public_subnet_cidr1
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpcmain-public-subnet1"
    Environment = var.app_environment
  }
}

# Define the public subnet 2
resource "aws_subnet" "vpcmain-public-subnet2" {
  vpc_id            = aws_vpc.vpcmain.id
  cidr_block        = var.vpcmain_public_subnet_cidr2
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpcmain-public-subnet2"
    Environment = var.app_environment
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "vpcmain_gw" {
  vpc_id = aws_vpc.vpcmain.id
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpcmain-igw"
    Environment = var.app_environment
  }
}

# Define the public route table
resource "aws_route_table" "vpcmain_public-rt" {
  vpc_id = aws_vpc.vpcmain.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpcmain_gw.id
  }
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpcmain-public-subnet-rt"
    Environment = var.app_environment
  }
}

# Assign the public route table to the public subnet1
resource "aws_route_table_association" "vpcmain_public-rt-association1" {
  subnet_id      = aws_subnet.vpcmain-public-subnet1.id
  route_table_id = aws_route_table.vpcmain_public-rt.id
}

# Assign the public route table to the public subnet1
resource "aws_route_table_association" "vpcmain_public-rt-association2" {
  subnet_id      = aws_subnet.vpcmain-public-subnet2.id
  route_table_id = aws_route_table.vpcmain_public-rt.id
}


# Define the private subnet 1
resource "aws_subnet" "vpcmain_private-subnet1" {
  vpc_id            = aws_vpc.vpcmain.id
  cidr_block        = var.vpcmain_private_subnet_cidr1
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpcmain-private-subnet1"
    Environment = var.app_environment
  }
}

# Define the private subnet 2
resource "aws_subnet" "vpcmain_private-subnet2" {
  vpc_id            = aws_vpc.vpcmain.id
  cidr_block        = var.vpcmain_private_subnet_cidr2
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpcmain-private-subnet2"
    Environment = var.app_environment
  }
}

# Define the private route table
resource "aws_route_table" "vpcmain_private-rt" {
  vpc_id = aws_vpc.vpcmain.id
  tags = {
    Name = "${lower(var.app_name)}-${lower(var.app_environment)}-vpcmain-private-subnet-rt"
    Environment = var.app_environment
  }
}
