variable "eks_cluster_version" {
    description = "Enter EKS cluster version"
    type = string
    default = "1.20"
}

variable "eks_worker_nodes_root_volume_type" {
    description = "Enter root volume type for the work nodes"
    type = string
    default = "gp2"
}

variable "vpc_name" {
    description = "Enter VPC name"
    type = string
    default = "vpc_paris"
}

variable "vpc_cidr" {
    description = "Enter VPC CIDR"
    type = string
    default = "10.0.0.0/16"
}

variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
  default = "anesthesia1234"
}

variable "ingress_name" {
    description = "Name of K8S ingress"
    type = list(object({
        name = string
        service = string
        port = string
        path = string
    }))
}

variable "ingress_alb" {
    description = "Name of K8S ingress ALB"
    type = list(object({
        alb_arn = string
        tg_arn = string
    }))
}

variable "certificate_arn" {
    description = "Enter ACM Certifiacte ARN for Ingress Resource"
    type = string
}