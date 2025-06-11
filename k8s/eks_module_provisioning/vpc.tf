
// This is need for dynamically picking the region 
provider "aws" {
  region = "eu-central-1"
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
}

// Dynamically set the azs instead of hardcoding it, requires the region to be defined
data "aws_availability_zones" "azs" {}

module "eks-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"  //"5.1.2" "5.19.0"

  name = "eks-vpc"
  cidr = var.vpc_cidr_block
  /* Best practice: One private and One public subnet in each 
     of the az in the region where we are creating EKS 6 in total 
  */
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets = var.public_subnet_cidr_blocks
  // To define the azs and tell terraform to replicate the cidr block on all the azs
  azs = data.aws_availability_zones.azs.names

  enable_nat_gateway = true
  // All private subnets will route their internet traffic through single nat gateway
  single_nat_gateway = true
  enable_dns_hostnames = true

// The tags are there to help CCM (Cloud control Manager) to identify which resource to connect to
// In a situation where we have multiple cluster
  tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/myapp-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

}