locals {
  region = "us-west-2"
  eks_cluster_name = "josh-test"
}

provider "aws" {
  region = local.region
}

module "eks_clickhouse" {
  source  = "github.com/Altinity/terraform-aws-eks-clickhouse?ref=new-keeper"

  install_clickhouse_operator = true
  install_clickhouse_cluster  = true

  clickhouse_cluster_enable_loadbalancer = true

  eks_cluster_name = local.eks_cluster_name
  eks_region       = local.region
  eks_cidr         = "10.0.0.0/16"

  eks_availability_zones = [
    "${local.region}a",
    "${local.region}b",
    "${local.region}c",
  ]
  eks_private_cidr = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24",
  ]
  eks_public_cidr = [
    "10.0.121.0/24",
    "10.0.122.0/24",
    "10.0.123.0/24",
  ]

  eks_node_pools = [
   {
      name          = "clickhouse"
      instance_type = "m6i.large"
      desired_size  = 0
      max_size      = 10
      min_size      = 0
      zones         = ["${local.region}a", "${local.region}b", "${local.region}c"]
    },
    {
      name          = "system"
      instance_type = "t3.large"
      desired_size  = 1
      max_size      = 10
      min_size      = 0
      zones         = ["${local.region}a"]
    }
  ]

  eks_tags = {
    CreatedBy = "joshlee-terraform"
  }
}

output "eks_configure_kubectl" {
  value = module.eks_clickhouse.eks_configure_kubectl
}
