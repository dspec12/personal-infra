provider "aws" {
  region     = var.region
}


terraform {
  backend "remote" {
    # hostname = "app.terraform.io"
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


data "aws_availability_zones" "available" {}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.54.0"

  name = "KubeVPC"
  cidr = "10.0.0.0/16"

  azs = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24"]

private_subnet_tags =  {
  Envirnment = "${var.env_stage}"
  Type = "Private"
  "kubernetes.io/role/internal-elb" = "1"
}

public_subnet_tags =  {
  Envirnment = "${var.env_stage}"
  Type = "Public"
  "kubernetes.io/role/elb" = "1"
}

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support   = true

}
