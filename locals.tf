# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------
# This file centralizes computed values and fallback logic for VPC/subnet
# configuration. When users don't provide vpc_id or subnet_ids, the module
# automatically discovers and uses the default VPC and its subnets.
# -----------------------------------------------------------------------------

locals {
  # Determine whether to use custom or default VPC
  use_default_vpc = var.vpc_id == null

  # Resolve VPC ID - use provided value or fall back to default VPC
  vpc_id = local.use_default_vpc ? data.aws_vpc.default[0].id : var.vpc_id

  # Resolve subnet IDs - use provided value or fall back to default VPC subnets
  subnet_ids = var.subnet_ids != null ? var.subnet_ids : data.aws_subnets.default[0].ids

  # Computed resource names with fallbacks
  cluster_name = var.cluster_name != null ? var.cluster_name : "${var.project_name}-cluster"
  service_name = var.service_name != null ? var.service_name : "${var.project_name}-service"

  # Common tags applied to all resources
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Module      = "terraform-aws-novelty"
    },
    var.tags
  )

  # -----------------------------------------------------------------------------
  # JVM Options
  # -----------------------------------------------------------------------------

  # Lets the JVM read configuration from CONFIG_FORCE_* environment variables
  # (Typesafe Config). The container image does not enable this itself, and it
  # is what allows the license key to arrive as an ECS-injected secret.
  config_env_override_java_opt = "-Dconfig.override_with_env_vars=true"

  # Full JDK_JAVA_OPTIONS: user-provided options first, then the module's
  java_opts_value = join(" ", compact([
    var.java_opts,
    local.config_env_override_java_opt,
  ]))

  # -----------------------------------------------------------------------------
  # Container Environment Variables
  # -----------------------------------------------------------------------------

  container_environment = concat(
    [
      {
        name  = "JDK_JAVA_OPTIONS"
        value = local.java_opts_value
      }
    ],
    var.container_environment
  )

  # -----------------------------------------------------------------------------
  # Container Secrets
  # -----------------------------------------------------------------------------

  # License key (read by Novelty as the thatdot.novelty.license-key setting),
  # followed by any user-provided secrets
  container_secrets = concat(
    [
      {
        name      = "CONFIG_FORCE_thatdot_novelty_license__key"
        valueFrom = var.license_key_secret_arn
      }
    ],
    var.container_secrets
  )

  # Every environment variable and secret name in the container. ECS rejects
  # duplicates, and a caller entry that repeats a module-set name (such as
  # JDK_JAVA_OPTIONS) would override it.
  container_variable_names = concat(
    [for env in local.container_environment : env.name],
    [for secret in local.container_secrets : secret.name]
  )

  # ARNs the execution role must be able to read. A Secrets Manager valueFrom
  # may end in ':json-key:version-stage:version-id'; IAM needs the bare secret ARN.
  container_secret_arns = distinct([
    for secret in local.container_secrets :
    try(regex("^arn:[^:]*:secretsmanager:[^:]*:[^:]*:secret:[^:]+", secret.valueFrom), secret.valueFrom)
  ])

  # Get current AWS region from provider for log configuration
  # This uses a data source since we can't use var.aws_region anymore (provider config is in root module)
  aws_region = data.aws_region.current.name
}

# -----------------------------------------------------------------------------
# Data Sources for Default VPC Discovery
# -----------------------------------------------------------------------------

# Get current AWS region
data "aws_region" "current" {}

# Get default VPC (only if vpc_id is not provided)
data "aws_vpc" "default" {
  count   = local.use_default_vpc ? 1 : 0
  default = true
}

# Get subnets in the default VPC (only if subnet_ids not provided)
data "aws_subnets" "default" {
  count = var.subnet_ids == null ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local.use_default_vpc ? data.aws_vpc.default[0].id : var.vpc_id]
  }
}
