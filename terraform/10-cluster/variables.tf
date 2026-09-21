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
  default = "Dev"
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