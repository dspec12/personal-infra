provider "aws" {
  region     = var.region
}


terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "dspec12-personal"
    workspaces {
      prefix = "eks-"
    }
  }
}


data "aws_subnet_ids" "private" {
  vpc_id = "vpc-09c5f5535f9ee0320"

  tags = {
    type = "private"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}


data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# EKS
module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = utils
  subnets      = data.aws_subnet_ids.private.ids
  vpc_id = "vpc-09c5f5535f9ee0320"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true

  tags = {
    Environment = var.env_stage
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },

    {
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]
}


# Security Groups
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.eks.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = module.eks.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}
