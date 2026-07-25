# Databricks Unity Catalog Explained
## Goal → Problem → Solution → Internal Working (Step-by-Step)

> **Interview Level:** ⭐⭐⭐⭐⭐
>
> Unity Catalog is one of the most important Databricks concepts.
>
> Most people know:
>
> > "Unity Catalog is for data governance."
>
> But interviewers expect you to explain:
>
> - Why was it created?
> - What problem does it solve?
> - How does it work internally?
> - What exactly happens when a user queries a table?
> - How does security work?

---

# Goal

Imagine you are working in a large bank like **UBS**.

There are multiple teams.

```
Risk Team

Fraud Team

Finance Team

Trading Team

Analytics Team

ML Team
```

All teams use Databricks.

Question:

How do you ensure

- Finance cannot access HR salary data?
- Interns cannot access Production?
- Data Scientists cannot delete production tables?
- Every query is audited?
- Sensitive columns like PAN or Aadhaar are masked?

This is exactly why Unity Catalog exists. 0

---

# Before Unity Catalog

Earlier Databricks used

```
Hive Metastore
```

Each workspace managed its own metadata.

Example

```
Workspace A

Customers

Orders

Payments
```

```
Workspace B

Customers

Orders

Payments
```

Now imagine

```
10 Workspaces
```

Every workspace

had

- separate permissions
- separate metadata
- separate security

Huge management nightmare.

---

# Problem

Suppose

Finance Team

has access to

```
Payments
```

Now another workspace is created.

You again configure

permissions.

Another workspace.

Again.

Another.

Again.

Now imagine

```
100 Workspaces
```

You maintain permissions

100 times.

Not scalable. 1

---

# Goal Revisited

Need

```
One Place

to manage

Everything
```

- Users
- Permissions
- Tables
- Views
- Functions
- Models
- Lineage
- Audit

This became

```
Unity Catalog
```

---

# What Exactly is Unity Catalog?

Unity Catalog is

```
Central Metadata

+

Central Security

+

Central Governance
```

for every Databricks workspace. 2

---

# Think Like This

Imagine a huge office.

Without Security

Anyone

can enter

any room.

Bad.

Now imagine

Reception Desk.

Everyone enters

through Reception.

Reception checks

```
Who are you?

Which department?

Which floor?

Which room?

Permission?
```

Then allows access.

Unity Catalog

is

that Reception.

---

# High-Level Architecture

```text
             Users

               │

               ▼

        Unity Catalog

      (Security Layer)

               │

               ▼

      Databricks Cluster

               │

               ▼

 Delta Lake / ADLS / S3
```

Notice

Nobody directly reaches Storage.

Everything goes through

Unity Catalog.

---

# Main Components

```text
Metastore

↓

Catalog

↓

Schema

↓

Table
```

---

# Component 1 - Metastore

Think of

Metastore as

```
Master Library
```

It contains

```
All Catalogs

All Permissions

All Metadata
```

Usually

One Metastore

per region

shared by multiple workspaces. 3

---

# Component 2 - Catalog

Think of Catalog

like

```
Department
```

Example

```
Finance

Sales

Marketing

HR
```

Each department

gets one Catalog.

Example

```
finance

sales

hr
```

---

# Component 3 - Schema

Inside

Finance

```
finance

↓

bronze

silver

gold
```

or

```
finance

↓

transactions

customers

reports
```

Schema

groups related tables.

---

# Component 4 - Tables

Inside

```
finance

↓

transactions

↓

payment
```

Three-level naming

```
catalog

↓

schema

↓

table
```

Example

```sql
finance.transactions.payment
```

This three-level namespace is the core object model of Unity Catalog. 4

---

# Complete Hierarchy

```text
Metastore

│

├── Finance Catalog

│      │

│      ├── Transactions Schema

│      │      │

│      │      ├── Payments

│      │      └── Refunds

│      │

│      └── Reports Schema

│

└── HR Catalog

       │

       └── Employees
```

---

# Now Let's Query Data

Suppose

Rahul

runs

```sql
SELECT *

FROM finance.transactions.payment;
```

What happens?

Let's see internally.

---

# Step 1

Rahul submits SQL.

```text
SELECT *

FROM finance.transactions.payment
```

---

# Step 2

SQL reaches

Unity Catalog.

Not Storage.

---

# Step 3

Unity Catalog checks

```
Who is Rahul?
```

Using

Azure AD / Identity.

---

# Step 4

Unity Catalog asks

```
Which groups?

Finance?

Admin?

Intern?
```

Suppose

Rahul belongs to

```
Finance Team
```

---

