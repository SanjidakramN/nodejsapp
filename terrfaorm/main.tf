provider "aws" {
  region = var.aws_region
}


resource "aws_vpc" "main" {
  cidr_block = var.vpc_main
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-sub"
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-sub"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name ="igw"
  }
}

resource "aws_eip" "nat" {
  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public[0].id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route" "public-default" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "private-rt"
  }
}

resource "aws_route" "private-default" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "ssh" {
  name = "ssh-group"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "0.0.0.0/0"

  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = "0.0.0.0/0"
  }
}

resource "aws_instance" "instance" {
  ami = "ami-05ffe3c48a9991133"
  instance_type = "t2.micro"
vpc_security_group_ids = [ aws_security_group.ssh.id ]
  subnet_id = aws_subnet.public.id
  key_name = "sanju"
tags = {
  Name = "new-one"
}
}

