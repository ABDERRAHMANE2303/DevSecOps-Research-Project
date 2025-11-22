variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix this project's resources"
  type        = string
  default     = "devsecopsproject"
}

variable "azs" {
  description = "availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "admin_ip"{
  description = "value of the current admin ip adress "
  type = string 
}

variable "bastion_key_name" {
  description = "EC2 key pair name to SSH into bastion"
  type        = string
}

variable "instances_key_name" {
  description = "EC2 key pair name used by private app instances (SSH from bastion)"
  type        = string
}


locals {
  common_tags = {
    Project = "DevSecOpsProject"
    Owner   = "AQ"
    Env     = "DevProd"
  }
  azs = var.azs
  name_prefix = var.name_prefix
}

locals {
  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]
}