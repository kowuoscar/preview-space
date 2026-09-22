variable "region" {
  type    = string
  default = "eu-west-1"
  validation {
    condition     = can(regex("^eu-", var.region))
    error_message = "EU regions only."
  }
}

variable "project" {
  type    = string
  default = "preview-space"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "node_groups" {
  type = map(object({ instance_type = string, desired = number }))
  default = {
    "general" = { instance_type = "t3.medium", desired = 2 }
  }
}

locals {
  cluster_name = "${var.project}-${var.env}"
  tags         = { Project = var.project, ManagedBy = "terraform" }
}

# SUBNETS

variable "public_subnet_cidrs" {
  type = list(string)
  description = "Public Subnet CIDR values"
  default = [ "10.0.1.0/24", "10.0.2.0/24" ]
}

variable "private_subnet_cidrs" {
  type = list(string)
  description = "Private Subnet CIDR values"
  default = [ "10.0.3.0/24", "10.0.4.0/24" ]
}