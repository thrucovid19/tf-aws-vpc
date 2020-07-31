variable "name" {
  default     = "Default"  
  type        = string
  description = "Name of the VPC"
}

variable "environment" {
  type        = string
  description = "Name of environment: ex. stg, prod, dev"
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Region of the VPC"
}

variable "key_name" {
  type        = string
  description = "EC2 Key pair name"
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "mgmt_subnet" {
  default     = "192.168.1.0/24"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "management_subnet_cidr_blocks" {
  default     = ["10.0.10.0/24", "10.0.12.0/24"]
  type        = list
  description = "List of management subnet CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
  type        = list
  description = "List of private subnet CIDR blocks"
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b"]
  type        = list
  description = "List of availability zones"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}
