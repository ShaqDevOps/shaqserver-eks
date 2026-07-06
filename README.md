# shaqserver-eks

Terraform configuration for deploying a production-style Amazon EKS cluster for a website such as shaqserver.com.

This repository is now structured as a reusable Terraform template for hosting web applications on AWS. It includes infrastructure for:

- Amazon EKS cluster provisioning
- managed node groups and IAM permissions
- Amazon VPC networking
- Application Load Balancer integration
- ingress and Kubernetes deployment resources
- DNS and ACM-related setup helpers

The repo is designed so you can reuse it for other sites by overriding the values in variables and using a custom Terraform variables file.

## Reusable template design

The main values that should be changed per deployment are now centralized in [variables.tf](variables.tf) and can be overridden in a file such as [terraform.tfvars.example](terraform.tfvars.example).

Examples of values to customize:

- domain names and subdomains
- cluster name
- AWS region
- VPC CIDR
- application name
- application container images
- ingress name and group
- Kubernetes namespace

## Prerequisites

Before deploying, make sure you have:

- Terraform installed
- AWS CLI configured with credentials
- kubectl installed
- Helm installed
- a domain name and DNS provider available
- permissions to create IAM roles, EKS clusters, and load balancers in AWS

Check versions:

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

2. Copy the example variables file and edit it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

3. Update the values in `terraform.tfvars` for your own website and AWS environment.

4. Initialize Terraform:

```bash
terraform init
```

5. Review the plan:

```bash
terraform plan -var-file=terraform.tfvars
```

6. Apply the infrastructure:

```bash
terraform apply -var-file=terraform.tfvars
```

7. Configure kubectl for the new cluster:

```bash
aws eks update-kubeconfig --name <cluster-name> --region <aws-region>
```

## Recommended values to customize

At minimum, update these before using the repo for another website:

```hcl
root_domain = "example.com"
additional_subdomains = ["app", "admin"]
wordwell_domain = "app.example.com"
cluster_name = "my-cluster"
region = "us-east-1"
```

You can also swap out the deployment images and ports for your own applications.

## Example workflow

```bash
terraform fmt
terraform validate
terraform plan -var-file=terraform.tfvars -out=tfplan
terraform apply tfplan
```

## DNS and ACM notes

For a production site, you will usually need:

- a public hosted zone in Route 53 or another DNS provider
- an ACM certificate for the root domain and chosen subdomains
- ingress annotations that point traffic to the ALB

Example placeholders:

- `example.com`
- `www.example.com`
- `api.example.com`

## Useful commands

Check Terraform state:

```bash
terraform state list
```

Show outputs:

```bash
terraform output
```

Destroy the infrastructure when needed:

```bash
terraform destroy -var-file=terraform.tfvars
```

Inspect the Kubernetes resources after deployment:

```bash
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A
```

## Folder overview

- [main.tf](main.tf) - core Terraform configuration
- [vpc.tf](vpc.tf) - networking resources
- [eks.tf](eks.tf) - EKS cluster and node group definitions
- [ingress.tf](ingress.tf) - ingress-related resources
- [k8s_app.tf](k8s_app.tf) - example Kubernetes deployment configuration
- [providers.tf](providers.tf) - provider configuration
- [variables.tf](variables.tf) - input variables
- [outputs.tf](outputs.tf) - outputs for useful values

## Security and hygiene

Do not commit Terraform state, local provider caches, kubeconfigs, credentials, or generated output. These files are intentionally ignored in [.gitignore](.gitignore).

For real deployments, review IAM permissions, secrets management, and network policies before going live.
