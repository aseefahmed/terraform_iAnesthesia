variable "region" {
  default     = "eu-west-3"
  description = "AWS region"
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "anesthesia-eks-${random_string.suffix.result}"
  rds_identifier = "anesthesia-rds-${random_string.suffix.result}"
  vpc_name = "anesthesia-vpc-${random_string.suffix.result}"
  rds_params_grp = "anesthesia-params-group-${random_string.suffix.result}"
  rds_sg = "anesthesia-sg-${random_string.suffix.result}"
  efs_sg = "anesthesia-efs-sg-${random_string.suffix.result}"
  rds_subnet_group = "anesthesia-subnet-group-${random_string.suffix.result}"
  msk_cluster = "anesthesia-msk-${random_string.suffix.result}"
  os_cluster_name      = "opensearch"
  os_cluster_domain    = "example.com"
  saml_entity_id    = "https://sts.windows.net/XXX-XXX-XXX-XXX-XXX/"
  saml_metadata_url = "https://login.microsoftonline.com/XXX-XXX-XXX-XXX-XXX/federationmetadata/2007-06/federationmetadata.xml?appid=YYY-YYY-YYY-YYY-YYY"

}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = local.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
