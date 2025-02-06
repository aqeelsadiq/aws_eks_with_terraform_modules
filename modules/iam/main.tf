
# eks cluster role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.name}-eks-cluster-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}



# Retrieve AWS account ID
data "aws_caller_identity" "current" {}

# External DNS IAM Role
resource "aws_iam_role" "external_dns" {
  name               = "external-dnsa"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role_policy.json
}

# External DNS IAM Policy
resource "aws_iam_policy" "external_dns_policy" {
  name        = "ExternalDNSPolicya"
  description = "IAM policy for External DNS to manage Route 53 DNS records"
  policy      = data.aws_iam_policy_document.external_dns_policy.json
}

# Attach the External DNS policy to the role
resource "aws_iam_role_policy_attachment" "external_dns_attach_policy" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns_policy.arn
}

# External DNS Assume Role Policy
data "aws_iam_policy_document" "external_dns_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.aws_region}.amazonaws.com/id/${var.eks_oidc_provider_arn}"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "oidc.eks.${var.aws_region}.amazonaws.com/id/${var.eks_oidc_provider_arn}:sub"
      values   = ["system:serviceaccount:kube-system:external-dns"]
    }
  }
}
# Attach External DNS Policy to the EKS Node Role
resource "aws_iam_role_policy_attachment" "external_dns_attach_to_node_role" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = aws_iam_policy.external_dns_policy.arn
}


# External DNS Policy Document
data "aws_iam_policy_document" "external_dns_policy" {
  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:GetChange",
      "route53:ChangeResourceRecordSets",
      "route53:ListHostedZonesByName"
    ]
    resources = ["arn:aws:route53:::hostedzone/${var.external_dns_hosted_zone_id}"]
  }
}



#Create IAM Policy for cert-manager (Managed Policy)
data "aws_iam_policy_document" "cert_manager_policy" {
  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:GetChange",
      "route53:ChangeResourceRecordSets",
      "route53:ListHostedZonesByName"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/${var.cert_manager_hosted_zone_id}",
      "arn:aws:route53:::change/*"
    ]
  }
}
resource "aws_iam_policy" "cert_manager_policy" {
  name        = "cert-manager-policy"
  description = "Policy to allow cert-manager access to Route 53 for DNS validation"
  policy      = data.aws_iam_policy_document.cert_manager_policy.json
}
#Attach the Managed cert-manager Policy to the Role
resource "aws_iam_role_policy_attachment" "cert_manager_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = aws_iam_policy.cert_manager_policy.arn
}


# eks node role
resource "aws_iam_role" "eks_node_role" {
  name = "${var.name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.name}-eks-node-role"
  }
}


resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "ec2_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}
resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
