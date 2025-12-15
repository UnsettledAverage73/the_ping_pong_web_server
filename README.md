# AWS High Availability Load Balancer with Terraform

## 🚀 Project Overview
This project deploys a highly available web architecture on AWS using Infrastructure as Code (Terraform). It provisions two EC2 instances across distinct Availability Zones behind an Application Load Balancer to ensure fault tolerance.

## 🏗 Architecture
* **Provider:** AWS (us-east-1)
* **Compute:** 2x EC2 Instances (Amazon Linux 2023)
* **Networking:** Default VPC, Multi-AZ Deployment (us-east-1a, us-east-1b)
* **Traffic Management:** Application Load Balancer (ALB) with Target Groups

## 🛠 Prerequisites
* Terraform installed
* AWS CLI configured with valid credentials

## ⚙️ How to Run
1.  Clone the repo:
    ```bash
    git clone [https://github.com/YOUR_USERNAME/aws-terraform-loadbalancer-demo.git](https://github.com/YOUR_USERNAME/aws-terraform-loadbalancer-demo.git)
    ```
2.  Initialize Terraform:
    ```bash
    terraform init
    ```
3.  Plan and Apply:
    ```bash
    terraform apply
    ```
4.  Copy the `load_balancer_dns` output and paste it into your browser to see the traffic balancing.

## 🧹 Cleanup
To avoid AWS charges, destroy the infrastructure when done:
```bash
terraform destroy
