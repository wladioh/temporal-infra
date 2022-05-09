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
    key                  = "loadtest.terraform.tfstate"
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

locals {
  cluster_name        = "load-test-cluster"
  resource_group_name = "loadtest"
}
resource "azurerm_resource_group" "loadtest" {
  name     = local.resource_group_name
  location = var.location
}
module "aks" {
  source              = "../../modules/aks"
  acr_id              = data.terraform_remote_state.base_infra.outputs.acr_id
  cluster_name        = local.cluster_name
  resource_group_name = azurerm_resource_group.loadtest.name
  # public_ip_id      = data.terraform_remote_state.base_infra.outputs.public_ip_id
  depends_on = [
    azurerm_resource_group.loadtest
  ]
}

module "dashboard" {
  source = "../../modules/dashboard"
  depends_on = [
    module.aks
  ]
}

resource "kubernetes_config_map" "locust_tasks" {
  metadata {
    name = "locust-tasks"
  }
  data = {
    "main.py" = "${file(var.task_file)}"
  }
  depends_on = [
    module.aks
  ]
}

resource "helm_release" "locust" {
  name       = "locust"
  repository = "https://charts.deliveryhero.io/"
  chart      = "locust"
  set {
    name  = "loadtest.name"
    value = "loadtest"
  }
  set {
    name  = "loadtest.locust_locustfile_configmap"
    value = "locust-tasks"
  }
  set {
    name  = "loadtest.locust_locustfile"
    value = "main.py"
  }
  set {
    name  = "worker.hpa.enabled"
    value = true
  }
  depends_on = [
    kubernetes_config_map.locust_tasks
  ]
}
