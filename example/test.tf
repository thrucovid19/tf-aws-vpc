terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "aws" {
  version                 = "~> 2.0"
  shared_credentials_file = var.credentials
  region                  = var.region
}

resource "aws_key_pair" "thrucovid19" {
  key_name   = "terraform-key"
  public_key = file("~/.ssh/terraform-key.pub")
}

module "tf-aws-vpc" {
  source         = "github.com/thrucovid19/tf-aws-vpc"
  name           = "Test"
  environment    = "testing"
  key_name       = aws_key_pair.thrucovid19.key_name
  mgmt_subnet    = "192.168.1.0/24"
}