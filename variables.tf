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

variable "wordwell_domain" {
  type    = string
  default = "wordwell.life"
}

variable "wordwell_image" {
  type    = string
  default = "shaqdevops/wordwell:latest"
}
