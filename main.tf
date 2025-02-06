module "vpc" {
  source        = "./modules/vpc"
  vpc_cidr      = var.vpc_cidr
  aws_region    = var.aws_region
  pub_subnet    = var.pub_subnet
  resource_name = var.resource_name
  pri_subnet    = var.pri_subnet

}

module "iam" {
  source                      = "./modules/iam"
  name                        = var.name
  cert_manager_hosted_zone_id = var.cert_manager_hosted_zone_id
  aws_region                  = var.aws_region
  eks_oidc_provider_arn       = module.eks.oidc_provider_id
  external_dns_hosted_zone_id = var.external_dns_hosted_zone_id
}

module "eks" {
  source           = "./modules/eks"
  eks_name         = var.eks_name
  cluster_role_arn = module.iam.eks_cluster_role_arn
  subnet_ids       = module.vpc.pub_subnet
  eks_node_role    = module.iam.aws_iam_role
  vpc_id           = module.vpc.vpc_id
}

