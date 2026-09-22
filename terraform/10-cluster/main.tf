provider "aws" {
  region = var.region
}

# Defining the vpc which will hold the Kubernetes cluster
# A vpc is a private network inside AWS infrastructure
# For a kubernetes cluster, for HA, AWS will require a minimum of 2 nodes spreads across two AZs
# Each AZ get its own private and public networks and a NAT gateway
# The NAT gateway enables the resource in the private network to reach internet and other services in AWS such as ECR 
# The public network is where load balancer, API Gateway lives, they authorize incoming and outgoing requests.
# The private network only authorize incoming requests from the public network if I understand correctly
resource "aws_vpc" "preview-space-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Preview Space VPC"
  }
}

# --- PROVISION OF PUBLIC AND PRIVATE SUBNETS ---

resource "aws_subnet" "preview-space-public-subnets" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.preview-space-vpc.id
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Preview Space Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "preview-space-private-subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.preview-space-vpc.id
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "Preview Space Private Subnet ${count.index + 1}"
  }
}

# --- VPC INTERNET GATEWAY ---

resource "aws_internet_gateway" "preview-space-internet-gateway" {
  vpc_id = aws_vpc.preview-space-vpc.id

  tags = {
    Name = "Preview Space Internet Gateway"
  }
}

# --- PUBLIC ROUTE TABLES TO ALLOW TRAFFIC INTO PUBLIC SUBNETS ---

resource "aws_route_table" "preview-space-public-route-table" {
  vpc_id = aws_vpc.preview-space-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.preview-space-internet-gateway.id
  }

  tags = {
    Name = "Preview Space Public Route Table" 
  }
}

resource "aws_route_table_association" "preview-space-public-route-asso" {
  count = length(var.public_subnet_cidrs)
  subnet_id = element(aws_subnet.preview-space-public-subnets[*].id, count.index)
  route_table_id = aws_route_table.preview-space-public-route-table.id
}

# --- ELASTIC IP ADDRESSES FOR NAT GATEWAY, ONE FOR EACH AZ ---

resource "aws_eip" "preview-space-eips" {
  count = length(var.public_subnet_cidrs)
  domain = "vpc"
  
  tags = {
    Name = "Preview Space Elastic IP ${count.index + 1}"
  }

  depends_on = [ aws_internet_gateway.preview-space-internet-gateway ]
}

# --- NAT GATEWAY FOR EACH AZ

resource "aws_nat_gateway" "preview-space-nat-gateways" {
  count = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.preview-space-eips[count.index].id
  subnet_id = element(aws_subnet.preview-space-public-subnets[*].id, count.index)

  tags = {
    Name =  "Preview Space NG ${count.index + 1}"
  }

  depends_on = [ aws_internet_gateway.preview-space-internet-gateway ]
}

# Configuration of private route tables for each AZs

resource "aws_route_table" "preview-space-private-route-tables" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.preview-space-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.preview-space-nat-gateways[count.index].id
  }

  tags = {
    Name = "Preview Space Private Route ${count.index + 1}" 
  }
}

resource "aws_route_table_association" "preview-space-private-routes-asso" {
  count = length(var.private_subnet_cidrs)
  subnet_id = element(aws_subnet.preview-space-private-subnets[*].id, count.index)
  route_table_id = element(aws_route_table.preview-space-private-route-tables[*].id, count.index)
}