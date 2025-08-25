locals {
   name = "suyas-eks-cluster"
   vpc-cidr  = "10.0.0.0/16"
   my_azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
   my_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
   my_public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
   my_intra_subnets = ["10.0.5.0/24", "10.0.6.0/24", "10.0.7.0/24"]

   node_types = ["t2.large"]

    tags = {
    example = local.name
  }
   
}

