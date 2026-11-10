# Test fixture: the license secret is created in the same configuration as the
# module, so its ARN is unknown at plan time. This is how most callers wire it.

variable "container_image" {
  type = string
}

resource "aws_secretsmanager_secret" "license" {
  name = "novelty-test/license-key"
}

module "novelty" {
  source = "../../../"

  project_name           = "novelty-inline-secret"
  container_image        = var.container_image
  license_key_secret_arn = aws_secretsmanager_secret.license.arn
}
