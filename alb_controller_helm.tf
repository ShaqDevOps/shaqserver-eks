resource "helm_release" "aws_load_balancer_controller" {
  provider = helm.eks

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"



  depends_on = [
    module.eks,
    module.alb_controller_irsa,
    null_resource.wait_for_cluster,
    aws_eks_access_policy_association.admin_policy
  ]

  values = [yamlencode({
    clusterName = module.eks.cluster_name
    region      = var.region
    serviceAccount = {
      create = false
      name   = kubernetes_service_account.alb_controller_sa.metadata[0].name

    }
    enableServiceMutatorWebhook = false
    enableIngressFinalizer      = false # Disables Finalizers
    defaultTags = {
      "auto-delete" = "no"
    }
  })]
}


