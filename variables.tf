variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "cluster_name" {
  type    = string
  default = "meowmart-cluster"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "vpc_cidr" {
  type    = string
  default = "20.0.0.0/16"
}

variable "root_domain" {
  type    = string
  default = "shaqserver.com"
}

variable "additional_subdomains" {
  type        = list(string)
  default     = ["meowmart", "slide"]
  description = "Additional subdomains to create under the root domain"
}

variable "wordwell_domain" {
  type    = string
  default = "wordwell.life"
}

variable "wordwell_image" {
  type    = string
  default = "shaqdevops/wordwell:latest"
}

variable "app_name" {
  type        = string
  default     = "wordwell"
  description = "Name used for the main application deployment and service"
}

variable "app_container_port" {
  type        = number
  default     = 8000
  description = "Container port exposed by the main application"
}

variable "app_service_port" {
  type        = number
  default     = 8000
  description = "Service port exposed for the main application"
}

variable "namespace" {
  type        = string
  default     = "default"
  description = "Namespace used for Kubernetes resources"
}

variable "ingress_name" {
  type        = string
  default     = "main-ingress"
  description = "Name of the shared ingress resource"
}

variable "ingress_group_name" {
  type        = string
  default     = "shaqserver-group"
  description = "ALB ingress group name"
}

variable "meowmart_image" {
  type        = string
  default     = "shaqdevops/meowmart-app:latest"
  description = "Container image for the meowmart application"
}

variable "slide_backend_image" {
  type        = string
  default     = "shaqdevops/og-slide-backend:v6"
  description = "Container image for the slide backend"
}

variable "slide_frontend_image" {
  type        = string
  default     = "shaqdevops/og-slide-frontend:v75"
  description = "Container image for the slide frontend"
}

variable "landing_page_image" {
  type        = string
  default     = "shaqdevops/landing-page:latest"
  description = "Container image for the landing page"
}
