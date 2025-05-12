variable "project_id" {
    description = "project id"
    type = string
    default = "caeli-458416"
}

variable "vm_core_name" {
    description = "VM name"
    type = string
    default = "engine"
}

variable "vm_core_type" {
    description = "tipo de maquina"
    type = string
    default = "e2-micro"
}

variable "region" {
    description = "GCP region"
    type = string
    default = "us-central1"
}

variable "zone" {
    description = "GCP zone"
    type = string
    default = "us-central1-a"
}

