# AWS AI Platform — Production Terraform Pattern

Production-ready Terraform for an AI platform on AWS. Provides the full
infrastructure foundation: networking, Kubernetes, database, cache, storage,
security, TLS, and observability. Does not deploy Kubernetes workloads.

## Architecture

```
                        ┌─────────────────────────────────────┐
                        │              VPC 10.40.0.0/16        │
                        │                                       │
          Internet ──── IGW                                     │
                        │                                       │
          ┌─────────────┼─────────────┐                        │
          │  Public /20 │  Public /20 │  Public /20            │
          │  us-east-1a │  us-east-1b │  us-east-1c            │
          │   NAT GW    │   NAT GW    │   NAT GW               │
          └──────┬──────┴──────┬──────┴──────┬─────────────────┘
                 │             │             │
          ┌──────▼─────────────▼─────────────▼──────────────────┐
          │  Private /20    Private /20    Private /20           │
          │  us-east-1a     us-east-1b     us-east-1c            │
          │                                                       │
          │   EKS nodes    EKS GPU nodes   RDS (multi-AZ)        │
          │   ElastiCache  (g4dn.xlarge)   Redis replica         │
          └───────────────────────────────────────────────────────┘
```

## What It Creates

### Networking (`modules/vpc`)
- VPC with DNS hostnames and DNS support enabled
- Public and private subnets across 3 Availability Zones
- Internet gateway and NAT gateways (one per AZ for HA)
- VPC flow logs to CloudWatch Logs
- Private VPC endpoints: S3 (gateway), ECR, EC2, logs, STS

### Kubernetes (`modules/eks`)
- EKS control plane in private subnets with KMS secrets encryption
- All 5 control plane log types shipped to CloudWatch
- OIDC provider for IRSA (pod-level IAM without credentials)
- Managed node group: `t3.medium`, min 2 / max 6
- GPU node group: `g4dn.xlarge` with `nvidia.com/gpu=true:NoSchedule` taint (optional, off by default)
- AWS-managed add-ons: CoreDNS, kube-proxy, VPC CNI, EKS Pod Identity

### Database (`modules/rds`)
- RDS PostgreSQL 16 — multi-AZ, `db.t4g.medium`
- KMS encryption at rest, gp3 storage with autoscaling to 500 GB
- `pgvector` and `pg_stat_statements` pre-loaded via parameter group
- Master password managed by AWS Secrets Manager (no plaintext)
- 7-day automated backups, deletion protection enabled

### Cache (`modules/cache`)
- ElastiCache Redis 7.1 — 3-node replication group across AZs
- Automatic failover, TLS in transit, AES256 at rest
- Slow-log and engine-log shipped to CloudWatch

### Storage (`modules/s3`)
- S3 bucket for AI assets: model weights, datasets, embeddings, outputs
- Versioning enabled, AES256 encryption, all public access blocked
- SSL-only bucket policy
- Lifecycle: transition to Glacier IR after 90 days
- Separate access-logs bucket

### Identity (`modules/irsa`)
- IAM role for the `ai-workload` Kubernetes service account
- Amazon Bedrock access: `InvokeModel`, `InvokeModelWithResponseStream`
- S3 read/write access scoped to the AI assets bucket

### Load Balancer (`modules/alb`)
- IAM role for the AWS Load Balancer Controller (Helm chart not included)
- ALB security group — ports 80 and 443 open to configured CIDRs

### TLS (`modules/acm`)
- ACM certificate with DNS validation
- Outputs DNS validation records for Route53 (or any DNS provider)

### WAF (`modules/waf`)
- WAFv2 Web ACL (Regional) attached to ALB
- AWS managed rules: CommonRuleSet + KnownBadInputsRuleSet
- Rate limiting: block IPs exceeding 2000 requests / 5 minutes
- Optional geo-blocking by country code
- WAF logs to CloudWatch

### Observability (`modules/observability`)
- SNS topic for alarm notifications
- CloudWatch dashboard: EKS CPU/memory, RDS CPU/connections/storage, Redis CPU/memory/connections
- CloudWatch alarms: RDS CPU >80%, RDS storage <10 GB, Redis CPU >80%, Redis memory >80%, EKS node CPU >80%
- Application log group with metric filters for AI error rate and latency
- Alarms for AI API error rate and p99 latency thresholds

