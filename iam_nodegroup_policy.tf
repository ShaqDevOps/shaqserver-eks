###########################################################
# Attach Load Balancer permissions to Node Group Role
###########################################################

# Dynamically fetch the Node Group IAM Role created by the EKS module
data "aws_iam_role" "node_group" {
  name       = module.eks.eks_managed_node_groups["default"].iam_role_name
  depends_on = [module.eks]
}

# Core node policies
resource "aws_iam_role_policy_attachment" "node_group_worker" {
  role       = data.aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  depends_on = [module.eks]
}

resource "aws_iam_role_policy_attachment" "node_group_cni" {
  role       = data.aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  depends_on = [module.eks]
}

resource "aws_iam_role_policy_attachment" "node_group_ecr" {
  role       = data.aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  depends_on = [module.eks]
}

resource "aws_iam_role_policy_attachment" "node_group_elbv2" {
  role       = data.aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  depends_on = [module.eks]
}
