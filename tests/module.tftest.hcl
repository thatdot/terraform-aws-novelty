# Plan-only tests against a mocked AWS provider: no account or credentials needed.
#   terraform init -backend=false && terraform test

mock_provider "aws" {
  mock_data "aws_region" {
    defaults = {
      name = "us-west-2"
    }
  }

  mock_data "aws_vpc" {
    defaults = {
      id = "vpc-12345678"
    }
  }

  mock_data "aws_subnets" {
    defaults = {
      ids = ["subnet-11111111", "subnet-22222222"]
    }
  }
}

variables {
  project_name    = "novelty-test"
  container_image = "123456789012.dkr.ecr.us-west-2.amazonaws.com/thatdot/novelty:1.2.0"
}

run "defaults" {
  command = plan

  variables {
    license_key_secret_arn = "arn:aws:secretsmanager:us-west-2:123456789012:secret:novelty/license-AbCdEf:key::"
  }

  assert {
    condition     = aws_lb_target_group.main.health_check[0].path == "/api/v2/system/liveness"
    error_message = "ALB health check should default to the v2 liveness endpoint."
  }

  assert {
    condition     = strcontains(jsondecode(aws_ecs_task_definition.main.container_definitions)[0].healthCheck.command[1], "/api/v2/system/liveness")
    error_message = "Container health check should default to the v2 liveness endpoint."
  }

  assert {
    condition = jsondecode(aws_ecs_task_definition.main.container_definitions)[0].secrets == [
      {
        name      = "CONFIG_FORCE_thatdot_novelty_license__key"
        valueFrom = "arn:aws:secretsmanager:us-west-2:123456789012:secret:novelty/license-AbCdEf:key::"
      }
    ]
    error_message = "License key must be injected as the CONFIG_FORCE_thatdot_novelty_license__key container secret."
  }

  assert {
    condition = jsondecode(aws_ecs_task_definition.main.container_definitions)[0].environment == [
      {
        name  = "JDK_JAVA_OPTIONS"
        value = "-Dconfig.override_with_env_vars=true -Dthatdot.novelty.license-server-uri=https://license.thatdot.com"
      }
    ]
    error_message = "JDK_JAVA_OPTIONS must enable CONFIG_FORCE_* overrides and must not carry the license key."
  }

  assert {
    condition     = !strcontains(aws_ecs_task_definition.main.container_definitions, "license-key")
    error_message = "The license key setting must not appear in the task definition's plain-text configuration."
  }

  assert {
    condition     = jsondecode(aws_iam_role_policy.ecs_task_execution_secrets.policy).Statement[0].Resource == ["arn:aws:secretsmanager:us-west-2:123456789012:secret:novelty/license-AbCdEf"]
    error_message = "Execution role must be granted the bare secret ARN (without the json-key suffix)."
  }
}

run "license_secret_created_in_same_configuration" {
  command = plan

  module {
    source = "./tests/fixtures/inline_secret"
  }
}
