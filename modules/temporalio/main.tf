terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

data "kubectl_file_documents" "temporalio" {
  content = file("${path.module}/temporal.yaml")
}
resource "kubectl_manifest" "temporalio" {
  for_each  = data.kubectl_file_documents.temporalio.manifests
  yaml_body = each.value
}

