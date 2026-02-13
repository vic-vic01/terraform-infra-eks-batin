# EKS Terraform Infrastructure

Creates an EKS cluster with custom VPC on AWS using Terraform.

## What This Creates

This infrastructure includes:

- **VPC** - Custom VPC with public and private subnets across 3 availability zones
- **EKS Cluster** - Kubernetes version 1.29 control plane
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
│   └── eks/          # EKS module: cluster, nodes, IAM, add-ons
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

| Variable | Description | Default |
|----------|-------------|---------|
| `cluster_name` | Name of the EKS cluster | - |
| `vpc_cidr` | CIDR block for VPC | - |
| `environment` | Environment name (dev, staging, prod) | - |
| `availability_zones` | List of AZs for subnets | - |
| `public_subnet_cidrs` | CIDR blocks for public subnets | - |
| `private_subnet_cidrs` | CIDR blocks for private subnets | - |
| `desired_size` | Desired number of worker nodes | 3 |
| `min_size` | Minimum number of worker nodes | 1 |
| `max_size` | Maximum number of worker nodes | 5 |
| `sso_admin_arn` | ARN of SSO admin role for cluster access | - |
| `github_ci_role_arn` | ARN of GitHub CI role | - |
| `github_tf_role_arn` | ARN of GitHub Terraform role | - |

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

### 1. EKS Version Problem
I started with EKS version 1.30 but got error "Your query returned no results" 
when running terraform plan. I checked AWS docs and realized AMI for 1.30 is 
not available in us-east-1 yet. Changed to version 1.29 and it worked. 
Now I always check AMI availability before choosing EKS version.

### 2. Access Entries Issue  
I added policy associations but forgot to create actual access entry resources 
first. Got terraform error about "undeclared resource". Used grep to find the 
problem - I only had depends_on without the resources. Fixed by creating 
access entries first, then adding policies. This taught me to create resources 
before referencing them in depends_on.

### 3. Duplicate Variables
While writing this README, I noticed two variables doing same thing: 
cluster_name and eks_cluster_name. This was confusing. I removed 
eks_cluster_name and kept only cluster_name everywhere. Code is cleaner now.

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