certificate_arn = "arn:aws:acm:eu-west-3:502802710160:certificate/a5a814b3-c8ca-41ad-8705-431385451c7a"
ingress_name = [
    # {
    #     name = "ingress-1"
    #     path = "/ingress1"
    #     service = "gateway"
    #     port = 8081
    # },
    # {
    #     name = "ingress-2"
    #     path = "/ingress2"
    #     service = "gateway"
    #     port = 8082
    # },
    # {
    #     name = "ingress-3"
    #     path = "/ingress3"
    #     service = "gateway"
    #     port = 8083
    # }
]

ingress_alb =[
    {
        alb_arn = "arn:aws:elasticloadbalancing:eu-west-3:502802710160:loadbalancer/app/k8s-default-gatewayi-d03ac23c62/b8d4dc5bb18622e7"
        tg_arn = "arn:aws:elasticloadbalancing:eu-west-3:502802710160:targetgroup/k8s-default-gateway-20bb242c6d/34ee825b907961df"
    }
]