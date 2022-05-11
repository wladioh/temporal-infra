terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

resource "helm_release" "kubernetes-dashboard" {
  name             = "kubernetes-dashboard"
  namespace        = "observability"
  create_namespace = true
  repository       = "https://kubernetes.github.io/dashboard/"
  chart            = "kubernetes-dashboard"
}

data "local_file" "dashboard_user" {
  filename = "${path.module}/dashboard_user.yaml"
}

resource "kubectl_manifest" "dashboard-user" {
  yaml_body = data.local_file.dashboard_user.content
  depends_on = [
    helm_release.kubernetes-dashboard
  ]
}
