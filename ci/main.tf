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

variable "license_key_secret_arn" {
  type = string
}

# JVM options for the CI environment, supplied from a repository secret
variable "java_opts" {
  type      = string
  sensitive = true
}

module "novelty" {
  source = "../"

  project_name           = "thatdot-terraform-ci-novelty"
  container_image        = var.container_image
  license_key_secret_arn = var.license_key_secret_arn
  java_opts              = var.java_opts
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

output "ecs_task_definition_arn" {
  value = module.novelty.ecs_task_definition_arn
}
