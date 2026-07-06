############################################
# Route53 Zone (wordwell.life)
############################################
data "aws_route53_zone" "wordwell" {
  name         = "${var.wordwell_domain}."
  private_zone = false
}

############################################
# ACM: WordWell (wordwell.life)
############################################
resource "aws_acm_certificate" "wordwell" {
  domain_name       = var.wordwell_domain
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
}

resource "aws_route53_record" "wordwell_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.wordwell.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id         = data.aws_route53_zone.wordwell.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.value]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "wordwell" {
  certificate_arn         = aws_acm_certificate.wordwell.arn
  validation_record_fqdns = [for r in aws_route53_record.wordwell_cert_validation : r.fqdn]
}

############################################
# WordWell app
############################################
resource "kubernetes_deployment" "wordwell" {
  provider = kubernetes.eks

  depends_on = [
    module.eks,
    null_resource.wait_for_cluster,
    null_resource.wait_for_access_ready,
    aws_eks_access_policy_association.admin_policy
  ]

  metadata {
    name   = var.app_name
    labels = { app = var.app_name }
  }

  spec {
    replicas = 1

    selector { match_labels = { app = var.app_name } }

    template {
      metadata { labels = { app = var.app_name } }

      spec {
        container {
          name              = var.app_name
          image_pull_policy = "Always"
          image             = var.wordwell_image

          port { container_port = var.app_container_port }

          env {
            name  = "DJANGO_DEBUG"
            value = "true"
          }

          env {
            name  = "ALLOWED_HOSTS"
            value = join(",", [var.wordwell_domain, "localhost", "127.0.0.1", "[::1]"])
          }

          env {
            name = "POD_IP"

            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          env {
            name  = "CSRF_TRUSTED_ORIGINS"
            value = "https://${var.wordwell_domain}"
          }

          readiness_probe {
            http_get {
              path = "/healthz/"
              port = 8000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/healthz/"
              port = 8000
            }
            initial_delay_seconds = 30
            period_seconds        = 20
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "768Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wordwell" {
  provider   = kubernetes.eks
  depends_on = [kubernetes_deployment.wordwell]

  metadata {
    name = var.app_name
  }

  spec {
    selector = { app = var.app_name }

    port {
      port        = var.app_service_port
      target_port = var.app_container_port
    }

    type = "ClusterIP"
  }
}

############################################
# Route53 A/ALIAS record -> shared ALB
############################################
resource "aws_route53_record" "wordwell_alias" {
  zone_id         = data.aws_route53_zone.wordwell.zone_id
  name            = var.wordwell_domain
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = data.kubernetes_ingress_v1.main.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_elb_hosted_zone_id.alb.id
    evaluate_target_health = false
  }

  depends_on = [data.kubernetes_ingress_v1.main]
}
