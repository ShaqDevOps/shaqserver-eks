output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "alb_hostname" {
  value = try(
    kubernetes_ingress_v1.main_ingress.status[0].load_balancer[0].ingress[0].hostname,
    "pending"
  )
  description = "The ALB hostname assigned to the main ingress"
}

output "wordwell_url" {
  value = "https://${var.wordwell_domain}"
}
