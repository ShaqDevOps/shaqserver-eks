# shaqserver-eks

Terraform configuration for deploying a production-style Amazon EKS cluster for the website shaqserver.com.

This repository is intended to be a reusable starting point for hosting a web application on AWS using Terraform. It includes infrastructure for:

- Amazon EKS cluster provisioning
- Node groups and IAM permissions
- Amazon VPC networking
- Application Load Balancer integration
- Ingress and Kubernetes deployment resources
- DNS and ACM-related setup helpers

Although this repo is currently configured for shaqserver.com, the structure is designed so you can reuse it for other domains by replacing the values in variables and configuration files.

## What this repository is for

Use this repo when you want to:

- stand up an EKS cluster on AWS with Terraform
- expose an application through an ALB and ingress controller
- connect a domain such as shaqserver.com to the workload
- keep infrastructure configuration version-controlled and repeatable

## Reusability notes

This repo is reusable because most environment-specific values are meant to be customized. Before using it for another project, replace placeholders such as:

- domain names like `shaqserver.com`
- cluster names
- AWS region
- VPC CIDR blocks
- subnet ranges
- node instance types
- application names and namespaces

A good pattern is to treat this repo as a template and change values in the Terraform files and variables before first deployment.

## Prerequisites

Before deploying, make sure you have:

- Terraform installed
- AWS CLI configured with credentials
- kubectl installed
- Helm installed
- access to a domain name and DNS provider
- permissions to create IAM roles, EKS clusters, and load balancers in AWS

Example tools and versions:

```bash
terraform version
aws --version
kubectl version --client
helm version
```

## Quick start

1. Clone the repository:

```bash
git clone https://github.com/ShaqDevOps/shaqserver-eks.git
cd shaqserver-eks
```

2. Configure your AWS profile or environment:

```bash
export AWS_PROFILE=your-profile
export AWS_REGION=us-east-1
```

3. Initialize Terraform:

```bash
terraform init
```

4. Review the planned changes:

```bash
terraform plan
```

5. Apply the infrastructure:

```bash
terraform apply
```

6. Configure kubectl to use the EKS cluster:

```bash
aws eks update-kubeconfig --name <cluster-name> --region <aws-region>
```

## Recommended variables to customize

If you want to reuse this repository for another site, update values such as:

```hcl
variable "domain_name" {
  default = "shaqserver.com"
}

variable "environment" {
  default = "prod"
}

variable "aws_region" {
  default = "us-east-1"
}
```

You can also replace placeholders in the Terraform resources for:

- cluster name
- ingress hostnames
- certificate domain names
- application namespace
- node group sizing
- tags

## Example deployment workflow

A typical workflow for this repository looks like this:

```bash
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

After the cluster is ready, you can deploy your application with Kubernetes manifests or Helm charts and point your ingress to the hostname you want to serve.

## DNS and domain setup

For a production site like shaqserver.com, you will usually need:

- a public hosted zone in Route 53 or another DNS provider
- an ACM certificate for the domain and subdomains
- ingress annotations that point traffic to the application load balancer

Example domain placeholders:

- `shaqserver.com`
- `www.shaqserver.com`
- `api.shaqserver.com`

Replace these values with the actual hostnames you want to use.

## Useful commands

Check Terraform state:

```bash
terraform state list
```

Show current outputs:

```bash
terraform output
```

Destroy the infrastructure when needed:

```bash
terraform destroy
```

Inspect the Kubernetes resources after deployment:

```bash
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A
```

## Folder overview

- `main.tf` - core Terraform configuration
- `vpc.tf` - networking resources
- `eks.tf` - EKS cluster and node group definitions
- `ingress.tf` - ingress-related resources
- `k8s_app.tf` - Kubernetes deployment configuration
- `providers.tf` - provider configuration
- `variables.tf` - input variables
- `outputs.tf` - outputs for useful values

## Security and hygiene

Do not commit Terraform state, local provider caches, kubeconfigs, credentials, or generated output. These files are intentionally ignored in `.gitignore`.

If you are using this repository for a real production deployment, review IAM permissions, secrets management, and network policies before going live.

## Notes for future reuse

If you want to turn this into a strong reusable template for multiple websites, consider:

- moving domain-specific values into a `terraform.tfvars` file
- parameterizing cluster and app names
- using a separate environment folder for `dev`, `staging`, and `prod`
- adding modules for networking, EKS, and ingress to make the repo more modular

This repository is a good base for hosting a site such as shaqserver.com, but it can be adapted for other domains and applications with a small amount of customization.
