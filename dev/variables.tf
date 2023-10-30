variable "bca-aws-master-region" {
  type    = string
  default = "ap-southeast-1"
}

# VPC Variables
variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string
  default     = "10.10.0.0/16"
}

#This is a Environement variable 
variable "environment" {
  description = "Environment name for deployment"
  type        = string
  # default     = "contoso-dev"
}