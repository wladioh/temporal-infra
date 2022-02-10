variable "agent_count" {
  default = 1
}

variable "vm_size" {
  default = "Standard_D2_v2"
  #default = "Standard_B2s"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "cluster"
}

variable "cluster_name" {
}

variable "resource_group_name" {
}

variable "acr_id" {

}

variable "public_ip_id" {
  default = ""
}

variable "location" {
  default = "Brazil South"
}
