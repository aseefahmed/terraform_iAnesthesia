module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = var.eks_cluster_version
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = var.eks_worker_nodes_root_volume_type
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.large"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 2
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.large"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]
}

resource "null_resource" "run_config_script" {
  depends_on = [
    module.eks
  ]

  provisioner "local-exec" {
    command = "./scripts/configure_cluster.sh"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
