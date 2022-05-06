terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}

data "local_file" "task_file" {
  filename = var.task_file
}

data "template_file" "deploy" {
  for_each = fileset("${path.module}/deploy", "**/*.yaml")
  template = file("${path.module}/${each.value}")
  vars = {
    TARGET_HOST       = "${var.target_host}"
    LOCUST_IMAGE      = "${var.locust_image}"
    TASK_FILE_CONTENT = "${data.local_file.task_file.content}"
    WORKER_REPLICAS   = var.woker_replicas
  }
}

resource "kubectl_manifest" "deploy" {
  for_each  = fileset("${path.module}/deploy", "**/*.yaml")
  yaml_body = data.template_file.deploy[each.value].rendered
}

