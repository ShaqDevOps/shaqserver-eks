# #####################################
# # BEFORE RESOURCES AVE BEEN LAUNCHED#
# #####################################
# |
# #############################################
# # Kubernetes Provider
# #############################################
# provider "kubernetes" {
#   alias                  = "eks"
#   # host                   = data.aws_eks_cluster.this.endpoint
#   host = data.aws_eks_cluster.this.endpoint

#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.this.token
#   # Use exec-based auth as backup
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--region", var.region, "--cluster-name", var.cluster_name]
#   }
# }

# #############################################
# # Helm Provider
# #############################################
# provider "helm" {
#   alias = "eks"

#   kubernetes = {
#     host                   = data.aws_eks_cluster.this.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
#     token                  = data.aws_eks_cluster_auth.this.token
#   }
# }




# # Default provider (for data sources/imports that forget alias)
# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.this.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.this.token
# }


#######################################################################################################################################
#COMMENT THIS OUT AND USE THESE CONFIGS AFTER RESOURCES HAVE ALREADY BEEN LAUNCHED TO AVOID DEPENDENCY LOOP
#######################################################################################################################################


#############################################
# Kubernetes Provider - aliased (required by existing state)
#############################################
provider "kubernetes" {
  alias       = "eks"
  config_path = "~/.kube/config"
}

#############################################
# Kubernetes Provider - default
#############################################
provider "kubernetes" {
  config_path = "~/.kube/config"
}

#############################################
# Helm Provider - aliased (required by existing state)
#############################################
provider "helm" {
  alias = "eks"

  kubernetes = {
    config_path = "~/.kube/config"
  }
}

#############################################
# Helm Provider - default
#############################################
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}
