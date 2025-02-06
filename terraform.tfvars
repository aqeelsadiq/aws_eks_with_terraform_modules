aws_region    = ""
resource_name = ""
vpc_cidr      = "10.0.0.0/16"
pub_subnet = [
  {
    name              = "Public-Subnet-1"
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-west-1a"
  },
  {
    name              = "Public-Subnet-2"
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-west-1c"
  }
]

pri_subnet = [
  {
    name              = "Private-Subnet-1"
    cidr_block        = "10.0.3.0/24"
    availability_zone = "us-west-1a"
  },
  {
    name              = "Private-Subnet-2"
    cidr_block        = "10.0.4.0/24"
    availability_zone = "us-west-1c"
  }
]

eks_name = ""
name     = ""

cert_manager_hosted_zone_id = ""
external_dns_hosted_zone_id = ""