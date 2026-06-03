# AWS EKS Production Pattern

This repo is a production-pattern Terraform example for AWS. It creates the
network and platform foundation for an empty EKS cluster. It does not deploy
Kubernetes workloads and does not use the Terraform Kubernetes provider.

## What It Creates

- VPC with DNS support
- Public subnets across multiple Availability Zones
- Private subnets across multiple Availability Zones for EKS
- Internet gateway, route tables, and subnet associations
- NAT gateway egress for private subnets
- VPC flow logs to CloudWatch Logs
- Common private VPC endpoints for EKS worker traffic
- KMS key for EKS secret encryption
- EKS control plane with private subnet placement and control plane logging
- IAM roles and policy attachments for EKS and managed nodes
- Optional EKS managed node group
- AWS-managed EKS add-ons
- GitHub Actions workflow for validate, plan, and manual apply

## Cost Warning

This stack creates billable AWS resources, including EKS, NAT gateways, EC2
worker nodes, VPC endpoints, CloudWatch logs, and KMS. Review
`terraform.tfvars` before applying.

## Files

```text
main.tf                    Root provider configuration and module wiring
variables.tf               Production and cost-control inputs
outputs.tf                 IDs and kubeconfig command
modules/vpc                VPC, subnets, routing, NAT, flow logs, endpoints
modules/eks                KMS, IAM, EKS control plane, add-ons, node group
terraform.tfvars.example   Example production values
.github/workflows          Terraform CI/CD workflow
```

## Local Test

Install and configure:

```bash
terraform version
aws --version
aws sts get-caller-identity
```

Then run:

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Apply only when you are ready to create AWS resources:

```bash
terraform apply
```

Connect kubectl after apply:

```bash
aws eks update-kubeconfig --region us-east-1 --name platform-prod
kubectl get nodes
kubectl get pods -A
```

Destroy when finished:

```bash
terraform destroy
```

## GitHub Actions Deploy

The workflow in `.github/workflows/terraform.yml` uses GitHub OIDC to assume an
AWS role.

To use it:

1. Create an AWS IAM role trusted by your GitHub repository OIDC identity.
2. Grant that role the permissions needed to manage this stack.
3. Add a repository or environment secret named `AWS_ROLE_TO_ASSUME`.
4. Create a protected GitHub environment named `production`.
5. Run the `Terraform` workflow manually with `apply=true`.

For real production, switch the local backend to remote state with locking, such
as Terraform Cloud or S3 plus DynamoDB locking.
