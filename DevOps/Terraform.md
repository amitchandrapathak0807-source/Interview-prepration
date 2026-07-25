# Terraform Interview Questions & Answers
## Complete Guide (Beginner → Architect | 10+ Years Experience)

> **Interview Level:** ⭐⭐⭐⭐⭐
>
> Terraform is one of the most frequently asked DevOps and Cloud interview topics.
>
> Companies like:
>
> - Microsoft
> - Amazon
> - UBS
> - Goldman Sachs
> - JP Morgan
> - Point72
> - Walmart
> - Adobe
>
> expect candidates to know not only Terraform syntax, but also **how Terraform works internally**.

---

# Table of Contents

1. What is Terraform?
2. Terraform Internal Working
3. Core Concepts
4. State File
5. Providers
6. Resources
7. Modules
8. Variables
9. Outputs
10. Workspaces
11. Backend
12. State Locking
13. Lifecycle
14. Interview Questions (Beginner → Architect)

---

# 1. What is Terraform?

## Interview Question

### What is Terraform?

### Expected Answer

Terraform is an **Infrastructure as Code (IaC)** tool developed by HashiCorp.

It allows you to provision and manage cloud infrastructure using declarative configuration files.

Instead of manually creating Azure resources from the portal, you define the infrastructure in code.

Example

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "demo-rg"
  location = "Central India"
}
```

Terraform creates the Resource Group automatically.

---

# 2. Why Terraform?

## Problem

Without Terraform

Developer

↓

Azure Portal

↓

Click

↓

Create Resource Group

↓

Create Storage

↓

Create SQL

↓

Create Function App

Imagine creating

```
100 Resources

for

10 Environments
```

Impossible to maintain manually.

---

## Solution

Write once

```hcl
resource "azurerm_storage_account" ...
```

Run

```bash
terraform apply
```

Infrastructure created automatically.

---

# 3. How Terraform Works Internally

This is one of the most important interview questions.

---

## Step 1

Developer writes

```hcl
resource "azurerm_storage_account" ...
```

---

## Step 2

Run

```bash
terraform init
```

Terraform

- Downloads Provider
- Initializes Backend
- Creates `.terraform`

---

## Step 3

Run

```bash
terraform plan
```

Terraform

Reads

```
Terraform Files

↓

State File

↓

Azure

↓

Compares

↓

Execution Plan
```

---

## Step 4

Run

```bash
terraform apply
```

Terraform

Calls

Azure REST APIs

↓

Creates Resources

↓

Updates State File

---

## Complete Flow

```text
Terraform Code

↓

terraform init

↓

Provider Download

↓

terraform plan

↓

Compare Desired State

↓

terraform apply

↓

Azure REST API

↓

Infrastructure Created

↓

terraform.tfstate Updated
```

---

# 4. What is Terraform State?

## Definition

Terraform stores

```
Current Infrastructure

Metadata

Resource IDs

Dependencies
```

inside

```
terraform.tfstate
```

---

## Why?

Suppose

Storage Account already exists.

How does Terraform know?

It checks

```
terraform.tfstate
```

Without state

Terraform would try to create duplicate resources.

---

# Example

State File

```json
{
  "resources": [
    {
      "type": "azurerm_storage_account",
      "name": "storage"
    }
  ]
}
```

---

# Interview Question

### Can we delete terraform.tfstate?

Technically yes.

Practically

Never.

Terraform loses track of resources.

---

# 5. Local State vs Remote State

## Local

```
terraform.tfstate

inside laptop
```

Good

Development

---

## Remote

Store

```
Azure Storage

S3

Terraform Cloud
```

Best

Production

---

# Why Remote State?

Multiple developers.

Need

Shared State

Versioning

Locking

Backup

---

# 6. What is terraform init?

### Expected Answer

Initializes Terraform project.

Performs

- Downloads Providers
- Configures Backend
- Initializes Modules

Run only once per project or when providers/backends change.

---

# 7. What is terraform plan?

### Expected Answer

Creates an execution plan.

Shows

```
What Terraform

will do
```

No changes applied.

Safe command.

---

# Example

```
+ Create

~ Update

- Destroy
```

---

# 8. What is terraform apply?

Applies changes.

Creates

Updates

Deletes

Resources.

---

# 9. What is terraform destroy?

Deletes

Everything

managed

by Terraform.

---

# 10. Providers

## What are Providers?

Providers are plugins that allow Terraform to communicate with cloud platforms.

Examples

- AzureRM
- AWS
- Google
- Kubernetes
- GitHub

---

## Azure Example

```hcl
provider "azurerm" {
  features {}
}
```

Terraform uses Azure REST APIs behind the scenes.

---

# 11. Resources

Resource

means

Anything Terraform manages.

Examples

- Resource Group
- Storage Account
- SQL Database
- Function App
- App Service

---

Example

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "demo-rg"
  location = "Central India"
}
```

---

# 12. Variables

Instead of

```hcl
name="dev-storage"
```

Use

```hcl
variable "storage_name" {}
```

Now

Different environments

can use different values.

---

# 13. Outputs

Need

Storage Account Name

after deployment.

Example

```hcl
output "storage_name" {
  value = azurerm_storage_account.storage.name
}
```

---

# 14. Modules

Question

Suppose

Need

10 Storage Accounts.

Copy Paste?

No.

Create Module.

---

Example

