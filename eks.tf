module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                    = var.cluster_name
  cluster_version                 = "1.35"
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  vpc_id = aws_vpc.main.id
  subnet_ids = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1b.id,
    aws_subnet.private_1a.id,
    aws_subnet.private_1b.id
  ]

  enable_irsa = true

  cluster_addons = {
    coredns = {
      addon_version               = "v1.14.2-eksbuild.4"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }

    kube-proxy = {
      addon_version               = "v1.35.3-eksbuild.5"
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }

    vpc-cni = {
      addon_version               = "v1.21.1-eksbuild.8"
      before_compute              = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }

  #Just 1 node for testingterraform validate
  eks_managed_node_groups = {
    default = {
      desired_size   = 1
      min_size       = 1
      max_size       = 3
      instance_types = [var.instance_type]

      ami_type = "AL2023_x86_64_STANDARD"

      tags = {
        "k8s.io/cluster/${var.cluster_name}" = "owned"
        "k8s.io/role/elb"                    = "1"
        "auto-delete"                        = "no"
        "Name"                               = "meowmart-node"
      }

      labels = {
        "node-type" = "worker"
      }
    }
  }

  tags = {
    Project       = var.cluster_name
    "auto-delete" = "no"
    "Name"        = "meowmart-cluster"
  }


}



############################################################
# Tag all Auto Scaling Groups created by EKS-managed nodes
############################################################

# Step 1: Data source to list all ASGs in the account
data "aws_autoscaling_groups" "all" {}

# Step 2: Filter for ASGs that belong to this cluster
locals {
  eks_asg_names = [
    for asg in data.aws_autoscaling_groups.all.names :
    asg
    if can(regex(var.cluster_name, asg))
  ]

  asg_tags = {
    "auto-delete" = "no"
    "Environment" = "Production"
    "Owner"       = "MeowMart"
    "Name"        = "meowmart-nodes"
  }
}

# Step 3: Tag each ASG with your desired key/values
resource "aws_autoscaling_group_tag" "meowmart_nodes" {
  for_each = {
    for combo in flatten([
      for asg_name in local.eks_asg_names : [
        for key, value in local.asg_tags : {
          asg_name = asg_name
          key      = key
          value    = value
        }
      ]
    ]) : "${combo.asg_name}-${combo.key}" => combo
  }

  autoscaling_group_name = each.value.asg_name

  tag {
    key                 = each.value.key
    value               = each.value.value
    propagate_at_launch = true
  }

  depends_on = [module.eks]
}
