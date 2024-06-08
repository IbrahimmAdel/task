provider "aws" {
  profile  = var.profile
  region   = var.region
}

module "network" {
  source       = "./modules/network"
  vpc_cidr     = var.vpc_cidr
  pub_subnets  = var.public_subnets
  priv_subnets = var.private_subnets
}

module "eks" {
  source                 = "./modules/eks"
  eni_subnet_ids         = module.network.private_subnets_id
  nodegroup_subnets_id   = module.network.private_subnets_id
}

#${module.eks.eks_cluster_name}
output "update_local_context_command" {
  description = "Command to update local kube context"
  value = "aws eks update-kubeconfig --name=project-cluster --region=${var.region}"

}

