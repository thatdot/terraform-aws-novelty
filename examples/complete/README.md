# Complete Example

Production-ready deployment of Novelty on AWS ECS Fargate with HTTPS and custom domain support.

## Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.5.0
- Route53 hosted zone for your domain (for HTTPS)
- Novelty Docker image pushed to your private ECR repository

## Quick Start

1. Create `terraform.tfvars`:

```hcl
project_name   = "novelty-prod"
container_image = "YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/thatdot/novelty:latest"
enable_https   = true
domain_name    = "novelty.example.com"
hosted_zone_id = "Z0123456789ABCDEFGHIJ"
```

To find your hosted zone ID:
```bash
aws route53 list-hosted-zones --query "HostedZones[?Name=='example.com.'].Id" --output text
```

2. Deploy:

```bash
terraform init
terraform plan
terraform apply
```

3. Access Novelty at `https://novelty.example.com`

## Configuration Options

See `terraform.tfvars.example` for all available options including:
- Custom VPC and subnet configuration
- Container CPU/memory allocation
- Environment variables and secrets
- ALB access restrictions

## HTTPS Options

**Option 1: Automatic (Recommended)** - Provide `domain_name` + `hosted_zone_id` and Terraform creates the ACM certificate and Route53 records.

**Option 2: Bring Your Own Certificate** - Provide `certificate_arn` for an existing ACM certificate.

## Cleanup

```bash
terraform destroy
```

Note: If you enabled `enable_deletion_protection = true`, disable it first via AWS Console or set to `false` and apply.

## What Gets Created

- ECS Fargate cluster with Container Insights
- ECS service running 1 Novelty container (4 vCPU, 8 GB)
- Internet-facing ALB with HTTPS
- ACM certificate (if using automatic option)
- Route53 alias record for custom domain
- Security groups, CloudWatch logs, IAM roles

## Outputs

| Name | Description |
|------|-------------|
| url | URL to access Novelty |
| certificate_arn | ACM certificate ARN |
| alb_dns_name | ALB DNS name |
| ecs_cluster_name | ECS cluster name |
| ecs_service_name | ECS service name |
| cloudwatch_log_group | CloudWatch log group |
