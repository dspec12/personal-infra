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


module "eks-cluster" {
  source  = "cloudposse/eks-cluster/aws"
  version = "0.22.0"
  
  name       = utils
  region     = var.region
  stage      = var.env_stage
  vpc_id     = "vpc-09c5f5535f9ee0320"
  subnet_ids = data.aws_subnet_ids.private.ids
  kubernetes_version    = 1.16
  oidc_provider_enabled = false

  # workers_security_group_ids   = [module.eks_workers.security_group_id]
  # workers_role_arns            = [module.eks_workers.workers_role_arn]

}
