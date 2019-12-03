provider "aws" {
  region = "eu-central-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "simple-example"

  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.2.0/24"]

  enable_ipv6 = false

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc-name"
  }
}

module "terraform-aws-bastion-ssm-iam" {
  source = "../../"

  # The name used to interpolate in the resources, defaults to bastion-ssm-iam
  # name = "bastion-ssm-iam"

  # The vpc id
  vpc_id = module.vpc.vpc_id

  # subnet_ids designates the subnets where the bastion can reside
  subnet_ids = module.vpc.private_subnets

  # The module creates a security group for the bastion by default
  # create_security_group = true

  # The module can create a diffent ssm document for this deployment, to allow
  # different security models per BASTION deployment
  # create_new_ssm_document = false

  # It is possible to attach other security groups to the bastion.
  # security_group_ids = []
}
