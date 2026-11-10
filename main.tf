resource "aws_vpc" "sch-vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "utc-vpc"
    env  = "dev"
    team = "config management"
  }
}

# 2. Create Public Subnet 1
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.sch-vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "school-public-1"
  }
}


# 3. Create Public Subnet 2
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.sch-vpc.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "school-public-2"
  }
}


# 4. Create Private Application Subnet 1
resource "aws_subnet" "private_app_1" {
  vpc_id                  = aws_vpc.sch-vpc.id
  cidr_block              = "10.10.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "school-private-app-1"
  }
}


# 5. Create Private Application Subnet 2
resource "aws_subnet" "private_app_2" {
  vpc_id                  = aws_vpc.sch-vpc.id
  cidr_block              = "10.10.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "school-private-app-2"
  }
}


# 6. Create Private Database Subnet 1
resource "aws_subnet" "private_db_1" {
  vpc_id                  = aws_vpc.sch-vpc.id
  cidr_block              = "10.10.5.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "school-private-db-1"
  }
}


# 7. Create Private Database Subnet 2
resource "aws_subnet" "private_db_2" {
  vpc_id                  = aws_vpc.sch-vpc.id
  cidr_block              = "10.10.6.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "school-private-db-2"
  }
}



# 8. Create Public Subnet 3
resource "aws_subnet" "public_3" {
  vpc_id                  = aws_vpc.sch-vpc.id
  cidr_block              = "10.10.7.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "school-public-3"
  }
}


# 9. Create Private Application Subnet 3
resource "aws_subnet" "private_app_3" {
  vpc_id                  = aws_vpc.sch-vpc.id
  cidr_block              = "10.10.8.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "school-private-app-3"
  }
}


# 10. Create Private Database Subnet 3
resource "aws_subnet" "private_db_3" {
  vpc_id                  = aws_vpc.sch-vpc.id
  cidr_block              = "10.10.9.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "school-private-db-3"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "school" {
  vpc_id = aws_vpc.sch-vpc.id

  tags = {
    Name = "school-tf-igw"
  }
}


# Elastic IP for NAT Gateway 1
resource "aws_eip" "nat_eip_1" {
  domain = "vpc"

  tags = {
    Name = "utc-nat-eip-1"
  }
}

# Elastic IP for NAT Gateway 2
resource "aws_eip" "nat_eip_2" {
  domain = "vpc"

  tags = {
    Name = "utc-nat-eip-2"
  }
}


# NAT Gateway 1
resource "aws_nat_gateway" "utc_nat_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.public_1.id

  depends_on = [aws_internet_gateway.school]

  tags = {
    Name = "utc-nat-gateway-1"
  }
}

# NAT Gateway 2
resource "aws_nat_gateway" "utc_nat_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.public_2.id

  depends_on = [aws_internet_gateway.school]

  tags = {
    Name = "utc-nat-gateway-2"
  }
}


# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.sch-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.school.id
  }

  tags = {
    Name = "school-public-route-table"
  }
}


# Connect Public Subnet 1A to Public Route Table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}


# Connect Public Subnet 1B to Public Route Table
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}


# Connect Public Subnet 1C to Public Route Table
resource "aws_route_table_association" "public_3" {
  subnet_id      = aws_subnet.public_3.id
  route_table_id = aws_route_table.public_rt.id
}


# Private Application Route Table 1
resource "aws_route_table" "private_app_rt_1" {
  vpc_id = aws_vpc.sch-vpc.id

  tags = {
    Name = "school-private-app-route-table-1"
  }
}

# Route private application traffic through NAT Gateway 1
resource "aws_route" "private_app_nat_1" {
  route_table_id         = aws_route_table.private_app_rt_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.utc_nat_1.id
}

# Associate private application subnet 1A
resource "aws_route_table_association" "private_app_1" {
  subnet_id      = aws_subnet.private_app_1.id
  route_table_id = aws_route_table.private_app_rt_1.id
}

# Associate private application subnet 1C
resource "aws_route_table_association" "private_app_3" {
  subnet_id      = aws_subnet.private_app_3.id
  route_table_id = aws_route_table.private_app_rt_1.id
}


# Private Application Route Table 2
resource "aws_route_table" "private_app_rt_2" {
  vpc_id = aws_vpc.sch-vpc.id

  tags = {
    Name = "school-private-app-route-table-2"
  }
}

# Route private application traffic through NAT Gateway 2
resource "aws_route" "private_app_nat_2" {
  route_table_id         = aws_route_table.private_app_rt_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.utc_nat_2.id
}

# Associate private application subnet 1B
resource "aws_route_table_association" "private_app_2" {
  subnet_id      = aws_subnet.private_app_2.id
  route_table_id = aws_route_table.private_app_rt_2.id
}

