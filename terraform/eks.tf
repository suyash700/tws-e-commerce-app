module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # EKS Managed Node Group(s)

  eks_managed_node_group_defaults = {

    instance_types =  local.node_types

    attach_cluster_primary_security_group = true

  }


  eks_managed_node_groups = {

    suyash-ng = {
      Name = "${local.Node_name}"
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = local.node_types
      capacity_type  = "SPOT"

      disk_size = 25
      use_custom_launch_template = false  # Important to apply disk size!

      tags = {
        Name = "suyash-ng"
        Environment = "dev"
        ExtraTag = "e-commerce-app"
      }
    }
  }
 
  tags = local.tags

}
# Security Group Rules for NodePort and port 8080
resource "aws_security_group_rule" "eks_nodes_nodeport_ingress" {
  type              = "ingress"
  description       = "Allow NodePort range and port 8080"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.node_security_group_id
}

data "aws_instances" "eks_nodes" {
  instance_tags = {
    "eks:cluster-name" = module.eks.cluster_name
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [module.eks]
}