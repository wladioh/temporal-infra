
terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

# data "kubectl_filename_list" "manifests" {
#   pattern = "${path.module}/*.yaml"
# }

# resource "kubectl_manifest" "apply" {
#   count     = 3
#   yaml_body = file(element(data.kubectl_filename_list.manifests.matches, count.index))
# }

data "kubectl_filename_list" "manifests" {
  pattern = "${path.module}/*.yaml"
}

resource "kubectl_manifest" "apply" {
  count     = length(data.kubectl_filename_list.manifests.matches)
  yaml_body = file(element(data.kubectl_filename_list.manifests.matches, count.index))
}
