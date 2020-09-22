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
  vpc_id = var.vpc_id

  tags = {
    Type = "Private"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}


data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.13"
}


# EKS
module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  version = "12.1.0"
  cluster_version = "1.16"
  cluster_name = "utils"
  subnets      = data.aws_subnet_ids.private.ids
  vpc_id = var.vpc_id
  wait_for_cluster_cmd          = "until curl -k -s $ENDPOINT/healthz >/dev/null; do sleep 4; done"
  cluster_endpoint_public_access = false
  cluster_endpoint_private_access = true

  cluster_endpoint_private_access_cidrs = [
    "10.0.0.0/16",
  ]

  tags = {
    Environment = var.env_stage
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 3
      # additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },

  ]
}



