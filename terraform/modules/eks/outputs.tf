output "eks_profile" {
    value = aws_iam_instance_profile.profile.name
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.id
}

output "eks_cluster_endpoint" {
    value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_certificate_authority_data" {
    value = aws_eks_cluster.eks_cluster.certificate_authority
}
