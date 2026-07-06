#############################################
# Get current AWS caller identity
#############################################
data "aws_caller_identity" "current" {}

#############################################
# EKS Access Entry for the current Terraform runner
#############################################
resource "aws_eks_access_entry" "admin_user" {
  cluster_name  = var.cluster_name
  principal_arn = data.aws_caller_identity.current.arn
  type          = "STANDARD"

  depends_on = [module.eks]
}

#############################################
# Attach Cluster Admin Policy
#############################################
resource "aws_eks_access_policy_association" "admin_policy" {
  cluster_name  = var.cluster_name
  principal_arn = aws_eks_access_entry.admin_user.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin_user]
}

#############################################
# Data sources for Kubernetes and Helm providers
#############################################
data "aws_eks_cluster" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks,
    aws_eks_access_entry.admin_user,
    aws_eks_access_policy_association.admin_policy,
    null_resource.wait_for_access_ready
  ]
}
