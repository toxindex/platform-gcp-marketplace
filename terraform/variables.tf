variable "project_id" {
  type = string
}

variable "zone" {
  type        = string
  description = "A zone that offers NVIDIA L4 GPUs when gpu_pool is true."
}

variable "cluster_name" {
  type    = string
  default = "toxindex"
}

variable "namespace" {
  type    = string
  default = "toxindex"
}

variable "general_min_nodes" {
  type    = number
  default = 1
}

variable "general_max_nodes" {
  type    = number
  default = 6
}

variable "gpu_pool" {
  type        = bool
  description = "Create the GPU node pool. Needed only if your license includes GPU tools."
}

variable "general_machine_type" {
  type    = string
  default = "e2-highmem-8"
}

variable "gpu_machine_type" {
  type    = string
  default = "g2-standard-12"
}

variable "gpu_type" {
  type    = string
  default = "nvidia-l4"
}
