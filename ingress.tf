resource "kubernetes_ingress" "ingress_service" {
  count = length(var.ingress_name)
  metadata {
    name = var.ingress_name[count.index].name
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/tags" = "ResourceType=Ingress"
    }
  }
  
  spec {
    backend {
      service_name = var.ingress_name[count.index].service
      service_port = var.ingress_name[count.index].port
    }
    
    rule {
      http {
        path {
          backend {
            service_name = "gateway"
            service_port = var.ingress_name[count.index].port
          }
          path = var.ingress_name[count.index].path
        }
      }
    }
  }
}

resource "aws_lb_listener" "front_end" {
  count = length(var.ingress_alb)
  load_balancer_arn = var.ingress_alb[0].alb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.ingress_alb[0].tg_arn
  }
}