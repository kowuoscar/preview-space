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

resource "aws_subnet" "preview-space-public-subnets" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.preview-space-vpc.id
  cidr_block = element(var.public_subnet_cidrs, count.index)

  tags = {
    Name = "Preview Space Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "preview-space-private-subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.preview-space-vpc.id
  cidr_block = element(var.private_subnet_cidrs, count.index)

  tags = {
    Name = "Preview Space Private Subnet ${count.index + 1}"
  }
}