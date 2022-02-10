terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}


data "local_file" "temporalio" {
  filename = "${path.module}/temporalio.yaml"
}

resource "kubectl_manifest" "default-namespace" {
  yaml_body = data.local_file.temporalio.content
}

# resource "helm_release" "temporalio" {
#   name      = "temporalio"
#   namespace = var.namespace
#   # NOTE: actual subpath after ${path.module} depends on module structure
#   chart            = "${path.module}/charts"
#   max_history      = 3
#   wait             = true
#   reset_values     = true
#   create_namespace = true

#   timeout = 900
#   values = [
#     "${file("${path.module}/charts/values.yaml")}"
#   ]
#   set {
#     name  = "server.replicaCount"
#     value = "1"
#   }
#   set {
#     name  = "cassandra.config.cluster_size"
#     value = "1"
#   }
#   set {
#     name  = "prometheus.enabled"
#     value = "false"
#   }
#   set {
#     name  = "grafana.enabled"
#     value = "false"
#   }
#   set {
#     name  = "elasticsearch.enabled"
#     value = "false"
#   }
# }


# helm install \
#     --set server.replicaCount=1 \
#     --set cassandra.config.cluster_size=1 \
#     --set prometheus.enabled=false \
#     --set grafana.enabled=false \
#     --set elasticsearch.enabled=false \
#     temporalio . --timeout 15m

# # helm upgrade --set server.replicaCount=1r --set cassandra.config.cluster_size=1 temporalio .
# sh
# -c
# until cqlsh localhost 9042 -e "SELECT keyspace_name FROM system_schema.keyspaces" | grep temporal$;

# kubectl exec --stdin --tty temporalio-cassandra-0 -- /bin/sh
