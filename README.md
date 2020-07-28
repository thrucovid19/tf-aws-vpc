# tf-aws-vpc

A Terraform module to create an Amazon Web Services (AWS) Virtual Private Cloud (VPC).

## Usage

This module creates a VPC alongside a variety of related resources, including:

- Public and private subnets
- Public and private route tables
- Elastic IPs
- Network Interfaces
- NAT Gateways
- An Internet Gateway

Example usage:

```hcl
module "vpc" {
  source = "github.com/thrucovid19/tf-aws-vpc"

  name = "Default"
  region = "us-east-1"
  key_name = "aws-key-pair"
  cidr_block = "10.0.0.0/16"
  public_subnet_cidr_blocks = ["10.0.0.0/24", "10.0.2.0/24"]
  management_subnet_cidr_blocks = ["10.0.10.0/24", "10.0.12.0/24"]
  private_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]

  environment = "Staging"
}
```

## Variables

- `name` - Name of the VPC (default: `Default`)
- `environment` - Name of environment this VPC is targeting (default: `Unknown`)
- `region` - Region of the VPC (default: `us-east-1`)
- `key_name` - EC2 Key pair name for the bastion
- `cidr_block` - CIDR block for the VPC (default: `10.0.0.0/16`)
- `public_subnet_cidr_blocks` - List of public subnet CIDR blocks (default: `["10.0.0.0/24","10.0.2.0/24"]`)
- `management_subnet_cidr_blocks` - List of public subnet CIDR blocks (default: `["10.0.10.0/24","10.0.12.0/24"]`)
- `private_subnet_cidr_blocks` - List of private subnet CIDR blocks (default: `["10.0.1.0/24", "10.0.3.0/24"]`)
- `availability_zones` - List of availability zones (default: `["us-east-1a", "us-east-1b"]`)
- `tags` - Extra tags to attach to the VPC resources (default: `{}`)

## Outputs

- `id` - VPC ID
- `public_subnet_ids` - List of public subnet IDs
- `private_subnets_ids` - List of private subnet IDs
- `cidr_block` - The CIDR block associated with the VPC
- `nat_gateway_ips` - List of Elastic IPs associated with NAT gateways
