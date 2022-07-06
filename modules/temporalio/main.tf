terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}
data "local_file" "temporalio" {
  filename = "${path.module}/temporal.yaml"
}

data "kubectl_file_documents" "temporalio" {
  content = data.local_file.temporalio.content
}
resource "kubectl_manifest" "temporalio" {
  # count     = length(split("\n---\n", data.local_file.temporalio.content))
  count     = 25
  yaml_body = element(data.kubectl_file_documents.temporalio.documents, count.index)
}

# resource "kubectl_manifest" "temporalio" {
#   for_each   = toset(split("\n---\n", data.local_file.temporalio.content))
#   yaml_body  = each.value
#   depends_on = [data.local_file.temporalio]
# }
