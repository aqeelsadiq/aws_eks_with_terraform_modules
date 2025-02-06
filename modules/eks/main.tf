
# eks cluster
resource "aws_eks_cluster" "eks_cluster" {
  name = var.eks_name

  role_arn = var.cluster_role_arn
  version = "1.31"
  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [aws_security_group.eks_node_sg.id] 

  }
  tags = {
    Name = "${var.eks_name}-eks-cluster"
  }
}


#node group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "my-node-group"
  node_role_arn   = var.eks_node_role
  subnet_ids      = var.subnet_ids
  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  ami_type = "AL2_x86_64"
  capacity_type = "ON_DEMAND"
  
  disk_size = 20
  force_update_version = false
  instance_types = ["t3.small"]
  version = "1.31"
  remote_access {
    ec2_ssh_key               = "my-key-pair"  
    source_security_group_ids = [aws_security_group.eks_node_sg.id]
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_security_group.eks_node_sg
  ]
}



#security group
resource "aws_security_group" "eks_node_sg" {
  name_prefix = "eks-node-sg"
  vpc_id      = var.vpc_id  


    dynamic "ingress" {
      for_each = toset ([80, 443, 10250, 6783, 6784, 22])
      iterator = port
      content {
        from_port   = port.value
        to_port     = port.value
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  tags = {
    Name = "eks-node-sg"
  }
}