# EKS Cluster
resource "aws_eks_cluster" "cluster" {
  name     = "${var.project}-cluster"
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    # security_group_ids      = [aws_security_group.eks_cluster.id, aws_security_group.eks_nodes.id]
    subnet_ids              = [aws_subnet.public_subnet.id , aws_subnet.private_subnet.id]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  #   tags = merge(
  #     var.tags
  #   )

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}


# EKS Cluster IAM Role. At least-priviledge permission for communicate with cluster
resource "aws_iam_role" "cluster" {
  name = "${var.project}-Cluster-Role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
# attach the permissions to role
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
  depends_on = [ aws_iam_role.cluster ]
}


# EKS Cluster Security Group, base on vpc 
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.cluster_vpc.id

  tags = {
    Name = "${var.project}-cluster-sg"
  }
}
# sg-rule: worker can access api control-plane server(s)
resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress"
}
# sg-rule: cluster-api server access to worker apis
resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "egress"
}