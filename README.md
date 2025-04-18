# AWS-Infrastructure-With-Terraform-Project

Overview

This project automates the deployment of a scalable and secure AWS infrastructure using Terraform. It provisions key AWS services including VPC, EC2 instances, an Application Load Balancer (ALB), RDS, and Auto Scaling Groups.

Features

Infrastructure as Code (IaC): Uses Terraform to define and provision AWS resources efficiently.

Scalability: Implements an Auto Scaling Group to maintain availability and adjust capacity automatically.

Security: Configures Security Groups to restrict access and allow only necessary traffic.

Load Balancing: Deploys an ALB to distribute traffic efficiently across EC2 instances.

Modular Design: Uses Terraform modules for better organization and reusability of infrastructure components.

AWS Resources Provisioned

Networking: VPC, public/private subnets, Internet Gateway.

Compute: EC2 instances with a Launch Template for automation.

Database: RDS instance deployed within private subnets.

Load Balancing: ALB to distribute incoming requests across multiple instances.

Security: Security Groups enforcing controlled ingress and open egress rules.

Prerequisites

Install Terraform

Configure AWS CLI (Guide)

Generate an SSH key pair for EC2 access

Deployment Steps

Clone the repository:

git clone https://github.com/bikalpa45/AWS-Infrastructure-With-Terraform-Project.git

cd aws-terraform-project

Initialize Terraform:

  terraform init

Preview the infrastructure changes:

  terraform plan

Deploy the infrastructure:

  terraform apply -auto-approve

Retrieve the Load Balancer DNS to access the deployed application:

   terraform output load_balancer_output

Cleanup

To remove all resources and prevent ongoing costs:

  terraform destroy -auto-approve

Folder Structure


      .
      ├── modules
      │   ├── vpc
      │   ├── rds
      │── webserver
      ├── main.tf
      ├── variable.tf
      ├── README.md
