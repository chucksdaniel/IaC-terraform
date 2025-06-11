module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.2" // "20.34.0"

  cluster_name = "myapp-eks-cluster"
  cluster_version = "1.27"

// List of subnet where Worker node 
  subnet_ids = module.eks-vpc.private_subnets
  vpc_id = module.eks-vpc.vpc_id

  // To ensure that the cluster is reachable
  cluster_endpoint_public_access  = true

  tags = {
    environment = "development"
    application = "myapp"
  }

// The minimum requirement
  eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t2.small"]
    }
  }
}

