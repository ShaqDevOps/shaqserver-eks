resource "null_resource" "wait_for_cluster" {
  provisioner "local-exec" {
    command = "aws eks wait cluster-active --name ${var.cluster_name} --region ${var.region}"
  }

  depends_on = [module.eks]
}

resource "null_resource" "wait_for_access_ready" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for EKS access propagation..."
      for i in {1..30}; do
        aws eks describe-cluster --name ${var.cluster_name} >/dev/null 2>&1 && break || sleep 10
      done
      echo "EKS cluster access ready."
    EOT
  }
}

resource "time_sleep" "wait_for_alb" {
  depends_on      = [kubernetes_ingress_v1.main_ingress]
  create_duration = "60s"
}

resource "time_sleep" "wait_for_alb_dns" {
  depends_on      = [kubernetes_ingress_v1.main_ingress]
  create_duration = "30s"
}

resource "null_resource" "verify_cluster_connection" {
  provisioner "local-exec" {
    command = "aws eks describe-cluster --name ${var.cluster_name} --region ${var.region} >/dev/null && echo '✅ Connected to EKS successfully'"
  }

  depends_on = [data.aws_eks_cluster.this]
}
