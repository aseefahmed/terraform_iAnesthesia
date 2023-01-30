resource "aws_elasticsearch_domain" "anesthesia" {
  domain_name           = "anesthesia"
  elasticsearch_version = "7.10"
  //username=admin
  //password=Anesthesia123@
  cluster_config {
    instance_type = "r4.large.elasticsearch"
  }

#   vpc_options {
#     subnet_ids = [
#       module.vpc.public_subnets[*].id,
#     ]

#   }


  advanced_security_options {
    enabled = false
  }

#   master_user_options {
#     master_user_name = "admin"
#     master_user_password = "Anesthesia123@"
#   }
  
  ebs_options {
    volume_size = "10"
    ebs_enabled = true
  }
  tags = {
    Domain = "TestDomain"
  }
}