```
Module

↓

Storage

↓

Called

10 Times
```

Reusable.

---

# Module Structure

```
modules

↓

storage

main.tf

variables.tf

outputs.tf
```

---

# 15. Backend

Backend stores

```
State File
```

Example

Azure Blob Storage.

```hcl
terraform {
  backend "azurerm" {}
}
```

---

# Why Backend?

- Shared State
- Versioning
- Team Collaboration
- Locking

---

# 16. State Locking

Suppose

Developer A

Runs

```
terraform apply
```

Developer B

Also

Runs

```
terraform apply
```

Same time.

Disaster.

Need

Lock.

Azure Blob Storage

supports state locking via blob leases when used as the backend.

---

# 17. Drift Detection

Suppose

Portal

↓

Delete Storage Account.

Terraform

Doesn't know.

Run

```
terraform plan
```

Terraform compares

```
State

↓

Azure

↓

Difference Found
```

Recreates resource if configuration still requires it.

---

# 18. Lifecycle Block

Example

```hcl
lifecycle {

  prevent_destroy = true

}
```

Protects

Production Resources.

---

Other options

```
ignore_changes

create_before_destroy

replace_triggered_by
```

---

# 19. Depends On

Sometimes

Terraform

cannot detect dependency.

Use

```hcl
depends_on = [
    azurerm_resource_group.rg
]
```

---

# 20. Data Source

Difference

Resource

Creates

Data Source

Reads Existing.

Example

```hcl
data "azurerm_resource_group" "existing" {
  name = "prod-rg"
}
```

---

# Resource vs Data Source

| Resource | Data Source |
|----------|-------------|
| Creates | Reads Existing |
| Managed | Not Managed |

---

# 21. Workspace

Used for

```
Dev

QA

UAT

Production
```

Same code.

Different State.

---

# 22. Import

Suppose

Resource

already exists.

Portal

↓

Need Terraform.

Run

```bash
terraform import
```

Terraform

starts managing

existing resource.

---

# 23. Refresh

Terraform

reads

current Azure infrastructure

and updates

state.

Modern versions perform refresh as part of planning; the old standalone `terraform refresh` command is deprecated.

---

# Production Folder Structure

```text
terraform/

│

├── modules/

│     ├── storage/

│     ├── sql/

│     ├── appservice/

│

├── dev/

├── qa/

├── prod/

│

├── main.tf

├── variables.tf

├── outputs.tf

├── backend.tf

└── providers.tf
```

---

# Best Practices

- Store State remotely.
- Enable State Locking.
- Never edit State manually.
- Use Modules.
- Use Variables.
- Keep Resources small.
- Separate environments.
- Use Managed Identity or Service Principal securely.
- Store secrets outside code (e.g., Key Vault).
- Review `terraform plan` before `apply`.

---

# Common Mistakes

❌ Storing State in Git.

---

❌ Hardcoding passwords.

---

❌ One huge Terraform file.

---

❌ Running Apply without Plan.

---

❌ Sharing Local State.

---

# Frequently Asked Interview Questions

## Beginner

### What is Terraform?

Infrastructure as Code tool.

---

### Difference between init and apply?

Init

Downloads providers.

Apply

Creates resources.

---

### What is State File?

Tracks

Current Infrastructure.

---

### What is Provider?

Plugin

for Azure

AWS

GCP

---

## Intermediate

### Difference between Resource and Module?

Resource

Single infrastructure object.

Module

Collection of resources.

---

### Why Remote State?

Shared Team

Locking

Versioning

---

### What is Backend?

Stores

Terraform State.

---

### Difference between Variables and Outputs?

Variables

Input.

Outputs

Return values.

---

## Senior (10+ Years)

### Question

Explain Terraform's internal working.

### Expected Answer

```
Write HCL

↓

terraform init

↓

Download Providers

↓

terraform plan

↓

Compare Desired State

↓

Current State

↓

Execution Plan

↓

terraform apply

↓

Azure REST API

↓

Update State
```

---

### Question

Why is State File so important?

### Expected Answer

The state file maps Terraform configuration to real cloud resources. It enables change detection, dependency tracking, and efficient updates. Losing the state file makes Terraform lose knowledge of what it manages.

---

### Question

What happens if two engineers run terraform apply simultaneously?

### Expected Answer

Without state locking, concurrent updates can corrupt the state or create inconsistent infrastructure. Remote backends with locking prevent simultaneous modifications.

---

### Question

How do you manage multiple environments?

### Expected Answer

Common approaches include:

- Separate state files/backends per environment.
- Separate folders (dev/qa/prod).
- Reusable modules.
- Environment-specific variable files (`.tfvars`).
- Workspaces for simpler scenarios.

---

### Question

How would you deploy Azure infrastructure for a production banking application?

### Expected Answer

- Use reusable modules.
- Store remote state in Azure Storage.
- Enable state locking.
- Separate environments.
- Use Managed Identity or Service Principal.
- Store secrets in Azure Key Vault.
- Integrate with Azure DevOps/GitHub Actions CI/CD.
- Review `terraform plan` before applying.
- Protect critical resources with lifecycle rules where appropriate.

---

# One-Line Interview Answer

> **Terraform is an Infrastructure as Code tool that compares the desired infrastructure defined in HCL with the current infrastructure using its state file, generates an execution plan, calls cloud provider APIs to create or update resources, and records the final state for future operations.**