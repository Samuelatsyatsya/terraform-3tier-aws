# 3-Tier AWS Architecture Terraform Project

---

## Architecture Explanation

This project deploys a **3-tier application architecture** on AWS using Terraform. It includes:

- **VPC Layer**: Custom VPC with public, private, and database subnets.
- **Application Layer**: Auto Scaling Group (ASG) of EC2 instances serving the application behind an ALB.
- **Database Layer**: RDS instance in private subnets for secure storage.
- **Networking**: NAT Gateway for private subnets, route tables, and security groups.

**Architecture Diagram:**


---

## Deployment Instructions

### Prerequisites
- Terraform v1.5+ installed
- AWS CLI configured (`aws configure`)
- SSH key pair for EC2 access (e.g., `my-keypair.pem`)
- IAM permissions to create VPC, EC2, ALB, RDS, etc.

### Steps

1. Clone the repository:

```bash
git clone <your-repo-url>
cd terraform-3tier-aws
```
2. Create a terraform.tfvars file with your variables:
```bash
project_name         = "my-project"
environment          = "dev"
owner                = "samuel"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
database_subnet_cidrs = ["10.0.5.0/24", "10.0.6.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]
single_nat_gateway   = true
web_app_port         = 80
enable_ssh_access    = true
ssh_cidr_blocks      = ["0.0.0.0/0"]
health_check_path    = "/"
health_check_interval = 30
health_check_timeout  = 5
instance_type        = "t3.medium"
key_name             = "my-keypair"
min_size             = 1
max_size             = 3
alb_enable_deletion_protection = false
alb_internal         = false
asg_desired_capacity = 2
```

Initialize Terraform:
```bash
terraform init
```

Plan the deployment:
```bash
terraform plan -var-file="terraform.tfvars"
```

Apply the deployment:
```bash
terraform apply -var-file="terraform.tfvars"
```

Verify resources in the AWS Console.

### Module Descriptions
Module	Purpose
vpc	Creates VPC, public/private/database subnets, Internet Gateway, NAT Gateway, route tables
alb	Creates Application Load Balancer, listeners, target groups
ec2_asg	Deploys Auto Scaling Group of EC2 instances with security groups
rds	Deploys RDS instance with storage, engine type, multi-AZ (optional)
outputs	Exposes ALB DNS, RDS endpoint, EC2 public/private IPs

### Variables and Outputs

# Key Variables
Variable	Description	Example Value
vpc_cidr	CIDR block for the VPC	10.0.0.0/16
public_subnet_cidrs	Public subnet CIDRs	["10.0.1.0/24","10.0.2.0/24"]
private_subnet_cidrs	Private subnet CIDRs	["10.0.3.0/24","10.0.4.0/24"]
instance_type	EC2 instance type	t3.medium
key_name	SSH key for EC2 access	my-keypair
min_size / max_size	Auto Scaling group min/max	1 / 3
alb_enable_deletion_protection	Protect ALB from accidental deletion	false

# Outputs
Output	Description
alb_dns_name	DNS of the ALB
rds_endpoint	RDS instance endpoint
public_ec2_ips	List of public EC2 instance IPs
private_ec2_ips	List of private EC2 instance IPs

Example Terraform outputs:

terraform output

# Screenshots

ALB – DNS name, listeners, target groups.

ICMP / Connectivity – Ping from bastion host to private EC2 instance or curl ALB.

EC2 / ASG – Auto Scaling group and running instances.

RDS – Database endpoint, engine, Multi-AZ, storage.

VPC / Subnets – VPC CIDR, public/private/database subnets, route tables.

Terraform Apply Output – Confirmation of resource creation.

⚡ Tip: Number screenshots to match sections above.

### Notes

Ensure security groups allow ICMP and SSH for testing connectivity.

Use HTTPS / HTTP health checks on the ALB for auto-scaling.

Always destroy resources after testing to avoid AWS charges:
```bash
terraform destroy -var-file="terraform.tfvars"
```