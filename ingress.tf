#############################################
# Shared ALB ingress for all subdomains
#############################################
resource "kubernetes_ingress_v1" "main_ingress" {
  provider = kubernetes.eks

  depends_on = [
    helm_release.aws_load_balancer_controller,
    aws_acm_certificate_validation.wildcard,
    aws_acm_certificate_validation.wordwell
  ]

  metadata {
    name      = var.ingress_name
    namespace = var.namespace

    annotations = {
      "kubernetes.io/ingress.class"            = "alb"
      "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"  = "ip"
      "alb.ingress.kubernetes.io/group.name"   = var.ingress_group_name
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\":80,\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"
      "alb.ingress.kubernetes.io/certificate-arn" = join(",", [
        aws_acm_certificate_validation.wildcard.certificate_arn,
        aws_acm_certificate_validation.wordwell.certificate_arn
      ])
    }
  }

  spec {
    # Landing page - root domain
    rule {
      host = var.root_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.landing_page.metadata[0].name
              port { number = 80 }
            }
          }
        }
      }
    }

    # Additional app subdomain
    rule {
      host = "${var.additional_subdomains[0]}.${var.root_domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.meowmart.metadata[0].name
              port { number = 9000 }
            }
          }
        }
      }
    }

    # Additional app subdomain
    rule {
      host = "${var.additional_subdomains[1]}.${var.root_domain}"
      http {
        # Frontend (Vue/Nginx)
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.slide_frontend.metadata[0].name
              port { number = 80 }
            }
          }
        }

        # Backend (Django)
        # path {
        #   path      = "/"
        #   path_type = "Prefix"
        #   backend {
        #     service {
        #       name = kubernetes_service.slide_backend.metadata[0].name
        #       port { number = 8000 }
        #     }
        #   }
        # }
      }
    }

    # WordWell root domain
    rule {
      host = var.wordwell_domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.wordwell.metadata[0].name
              port { number = 8000 }
            }
          }
        }
      }
    }
  }

  wait_for_load_balancer = true
}

data "kubernetes_ingress_v1" "main" {
  provider = kubernetes.eks
  metadata {
    name      = var.ingress_name
    namespace = var.namespace
  }
  depends_on = [kubernetes_ingress_v1.main_ingress]
}

data "aws_elb_hosted_zone_id" "alb" {}
