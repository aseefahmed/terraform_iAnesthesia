resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = local.rds_subnet_group
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "EKS"
  }
}

resource "aws_db_parameter_group" "rds_params" {
  name   = local.rds_params_grp
  family = "mysql8.0"
}

resource "aws_db_instance" "rds" {
  identifier             = local.rds_identifier
  instance_class         = "db.t4g.medium"
  allocated_storage      = 5
  engine                 = "mysql"
  username               = "anesthesia"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.rds_params.name
  publicly_accessible    = true
  skip_final_snapshot    = true
  backup_retention_period = 7
  apply_immediately = true
}