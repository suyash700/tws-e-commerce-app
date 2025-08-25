output "vpc_id" {
  description = "VPC ID"
  value = module.vpc.vpc_id
}

output "region" {
  description = "region"
  value = var.region
}

output "eks_cluster_name" {
  description = "eks cluster name"
  value = module.eks.cluster_name
}


output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.my-ec2-instance.public_ip
}

output "eks_node_group_public_ips" {
  description = "Public IPs of the EKS node group instances"
  value       = data.aws_instances.eks_nodes.public_ips
}
