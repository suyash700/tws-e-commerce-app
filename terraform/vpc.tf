module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.name}-vpc"
  cidr = local.vpc-cidr

  azs             = local.my_azs
  private_subnets = local.my_private_subnets
  public_subnets  = local.my_public_subnets
  intra_subnets  =  local.my_intra_subnets
  enable_nat_gateway = true
  enable_vpn_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

    private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Terraform = "true"
    Environment = "dev"
    name = local.name
  }

     # Ensure public subnets auto-assign public IPs
  map_public_ip_on_launch = true
}