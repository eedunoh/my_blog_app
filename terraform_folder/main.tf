
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


terraform {
  backend "s3" {
    bucket = "app-remote-state-bucket-fyi"
    key    = "jenkins/terraform.tfstate"
    region = "eu-north-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-north-1"
}



# Since this project uses a CI/CD pipeline, Jenkins will be deployed first (if it hasn't been created already).
# See jenkins deployment files here: https://github.com/eedunoh/terraform_jenkins_aws_install.git

# To proceed with this project, you must first create the VPC, subnets, and install Jenkins using the files in the repository above. 


# We will use the default (existing) vpc. We dont want to create another one


# Use terraform import if you want Terraform to manage the resource.
# Use data block if you just need to reference an existing resource without managing it.

# AWS is case-sensitive when querying data sources compared to when creating them using aws resources
# Always check how your data is structured especially tags before using them. "is-default" != "is_default"


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
    values = [data.aws_vpc.existing_vpc.id]  # Fetch subnets from the default (existing) VPC - The default VPC has public subnets only. No private subnet.
  }
}


output "main_vpc_id" {
  value = data.aws_vpc.existing_vpc.id
}

output "main_public_subnets" {
  value = data.aws_subnets.public_subnets.ids
}

