resource "kubernetes_deployment" "meowmart" {
  provider = kubernetes.eks
  depends_on = [module.eks,
    null_resource.wait_for_cluster,

    aws_eks_access_policy_association.admin_policy
  ]

  metadata {
    name   = "meowmart"
    labels = { app = "meowmart" }
  }

  spec {
    replicas = 1
    selector { match_labels = { app = "meowmart" } }

    template {
      metadata { labels = { app = "meowmart" } }
      spec {
        container {
          name              = "meowmart"
          image_pull_policy = "Always"
          image             = "shaqdevops/meowmart-app:latest"

          port { container_port = 9000 }

          resources {
            requests = { cpu = "100m", memory = "128Mi" }
            limits   = { cpu = "250m", memory = "256Mi" }
          }
        }
      }
    }
  }
}


resource "kubernetes_deployment" "slide_backend" {
  depends_on = [
    module.eks,
    null_resource.wait_for_cluster,
    null_resource.wait_for_access_ready,
    aws_eks_access_policy_association.admin_policy
  ]
  metadata {
    name = "slide-backend"
    labels = {
      app = "slide-backend"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "slide-backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "slide-backend"
        }
      }

      spec {
        container {
          name  = "slide-backend"
          image = "shaqdevops/og-slide-backend:v6"
          port {
            container_port = 8000
          }

        }
      }
    }
  }
}

resource "kubernetes_deployment" "slide_frontend" {
  depends_on = [
    module.eks,
    null_resource.wait_for_cluster,
    null_resource.wait_for_access_ready,
    aws_eks_access_policy_association.admin_policy
  ]
  metadata {
    name = "slide-frontend"
    labels = {
      app = "slide-frontend"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "slide-frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "slide-frontend"
        }
      }

      spec {
        container {
          name              = "slide-frontend"
          image_pull_policy = "Always"
          image             = "shaqdevops/og-slide-frontend:v75"


          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "meowmart" {
  provider   = kubernetes.eks
  depends_on = [kubernetes_deployment.meowmart]

  metadata {
    name = "meowmart-service"
  }

  spec {
    selector = { app = "meowmart" }

    port {
      name        = "web"
      port        = 9000
      target_port = 9000
      protocol    = "TCP"
    }
    type = "ClusterIP"

  }
}

resource "kubernetes_service" "slide_backend" {
  depends_on = [
    module.eks,
    null_resource.wait_for_cluster,
    null_resource.wait_for_access_ready,
    aws_eks_access_policy_association.admin_policy
  ]
  metadata {
    name = "slide-backend"
  }

  spec {
    selector = {
      app = "slide-backend"
    }

    port {
      port        = 8000
      target_port = 8000
    }
  }
}


resource "kubernetes_service" "slide_frontend" {
  depends_on = [
    module.eks,
    null_resource.wait_for_cluster,
    null_resource.wait_for_access_ready,
    aws_eks_access_policy_association.admin_policy
  ]
  metadata {
    name = "slide-frontend"
  }

  spec {
    selector = {
      app = "slide-frontend"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}


resource "kubernetes_deployment" "landing_page" {
  depends_on = [
    module.eks,
    null_resource.wait_for_cluster,
    null_resource.wait_for_access_ready,
    aws_eks_access_policy_association.admin_policy
  ]
  metadata {
    name   = "landing-page"
    labels = { app = "landing-page" }
  }

  spec {
    replicas = 1
    selector { match_labels = { app = "landing-page" } }

    template {
      metadata { labels = { app = "landing-page" } }
      spec {
        container {
          name  = "landing-page"
          image = "shaqdevops/landing-page:latest"
          port { container_port = 80 }
        }
      }
    }
  }
}

resource "kubernetes_service" "landing_page" {
  depends_on = [
    module.eks,
    null_resource.wait_for_cluster,
    null_resource.wait_for_access_ready,
    aws_eks_access_policy_association.admin_policy
  ]
  metadata { name = "landing-page" }

  spec {
    selector = { app = "landing-page" }
    port {
      port        = 80
      target_port = 80
    }
    type = "ClusterIP"
  }
}
