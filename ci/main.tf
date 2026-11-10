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

# ARN of a pre-existing Secrets Manager secret holding the license key.
# The CI role cannot manage secrets, and the key never passes through Terraform.
variable "license_key_secret_arn" {
  type = string
}

variable "license_server_uri" {
  type = string
}

module "novelty" {
  source = "../"

  project_name           = "thatdot-terraform-ci-novelty"
  container_image        = var.container_image
  license_key_secret_arn = var.license_key_secret_arn
  license_server_uri     = var.license_server_uri
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
