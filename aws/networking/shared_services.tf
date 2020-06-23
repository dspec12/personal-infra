provider "aws" {
  region     = var.region
}


terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "dspec12-personal"
    workspaces {
      prefix = "networking-"
    }
  }
}


data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.43.0"

  name = "shared-services-${var.env_stage}"
  cidr = "10.0.0.0/16"

  azs = var.azs 
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.13.0/24"]

private_subnet_tags =  {
  env_stage = "${var.env_stage}"
  type = "private"
}

private_subnet_tags =  {
  env_stage = "${var.env_stage}"
  type = "public"
}

database_subnet_tags =  {
  env_stage = "${var.env_stage}"
  type = "database"
}

  enable_nat_gateway = true
  enable_vpn_gateway = true
  create_database_subnet_group = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC endpoint for KMS
  enable_kms_endpoint = true
  kms_endpoint_private_dns_enabled = true
  kms_endpoint_security_group_ids = [data.aws_security_group.default.id]

}
