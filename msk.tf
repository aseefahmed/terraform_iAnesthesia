resource "aws_s3_bucket" "msk_logs" {
    bucket_prefix = "msk-logs-"
    force_destroy = true
}

resource "aws_secretsmanager_secret" "anesthesia" {
  name_prefix = "AmazonMSK_"
  kms_key_id = "446ce1e6-4752-44e9-a4ab-3d6b84dec3c9"
}

resource "aws_secretsmanager_secret_version" "sversion" {
  secret_id = aws_secretsmanager_secret.anesthesia.id
  secret_string = <<EOF
   {
    "username": "adminaccount",
    "password": "pass123"
   }
EOF
}

module "msk_kafka_cluster" {
  source = "clowdhaus/msk-kafka-cluster/aws"

  name                   = local.msk_cluster
  kafka_version          = "2.8.0"
  number_of_broker_nodes = 3
  enhanced_monitoring    = "PER_TOPIC_PER_PARTITION"

  broker_node_client_subnets  = module.vpc.public_subnets
  broker_node_ebs_volume_size = 20
  broker_node_instance_type   = "kafka.t3.small"
  broker_node_security_groups = [aws_security_group.msk.id]

  encryption_in_transit_client_broker = "PLAINTEXT"
  encryption_in_transit_in_cluster    = true

  configuration_name        = "msk-configuration"
  configuration_description = "MSK configuration"
  configuration_server_properties = {
    "auto.create.topics.enable" = true
    "delete.topic.enable"       = true
  }

  jmx_exporter_enabled    = true
  node_exporter_enabled   = true
  cloudwatch_logs_enabled = true
  s3_logs_enabled         = true
  s3_logs_bucket          = aws_s3_bucket.msk_logs.bucket
  s3_logs_prefix          = local.msk_cluster

  scaling_max_capacity = 512
  scaling_target_value = 80

  client_authentication_sasl_scram         = false
  create_scram_secret_association          = false
  scram_secret_association_secret_arn_list = [
    aws_secretsmanager_secret.anesthesia.arn
  ]

  # AWS Glue Registry
#   schema_registries = {
#     team_a = {
#       name        = "team_a"
#       description = "Schema registry for Team A"
#     }
#     team_b = {
#       name        = "team_b"
#       description = "Schema registry for Team B"
#     }
#   }

  # AWS Glue Schemas
#   schemas = {
#     team_a_tweets = {
#       schema_registry_name = "team_a"
#       schema_name          = "tweets"
#       description          = "Schema that contains all the tweets"
#       compatibility        = "FORWARD"
#       schema_definition    = "{\"type\": \"record\", \"name\": \"r1\", \"fields\": [ {\"name\": \"f1\", \"type\": \"int\"}, {\"name\": \"f2\", \"type\": \"string\"} ]}"
#       tags                 = { Team = "Team A" }
#     }
#     team_b_records = {
#       schema_registry_name = "team_b"
#       schema_name          = "records"
#       description          = "Schema that contains all the records"
#       compatibility        = "FORWARD"
#       team_b_records = {
#       schema_registry_name = "team_b"
#       schema_name          = "records"
#       description          = "Schema that contains all the records"
#       compatibility        = "FORWARD"
#       schema_definition = jsonencode({
#         type = "record"
#         name = "r1"
#         fields = [{
#           name = "f1"
#           type = "int"
#           }, {
#           name = "f2"
#           type = "string"
#           }, {
#           name = "f3"
#           type = "boolean"
#         }]
#       })
#       tags = { Team = "Team B" }
#     }
#   }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}