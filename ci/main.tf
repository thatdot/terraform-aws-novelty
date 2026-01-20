terraform {
  required_version = ">= 1.7.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "us-west-2"
}

variable "container_image" {
  type = string
}

variable "license_key" {
  type      = string
  sensitive = true
}

variable "license_server_uri" {
  type = string
}

module "novelty" {
  source = "../"

  project_name       = "thatdot-terraform-ci-novelty"
  container_image    = var.container_image
  license_key        = var.license_key
  license_server_uri = var.license_server_uri
}

output "alb_url" {
  value = module.novelty.alb_url
}

output "ecs_cluster_name" {
  value = module.novelty.ecs_cluster_name
}

output "ecs_service_name" {
  value = module.novelty.ecs_service_name
}
