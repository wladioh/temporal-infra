terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"

  # set {
  #   name  = "controller.replicaCount"
  #   value = "2"
  # }
  # set {
  #   name  = "rbac.create"
  #   value = false
  # }
  # set {
  #   name  = "prometheus.create"
  #   value = true
  # }
  # set {
  #   name  = "controller.metrics.enabled"
  #   value = true
  # }
  # set {
  #   name  = "controller.podAnnotations.\"prometheus\\.io/scrape\""
  #   value = true
  # }
  # set {
  #   name  = "controller.podAnnotations.\"prometheus\\.io/port\""
  #   value = 10254
  # }
  # set {
  #   name  = "controller.podAnnotations.\"prometheus\\.io/port\""
  #   value = 10254
  # }
  # set {
  #   name  = "controller.podAnnotations.\"linkerd\\.io/inject\""
  #   value = "ingress"
  # }

  # set {
  #   name  = "controller.config.enable-opentracing"
  #   value = "true"
  # }

  # set {
  #   name  = "controller.config.zipkin-collector-host"
  #   value = "collector.linkerd-jaeger"
  # }
}
