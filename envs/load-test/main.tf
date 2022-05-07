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
resource "azurerm_resource_group" "prod" {
  name     = local.resource_group_name
  location = var.location
}
module "aks" {
  source              = "../../modules/aks"
  acr_id              = data.terraform_remote_state.base_infra.outputs.acr_id
  cluster_name        = local.cluster_name
  resource_group_name = azurerm_resource_group.prod.name
  # public_ip_id      = data.terraform_remote_state.base_infra.outputs.public_ip_id
  depends_on = [
    azurerm_resource_group.prod
  ]
}
resource "null_resource" "build_image" {
  triggers = {
    registry_server = data.terraform_remote_state.base_infra.outputs.registry_server
    locust_image    = var.locust_image
  }
  provisioner "local-exec" {
    command = "/bin/bash build.sh ${self.triggers.registry_server} ${self.triggers.locust_image}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "/bin/bash destroy.sh ${self.triggers.registry_server} ${self.triggers.locust_image}"
  }
}

module "dashboard" {
  source = "../../modules/dashboard"
  depends_on = [
    module.aks
  ]
}

module "locust" {
  source       = "../../modules/locust"
  locust_image = "${data.terraform_remote_state.base_infra.outputs.registry_server}/${var.locust_image}"
  target_host  = var.target_host
  task_file    = abspath(var.task_file)
  depends_on = [
    module.dashboard
  ]
}

resource "null_resource" "connect_to_cluster" {
  provisioner "local-exec" {
    command = "/bin/bash connect.sh ${local.resource_group_name} ${local.cluster_name}"
  }
}
