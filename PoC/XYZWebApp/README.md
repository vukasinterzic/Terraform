# XYZ Corp Online Sales Web Application

## Introduction

This repository contains the Terraform configurations for provisioning a robust and scalable backend infrastructure for XYZ Corp's new web application on Microsoft Azure. It outlines the automation of resource provisioning and management, including virtual networks, VM scale sets, managed disks, a PostgreSQL database, and more, ensuring best practices in cloud resource management and infrastructure as code.


## Resource Overview

- **Resource Group**: Holds all related Azure resources for the application.
- **Virtual Network and Subnets**: Isolates network traffic within the application, with separate subnets for application servers and database servers.
- **VM Scale Set**: Ensures high availability and scalability for the application servers.
- **Managed Disks**: Provides persistent storage for the VMs.
- **Managed PostgreSQL Database**: Serves as the backend database for the application.
- **Load Balancer**: Distributes incoming network traffic across multiple servers to ensure no single server becomes overwhelmed.
- **Storage Account**: Stores application-related data, such as logs and backups.
- **Resource Tagging**: Tags all resources for easier identification and management.

## Module Overview

```
2_XYZWebApp/
│
├── main.tf                # Main Terraform configuration file for your project
├── variables.tf           # Variable definitions for the main module
├── outputs.tf             # Output definitions for the main module
├── README.md              # Documentation for your project. This file.
│
└── modules/               # Directory for Terraform modules
│   ├── vnet/              # VNet module
│   │   ├── main.tf        # VNet specific Terraform configurations
│   │   ├── variables.tf   # VNet module variables
│   │   ├── outputs.tf     # VNet module outputs
│   │   └── README.md      # Documentation for the VNet module
│   │
│   ├── KeyVault/         # KeyVault module
│   │   ├── main.tf       # KeyVault specific Terraform configurations
│   │   ├── variables.tf  # KeyVault module variables
│   │   ├── outputs.tf    # KeyVault module outputs
│   │   └── README.md     # Documentation for the KeyVault module
│   │
│   ├── ApplicationResources/ # ApplicationResources module
│   │   ├── main.tf            # ApplicationResources specific Terraform configurations
│   │   ├── variables.tf       # ApplicationResources module variables
│   │   ├── outputs.tf         # ApplicationResources module outputs
│   │   └── README.md          # Documentation for the ApplicationResources module
│   │
│   └── DatabaseResources/    # DatabaseResources module
│       ├── main.tf           # DatabaseResources specific Terraform configurations
│       ├── variables.tf      # DatabaseResources module variables
│       ├── outputs.tf        # DatabaseResources module outputs
│       └── README.md         # Documentation for the DatabaseResources module
│
└── examples/              # Directory for examples
    └── full_setup/        # Example for full setup
        ├── main.tf        # Example Terraform configuration
        ├── variables.tf   # Example variables
        ├── outputs.tf     # Example outputs
        └── README.md      # Documentation for the example file
```


## Prerequisites

Before you begin, ensure you have the following prerequisites installed and configured:

- **Azure Account**: Make sure you have an Azure subscription.
- **Azure CLI**: Used for authenticating Terraform with Azure.
- **Terraform**: The primary tool for deploying infrastructure as code.
- **Verify Azure Policy Compliance**: Check that existing Azure policies will not prevent the creation of the resources defined in the Terraform scripts. This includes validations for resource naming conventions, required tags, allowed locations for resources, and permitted SKUs. You can verify policies by navigating to the **Policies** section in the Azure Portal or using the Azure CLI with commands such as `az policy assignment list` and `az policy state list`.
- **Verify Azure Subscription Capacity**: Ensure your Azure subscription has sufficient capacity to create all required resource types, including VM instances, disk storage, databases, and network resources. Azure limits can vary by subscription type and region. To check your current usage and limits, you can use the Azure Portal or the Azure CLI with commands like `az vm list-usage --location <location>`. If necessary, you can request an increase in your subscription limits by submitting a support request through the Azure Portal. 



## Terraform State

The provided configuration uses a local Terraform state file for simplicity and ease of understanding. While this is suitable for development or testing environments, it's important to use a remote state for production environments. Remote state storage has several benefits, including:

- **Team Collaboration**: Remote state allows team members to access the latest state of the infrastructure, ensuring consistency across deployments.
- **State Locking**: Prevents conflicts caused by concurrent executions of Terraform apply.
- **Security and Compliance**: Centralizes state management, making it easier to secure and audit.

### Using Azure Storage for Terraform State

To configure Terraform to use Azure Storage as a backend for its state file, follow these steps:

#### Step 1: Create an Azure Storage Account

1. Log in to the Azure Portal or use the Azure CLI to create a storage account.
2. Ensure the account is set to "StorageV2" (general purpose v2) as it provides the latest features and pricing.
3. Create a storage container within the account where the Terraform state files will be stored.

Using the Azure CLI, the commands might look something like this:

```shell
# Create a resource group
az group create --name myResourceGroup --location eastus

# Create storage account
az storage account create --name mystorageaccount --resource-group myResourceGroup --location eastus --sku Standard_LRS --kind StorageV2

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group myResourceGroup --account-name mystorageaccount --query '[0].value' -o tsv)

# Create blob container
az storage container create --name tfstate --account-name mystorageaccount --account-key $ACCOUNT_KEY
```

#### Step 2: Configure Terraform to Use Azure Blob Storage

Modify your Terraform configuration to use the Azure blob storage as its backend. This involves adding a backend block to your Terraform configuration files, typically in a file named `backend.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name   = "myResourceGroup"
    storage_account_name  = "mystorageaccount"
    container_name        = "tfstate"
    key                   = "prod.terraform.tfstate"
  }
}
```


#### Step 3: Initialize Terraform

After configuring the backend, run `terraform init` to initialize it. Terraform will detect the change in configuration and prompt you to copy the existing state to the new backend. Confirm the action to migrate your local state file to the Azure blob storage.



## Configuration Steps

### 1. Clone the Repository

Start by cloning this repository to your local machine.

```bash
git clone <repository-url>
```

Navigate into the project directory.

```bash
cd <project-directory>
```

### 2. Authenticate with Azure

Use the Azure CLI to log into your Azure account.

```shell
az login
```

Set your subscription.

```shell
az account set --subscription="YOUR_SUBSCRIPTION_ID"
```

### 3. Initialize Terraform

Run the following command to initialize Terraform in your project directory.

```shell
terraform init
```

This command prepares Terraform to manage your infrastructure by downloading necessary plugins and setting up the backend.

### 4. Plan the Deployment

To see what Terraform plans to execute without actually making any changes, run:

```shell
terraform plan
```

### 5. Apply the Configuration

To create the resources in Azure as defined in your Terraform files, execute:

```shell
terraform apply
```

Confirm the action by typing `yes` when prompted.

## Support

For support or contributions, please open an issue or pull request in the repository.