### Remote State (`bootstrap/`)
- S3 bucket with versioning and encryption for Terraform state
- DynamoDB table for state locking

## Cost Warning

This stack creates billable AWS resources. Key cost drivers:

| Resource | Approx cost |
|---|---|
| EKS control plane | ~$72/month |
| NAT gateways (3×) | ~$100/month + data transfer |
| RDS `db.t4g.medium` multi-AZ | ~$100/month |
| ElastiCache `cache.t4g.medium` 3× | ~$150/month |
| GPU node `g4dn.xlarge` (when enabled) | ~$0.53/hour per node |

Review `terraform.tfvars` before applying. Use `single_nat_gateway = true` and smaller instance types to reduce cost in non-production environments.

## Files

```text
bootstrap/                 One-time state backend setup (run first)
main.tf                    Provider configuration and module wiring
variables.tf               All input variable declarations with defaults
outputs.tf                 IDs, endpoints, and connection info
terraform.tfvars           Production values
terraform.tfvars.example   Example values for reference
modules/vpc                VPC, subnets, routing, NAT, flow logs, endpoints
modules/eks                EKS cluster, OIDC, node groups, KMS, IAM
modules/rds                RDS PostgreSQL with pgvector, KMS, Secrets Manager
modules/cache              ElastiCache Redis replication group
modules/s3                 AI assets bucket with lifecycle and logging
modules/irsa               IAM role for Kubernetes service accounts
modules/alb                AWS Load Balancer Controller IAM + security group
modules/acm                ACM TLS certificate
modules/waf                WAFv2 Web ACL with managed rules and rate limiting
modules/observability      CloudWatch alarms, dashboard, and log groups
.github/workflows          Terraform CI/CD workflow
```

## Getting Started

### Prerequisites

```bash
terraform version   # >= 1.6.0
aws --version
aws sts get-caller-identity
```

### Step 1 — Bootstrap remote state (once)

```bash
cd bootstrap
terraform init
terraform apply
cd ..
```

This creates the S3 bucket and DynamoDB table used by the remote backend.

### Step 2 — Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

At minimum update:
- `acm_domain_name` — your actual domain
- `acm_subject_alternative_names` — your SANs
- `cluster_endpoint_public_access_cidrs` — restrict to your IP range

### Step 3 — Init and plan

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

### Step 4 — Apply

```bash
terraform apply
```

### Step 5 — Connect kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name platform-prod
kubectl get nodes
kubectl get pods -A
```

### Step 6 — Validate ACM certificate

After apply, check the `acm_domain_validation_options` output and add the DNS
records to your DNS provider. The certificate activates automatically once the
records are present.

```bash
terraform output acm_domain_validation_options
```

### Destroy

```bash
terraform destroy
```

Note: `db_deletion_protection = true` must be set to `false` and applied before
RDS can be destroyed.

## GPU Workloads

GPU nodes are off by default. To enable:

```hcl
# terraform.tfvars
enable_gpu_node_group   = true
gpu_node_desired_size   = 1
gpu_node_min_size       = 0
gpu_node_max_size       = 4
gpu_node_instance_types = ["g4dn.xlarge"]
```

GPU pods must tolerate the `nvidia.com/gpu=true:NoSchedule` taint:

```yaml
tolerations:
  - key: "nvidia.com/gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
```

## pgvector (Vector Database)

pgvector is pre-loaded on the RDS instance via the parameter group. Enable it
in your application database after connecting:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

Then create vector columns and indexes as needed for RAG pipelines.

## IRSA (Pod IAM)

The `ai-workload` service account in the `ai-platform` namespace is pre-wired
with IAM permissions for Bedrock and S3. Use it in your pod spec:

```yaml
serviceAccountName: ai-workload
```

Annotate the Kubernetes service account with the role ARN from the output:

```bash
terraform output irsa_ai_workload_role_arn
```

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ai-workload
  namespace: ai-platform
  annotations:
    eks.amazonaws.com/role-arn: <role_arn>
```

## GitHub Actions Deploy

The workflow in `.github/workflows/terraform.yml` uses GitHub OIDC to assume an
AWS IAM role — no long-lived credentials needed.

1. Create an IAM role trusted by your GitHub repository OIDC identity
2. Grant it permissions to manage this stack
3. Add a repository secret `AWS_ROLE_TO_ASSUME`
4. Create a protected GitHub environment named `production`
5. Run the `Terraform` workflow manually with `apply=true`
