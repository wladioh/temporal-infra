variable "location" {
  default = "Brazil South"
}
variable "target_host" {
  default = "https://localhost:8080"
}

variable "locust_image" {
  default = "locust-load-test:v1"
}

variable "task_file" {
}
