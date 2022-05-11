terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  backend "azurerm" {
    key                  = "prod.terraform.tfstate"
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate12574"
    container_name       = "tfstate-temporal"
  }
  required_version = ">= 0.13"
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}


provider "kubectl" {
  host                   = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}


provider "helm" {
  kubernetes {
    host                   = module.aks.host
    client_certificate     = base64decode(module.aks.client_certificate)
    client_key             = base64decode(module.aks.client_key)
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  }
}
data "terraform_remote_state" "base_infra" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate12574"
    container_name       = "tfstate-temporal"
    key                  = "base.terraform.tfstate"
  }
}

resource "azurerm_resource_group" "prod" {
  name     = "temporal"
  location = var.location
}

module "aks" {
  source              = "../../modules/aks"
  acr_id              = data.terraform_remote_state.base_infra.outputs.acr_id
  cluster_name        = "temporal-cluster"
  resource_group_name = azurerm_resource_group.prod.name
  vm_size             = "Standard_A8_v2"
  # public_ip_id      = data.terraform_remote_state.base_infra.outputs.public_ip_id
  depends_on = [
    azurerm_resource_group.prod
  ]
}

module "ingress" {
  source = "../../modules/ingress"
  depends_on = [
    module.aks
  ]
}
module "temporalio" {
  source = "../../modules/temporalio"
  depends_on = [
    module.ingress
  ]
}
module "dashboard" {
  source = "../../modules/dashboard"
  depends_on = [
    module.temporalio
  ]
}

module "postgres" {
  source = "../../modules/postgres"
  depends_on = [
    module.dashboard
  ]
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  namespace        = "observability"
  create_namespace = true
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  values = [
    "${file("./prometheus.yaml")}"
  ]
  depends_on = [
    module.postgres
  ]
}

resource "helm_release" "jaeger" {
  name             = "jaeger"
  namespace        = "observability"
  create_namespace = true
  repository       = "https://jaegertracing.github.io/helm-charts"
  chart            = "jaeger"
  values = [
    "${file("./jaeger.yaml")}"
  ]
  depends_on = [
    module.postgres
  ]
}

resource "helm_release" "grafana" {
  name             = "grafana"
  namespace        = "observability"
  create_namespace = true
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  values = [
    "${file("./grafana.yaml")}"
  ]
  depends_on = [
    module.postgres
  ]
}
#kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

resource "helm_release" "opentelemetry_collector" {
  name             = "opentelemetry-collector"
  namespace        = "observability"
  create_namespace = true
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart            = "opentelemetry-collector"
  values = [
    "${file("./otpl-collector.yaml")}"
  ]
  depends_on = [
    helm_release.jaeger,
    helm_release.prometheus
  ]
}
