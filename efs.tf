resource "aws_efs_file_system" "efs" {
   creation_token = "anesthesia"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
   tags = {
        Name = "EFS Anesthesia"
   }
 }

resource "aws_efs_mount_target" "efs-mt" {
   count = length(module.vpc.public_subnets)
   file_system_id  = aws_efs_file_system.efs.id
   subnet_id = module.vpc.public_subnets[count.index]
   security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "access" {
  file_system_id = aws_efs_file_system.efs.id

  root_directory {
   path = "/"
   creation_info {
      owner_gid = 0
      owner_uid = 0
      permissions = "777"
   }
  }

  posix_user {
   gid = 0
   uid = 0
  }

  tags = {
    "Name" = "LambdaEFSAccess"
  }
}