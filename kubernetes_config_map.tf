resource "kubernetes_service_account" "alb_controller_sa" {
  provider = kubernetes.eks

  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = module.alb_controller_irsa.iam_role_arn
    }
  }

  depends_on = [
    module.alb_controller_irsa,
    module.eks,
    null_resource.wait_for_cluster,
    data.aws_eks_cluster.this,
    data.aws_eks_cluster_auth.this
  ]
}
