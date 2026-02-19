# EKS Terraform Infrastructure

Creates an EKS cluster with custom VPC on AWS using Terraform.

## What This Creates

This infrastructure includes:

- **VPC** - Custom VPC with public and private subnets across 3 availability zones
- **EKS Cluster** - Kubernetes version 1.34 control plane
- **Worker Nodes** - Self-managed EC2 instances in Auto Scaling Group
- **Mixed Instances Policy** - Cost optimization: 20% on-demand, 80% spot instances
- **IAM Roles** - Separate roles for cluster and worker nodes with required policies
- **Security Groups** - Network access control for worker nodes
- **Access Entries** - Cluster access for SSO admin and GitHub CI/CD runners
- **EKS Add-ons** - VPC CNI (native pod networking) and EBS CSI (dynamic volume provisioning)

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with credentials
- AWS account with permissions to create VPC, EKS, EC2, and IAM resources
- kubectl (optional) - for cluster access after deployment

## Project Structure
```
terraform-infra-25b-centos/
├── modules/
│   ├── vpc/          # VPC module: networking resources
│   └── eks/          # EKS module
│       ├── cluster.tf    # EKS cluster and security group
│       ├── iam.tf        # IAM roles and policies
│       ├── nodes.tf      # Launch template and ASG
│       ├── access.tf     # Access entries
│       ├── addons.tf     # EKS add-ons
│       ├── variables.tf  # Variable definitions
│       └── outputs.tf    # Output values
└── roots/
    └── devops-project-main/
        ├── main.tf        # Module calls
        ├── variables.tf   # Variable definitions
        ├── providers.tf   # AWS provider configuration
        └── dev.tfvars     # Environment-specific values
```

The project uses a modular structure:
- **modules/** - Reusable Terraform modules for VPC and EKS
- **roots/** - Root configuration that calls modules and defines environment-specific settings

## How to Use

1. **Clone the repository**
```bash
   git clone <repository-url>
   cd terraform-infra-25b-centos/roots/devops-project-main
```

2. **Configure variables**
   
   Create or update `dev.tfvars` with your values:
```hcl
   cluster_name         = "your-cluster-name"
   vpc_cidr            = "10.0.0.0/16"
   environment         = "dev"
   availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]
   sso_admin_arn       = "arn:aws:iam::..."
   # ... other variables
```

3. **Initialize Terraform**
```bash
   terraform init
```

4. **Review the plan**
```bash
   terraform plan -var-file=dev.tfvars
```

5. **Deploy infrastructure**
```bash
   terraform apply -var-file=dev.tfvars
```

6. **Access the cluster** (after deployment)
```bash
   aws eks update-kubeconfig --name <cluster-name> --region us-east-1
   kubectl get nodes
```

## Key Variables

| Variable | Description |
|----------|-------------|
| `cluster_name` | Name of the EKS cluster |
| `vpc_cidr` | CIDR block for VPC |
| `environment` | Environment name (dev, staging, prod) |
| `availability_zones` | List of AZs for subnets |
| `public_subnet_cidrs` | CIDR blocks for public subnets |
| `private_subnet_cidrs` | CIDR blocks for private subnets |
| `kubernetes_version` | Kubernetes version for EKS cluster |
| `desired_size` | Desired number of worker nodes |
| `min_size` | Minimum number of worker nodes |
| `max_size` | Maximum number of worker nodes |
| `instance_type` | EC2 instance type for worker nodes |
| `ami_owner` | AWS account ID that owns the EKS AMI |
| `service_cidr` | Kubernetes service CIDR block |
| `on_demand_percentage` | % of on-demand instances in ASG |
| `on_demand_base_capacity` | Base number of on-demand instances |
| `sso_admin_arn` | ARN of SSO admin role for cluster access |
| `github_ci_role_arn` | ARN of GitHub CI role |
| `github_tf_role_arn` | ARN of GitHub Terraform role |

See `variables.tf` for complete list and descriptions.

## Outputs

After successful deployment, Terraform will display:

| Output | Description |
|--------|-------------|
| `cluster_endpoint` | EKS cluster API server endpoint |
| `cluster_name` | Name of the EKS cluster |
| `vpc_id` | ID of the created VPC |

Use these values to configure kubectl:
```bash
aws eks update-kubeconfig --name <cluster_name> --region us-east-1
```

## Challenges and Solutions

### 1. EKS Version and AMI Compatibility
When upgrading the cluster to version 1.34, Terraform plan failed with 
"Your query returned no results" on the AMI data source. After investigating, 
I found that AWS switched to Amazon Linux 2023 as default OS starting from 
Kubernetes 1.30, which uses nodeadm instead of the old bootstrap.sh script. 
Fixed by updating the AMI filter to AL2023 format and rewriting user data 
to use NodeConfig API.

### 2. Node Authentication Issue
Nodes were not joining the cluster after deployment. Spent a lot of time 
debugging - turned out GitHub Actions was running under a different IAM role 
than the one configured in Access Entries. Fixed by making sure the correct 
role ARN is passed via variables instead of hardcoding it.

### 3. EKS Module Got Too Big
main.tf grew to 250+ lines which made it hard to navigate and debug. 
Split it into separate files by resource type: cluster.tf, iam.tf, nodes.tf, 
access.tf, addons.tf. Also removed all hardcoded default values from variables 
and moved them to dev.tfvars. Much easier to work with now.

### 4. Spot Instance Capacity Issues
ASG kept failing with InsufficientInstanceCapacity for spot instances in us-east-1. 
Fixed by adding multiple instance types via override blocks (t3.medium, t3.large, 
m5.large, m5a.large, m4.large) and switching spot allocation strategy from 
lowest-price to capacity-optimized. This gives ASG more options to find 
available spot capacity.

## Workflow for Terraform State Management

This repository uses a dynamic approach to manage Terraform state files across different branches to prevent conflicts and ensure seamless collaboration.

### Key Points:

- **Dynamic Bucket Key with Account Number**: The Terraform state file's bucket key includes the AWS account number, making the YAML file dynamic and eliminating the need for manual adjustments per team.

- **Branch Name as State File Key**: We use the branch name as the state file key in the S3 bucket. This allows multiple users to run Terraform in the same AWS account from different branches without overwriting each other's state files.

- **Handling Resource Conflicts**: Since all changes are eventually merged into the main branch, running the same Terraform code from feature branches in the main branch would typically cause conflicts (e.g., a security group with the same name already exists). To avoid the cost of using different accounts or `.tfvars` for `main` branch, we adopt a functional workaround:

  - **Terraform Destroy on PR Approval**: we have a Terraform destroy job that triggers upon PR approval into the main branch. This ensures resources created in feature branches are destroyed before being applied in the main branch, preventing conflicts. The workflow for this can be found in `.github/workflows/terraform-destroy-dev.yaml`

### Workflow Overview:

1. **Terraform Apply** in `feature/x` branch *when a commit is pushed.*
2. **Terraform Destroy** in `feature/x` branch *when a PR from `feature-x` to `main` branch is approved.*
3. **Terraform Apply** in `main` branch *after PR merge.*

This approach ensures efficient resource management and conflict resolution in a multi-branch, multi-user Terraform environment.