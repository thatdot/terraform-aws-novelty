# Basic Example

Simplest deployment of Novelty on AWS ECS Fargate with minimal configuration.

## Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.5.0
- Default VPC in the target region
- Novelty Docker image pushed to your private ECR repository
- Novelty license key, stored in AWS Secrets Manager:

```bash
aws secretsmanager create-secret \
  --name novelty/license-key \
  --secret-string "$NOVELTY_LICENSE_KEY" \
  --query ARN --output text
```

The command prints the secret's ARN, which you pass as `license_key_secret_arn`. The license key itself never goes into Terraform variables, state, the ECS task definition, or the container logs.

## Usage

1. Create `terraform.tfvars`:

```hcl
container_image        = "YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/thatdot/novelty:1.2.0"
license_key_secret_arn = "arn:aws:secretsmanager:us-west-2:123456789012:secret:novelty/license-key-AbCdEf"
```

2. Deploy:

```bash
terraform init
terraform plan
terraform apply
```

After deployment, access Novelty at the URL shown in outputs:

```bash
terraform output url
```

## Cleanup

```bash
terraform destroy
```

## What Gets Created

- ECS Fargate cluster with Container Insights
- ECS service running 1 Novelty container (2 vCPU, 4 GB)
- Internet-facing Application Load Balancer (HTTP)
- Security groups for ALB and ECS tasks
- CloudWatch log group
- IAM roles for task execution

## Outputs

| Name                 | Description               |
| -------------------- | ------------------------- |
| url                  | URL to access Novelty     |
| alb_dns_name         | ALB DNS name              |
| ecs_cluster_name     | ECS cluster name          |
| ecs_service_name     | ECS service name          |
| cloudwatch_log_group | CloudWatch log group name |

## Next Steps

See the [complete example](../complete/) for HTTPS, custom domains, and advanced configuration.
