// This is custom VPC block
resource "aws_vpc" "set-22-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "set-22-vpc"
  }
}

// This is public subnet 1 block
resource "aws_subnet" "set-22-pub-sub-1" {
  vpc_id     = aws_vpc.set-22-vpc.id
  cidr_block = var.public_subnet_1_cidr

  tags = {
    Name = "set-22-pub-sub-1"
    Type = "Public"
  }
}

// This is public subnet 2 block
resource "aws_subnet" "set-22-pub-sub-2" {
  vpc_id     = aws_vpc.set-22-vpc.id
  cidr_block = var.public_subnet_2_cidr

  tags = {
    Name = "set-22-pub-sub-2"
    Type = "Public"
  }
}

// This is private subnet 1 block
resource "aws_subnet" "set-22-prt-sub-1" {
  vpc_id     = aws_vpc.set-22-vpc.id
  cidr_block = var.private_subnet_1_cidr

  tags = {
    Name = "set-22-prt-sub-1"
    Type = "Private"
  }
}

// This is private subnet 2 block
resource "aws_subnet" "set-22-prt-sub-2" {
  vpc_id     = aws_vpc.set-22-vpc.id
  cidr_block = var.private_subnet_2_cidr

  tags = {
    Name = "set-22-prt-sub-2"
    Type = "Private"
  }
}

// This is the Internet Gateway block
resource "aws_internet_gateway" "set-22-igw" {
  vpc_id = aws_vpc.set-22-vpc.id

  tags = {
    Name = "set-22-igw"
  }
}

// Elastic IP for NAT Gateway
resource "aws_eip" "set-22-eip" {
  domain = "vpc"
}

// NAT Gateway
resource "aws_nat_gateway" "set-22-nat" {
  allocation_id = aws_eip.set-22-eip.id
  subnet_id     = aws_subnet.set-22-pub-sub-1.id

  tags = {
    Name = "set-22-nat"
  }
}

// Public Route Table
resource "aws_route_table" "set-22-public-rt" {
  vpc_id = aws_vpc.set-22-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.set-22-igw.id
  }

  tags = {
    Name = "set-22-public-rt"
  }
}

// Route Table Association for Public Subnet 1
resource "aws_route_table_association" "set-22-public-rt-assoc-1" {
  subnet_id      = aws_subnet.set-22-pub-sub-1.id
  route_table_id = aws_route_table.set-22-public-rt.id
}

// Route Table Association for Public Subnet 2
resource "aws_route_table_association" "set-22-public-rt-assoc-2" {
  subnet_id      = aws_subnet.set-22-pub-sub-2.id
  route_table_id = aws_route_table.set-22-public-rt.id
}

// keypair
resource "aws_key_pair" "set-22-key" {
    key_name = "set-22-keypair"
    public_key = file("./ec2.pub")
}
