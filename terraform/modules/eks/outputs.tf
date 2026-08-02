output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = aws_eks_cluster.this.arn
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID."
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "EKS node security group ID for database ingress rules."
  value       = aws_security_group.nodes.id
}

output "node_role_arn" {
  description = "EKS node IAM role ARN."
  value       = aws_iam_role.nodes.arn
}

output "secrets_kms_key_arn" {
  description = "KMS key ARN used for EKS secret encryption."
  value       = aws_kms_key.eks_secrets.arn
}

output "ebs_csi_pod_identity_role_arn" {
  description = "Pod Identity role ARN used by the EBS CSI driver."
  value       = aws_iam_role.ebs_csi_pod_identity.arn
}
