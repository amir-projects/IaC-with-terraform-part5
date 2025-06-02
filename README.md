# 📦 Terraform Project: THREE-TIER-FULL-STACK-APP

## 📝 Overview

This Terraform project provisions a **three-tier full stack application infrastructure on AWS**, consisting of:

- A VPC with public and private subnets  
- EC2 instances for application tiers  
- A managed RDS database instance  

The infrastructure is designed using **Terraform best practices**.

---

## 🔧 Prerequisites

Make sure you have the following installed and configured:

- ✅ **Terraform** (Latest Version)  
- ✅ **AWS CLI** (with credentials configured via `~/.aws/credentials`)  

---

## 🚀 Usage

Follow these steps to deploy the infrastructure:

### 1. Clone the Terraform Repository

```bash
git clone https://github.com/amir-projects/IaC-with-terraform-part5.git

cd IaC-with-terraform-part5
```

### 2. Prepare Your SSH Keys

Ensure you have SSH key pairs generated with the following naming convention:

- 🔑 **Public Key**: `id_ed25519.pub`
- 🔒 **Private Key**: `id_ed25519`

If you haven’t generated the keys yet, you can do so directly inside the `ssh-keys/` directory by running:

```bash
cd ssh-keys
ssh-keygen -t ed25519 -C ""
```
> 💡 When prompted for a file location, type the filename as: `id_ed25519`  
> 🔐 You can leave the passphrase empty (press Enter twice)


### 3. Configure the AWS Provider

Before deploying the infrastructure, you need to configure the AWS provider with your credentials.

1. Open the `provider.tf` file located in the root directory of the project.
2. Update the `profile` attribute with your AWS CLI profile name (e.g., `default`, `dev`, or any named profile you’ve set up in `~/.aws/credentials`).
3. Optionally, update the `region` attribute to your preferred AWS region (for example, `us-east-1`, `us-west-2`, etc.).

Example configuration:

```hcl
provider "aws" {
  region  = "us-west-2"    # Replace with your preferred AWS region code
  profile = "yourmentors"  # Replace this with your actual profile name
}
```
> ⚠️ Ensure that the specified AWS profile has sufficient IAM permissions to create and manage resources like VPCs, EC2 instances, and RDS databases.

### 4. Initialize the project

```bash
terraform init
```

### 5. Apply the configuration

```bash
terraform apply
```

> ✅ Confirm the apply step when prompted to create the resources.

### 🌐 Access the Application

Once the infrastructure is deployed, you can access the application using the **public IP address** of the EC2 instance on **port 5000**:

```
http://<EC2_PUBLIC_IP>:5000
```