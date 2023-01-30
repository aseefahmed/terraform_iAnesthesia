resource "aws_iam_role" "lambda_role" {
name   = "Lambda_Role_For_EFS"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
 
 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "*",
     "Resource": "*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_lambda_function" "terraform_lambda_func" {
    filename                       = "lambda/func.zip"
    function_name                  = "efs-cleanup-func"
    role                           = aws_iam_role.lambda_role.arn
    handler                        = "lambda_function.lambda_handler"
    runtime                        = "python3.9"
    timeout                        = 900

    vpc_config {
    subnet_ids = module.vpc.public_subnets
    security_group_ids = [aws_security_group.efs.id]
    }

    file_system_config {
        arn = aws_efs_access_point.access.arn
        local_mount_path = "/mnt/lambda-efs"
    }

    depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  create_bus = false

  rules = {
    crons = {
      description         = "Trigger for a Lambda"
      schedule_expression = "rate(5 minutes)"
    }
  }

  targets = {
    crons = [
      {
        name  = "lambda-loves-cron"
        arn   = aws_lambda_function.terraform_lambda_func.arn
      }
    ]
  }
}