
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-north-1"
}


# We will use the default (existing) vpc. We dont want to create another one
data "aws_vpc" "existing_vpc" {
  filter {
    name   = "is-default"
    values = ["true"]   # Set to "false" if you're using a non-default VPC
  }
}


# We are extracting the subnet from the default vpc
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing_vpc.id]  # Fetch subnets from the default (existing) VPC
  }
}


output "main_vpc_id" {
  value = data.aws_vpc.existing_vpc.id
}

output "main_public_subnets" {
  value = data.aws_subnets.public_subnets.ids
}

