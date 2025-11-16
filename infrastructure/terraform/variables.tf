variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix this project's resources"
  type        = string
  default     = "DevSecOpsProject"
}

variable "azs" {
  description = "availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

locals {
  common_tags = {
    Project = "DevSecOpsProject"
    Owner   = "AhssenQuadrinome"
    Env     = "DevProd"
  }
  azs = var.azs
  name_prefix = var.name_prefix
}