# Step 5

Unity Catalog checks permissions.

```
Finance Team

↓

Can Read?

YES
```

---

# Step 6

Unity Catalog resolves

```
finance.transactions.payment
```

It knows

where

actual files exist.

Example

```
ADLS

abfss://prod/payment/
```

or

```
S3

s3://finance/payment/
```

Notice

SQL never knew storage path.

Unity Catalog translates logical names into physical storage locations. 5

---

# Step 7

Cluster reads

Delta files.

---

# Step 8

Results returned.

Simple.

---

# What If Rahul Doesn't Have Permission?

Unity Catalog

stops

everything.

Storage

never gets accessed.

Security check

happens first.

---

# Internal Flow

```text
User

↓

SQL Query

↓

Unity Catalog

↓

Authentication

↓

Authorization

↓

Metadata Lookup

↓

Storage Location

↓

Delta Lake

↓

Spark Execution

↓

Results
```

---

# Managed Table vs External Table

This is another favorite interview question.

---

## Managed Table

Unity Catalog manages

- Metadata
- Storage
- Lifecycle

Example

```sql
CREATE TABLE finance.sales.orders
```

Databricks decides

where

files live.

If table is dropped

Data files

are also deleted. 6

---

## External Table

Files already exist.

Example

```
Azure Data Lake

↓

CSV Files
```

Unity Catalog

only stores metadata.

Files remain

outside.

If table deleted

Files remain.

---

# Security Example

Suppose

Table

```
Employee
```

Columns

```
Id

Name

Salary

PAN
```

HR

Should see

everything.

Finance

Should NOT see

PAN.

Unity Catalog supports fine-grained governance such as permissions and policies on governed objects. 7

---

# Data Lineage

Question

```
Where did

Gold.Customer

come from?
```

Unity Catalog tracks

```
Bronze.Customer

↓

Silver.Customer

↓

Gold.Customer
```

Automatically.

You know

which notebook

pipeline

or job

created a table. 8

---

# Audit Logs

Suppose

Auditor asks

```
Who accessed

Payment Table

Yesterday?
```

Unity Catalog

stores

audit information.

You can answer

```
User

Time

Operation
```

Useful for

Banks

Healthcare

Finance. 9

---

# Why Not Give Direct ADLS Access?

Without Unity Catalog

Every user

needs

Storage permissions.

Huge security risk.

With Unity Catalog

```
User

↓

Unity Catalog

↓

Storage
```

Storage remains protected.

---

# Real UBS Example

Suppose

You have

```
Raw Market Data

↓

Bronze

↓

Silver

↓

Gold
```

Teams

```
Trading

Risk

Compliance

Research
```

Each team

gets

different permissions

on the same data.

Nobody manages storage ACLs manually.

Unity Catalog

does it centrally.

---

# Best Practices

✅ One metastore per region.

✅ Organize catalogs by business domain (Finance, Risk, HR) or environment strategy that fits your organization.

✅ Use groups instead of assigning permissions to individual users.

✅ Prefer managed tables unless external storage ownership is required.

✅ Enable audit logging.

✅ Use lineage to understand downstream impact before changing data.

---

# Common Interview Questions

## Beginner

### What is Unity Catalog?

A centralized governance layer for data and AI assets in Databricks that manages metadata, permissions, lineage, and auditing. 10

---

### What is the hierarchy?

```
Metastore

↓

Catalog

↓

Schema

↓

Table
```

---

### Difference between Catalog and Schema?

Catalog

Highest logical grouping.

Schema

Groups related objects inside a catalog.

---

## Senior

### Why was Unity Catalog introduced?

To replace workspace-specific metadata management with centralized governance across multiple workspaces, providing consistent security, lineage, auditing, and object management. 11

---

### Explain what happens when a query is executed.

1. User submits SQL.
2. Identity is authenticated.
3. Unity Catalog checks authorization.
4. Metadata is resolved.
5. Physical storage location is identified.
6. Spark reads Delta files.
7. Results are returned.

---

### Managed Table vs External Table?

| Managed Table | External Table |
|---------------|----------------|
| Unity Catalog manages metadata and storage lifecycle | Unity Catalog manages only metadata |
| Files deleted when table is dropped | Files remain after table is dropped |
| Best for Databricks-managed data | Best for shared/existing data lakes |

---

# One-Line Interview Answer

> **Unity Catalog is Databricks' centralized governance layer that sits between users and data storage. It authenticates users, authorizes access, manages metadata, resolves logical table names to physical storage, tracks lineage, records audit logs, and enforces consistent security across multiple Databricks workspaces.** 12
````13