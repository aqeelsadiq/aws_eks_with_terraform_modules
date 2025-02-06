variable "aws_region" {}
variable "resource_name" {}
variable "vpc_cidr" {}
variable "pub_subnet" {
  type = list(map(string))
}
variable "pri_subnet" {
  type = list(map(string))
}

variable "name" {}
variable "eks_name" {}

variable "cert_manager_hosted_zone_id" {}
variable "external_dns_hosted_zone_id" {}