# Database Keys and Constraints Explained (SQL Server)

> One of the most frequently asked SQL interview topics is **Database Keys and Constraints**.
>
> Every enterprise application (Banking, Amazon, Uber, Healthcare, etc.) relies on keys and constraints to ensure:
>
> - Data Integrity
> - Data Consistency
> - Performance
> - Referential Integrity
> - Data Validation

Without keys and constraints, your database would quickly become inconsistent and unreliable.

---

# Table of Contents

1. What are Keys?
2. Why do we need Keys?
3. What are Constraints?
4. Types of Keys
5. Types of Constraints
6. Real-world Examples
7. Internal Working
8. Performance Considerations
9. Best Practices
10. Common Mistakes
11. Interview Questions

---

# Why Do We Need Keys?

Imagine an online banking application.

Customer Table

| CustomerId | Name |
|------------|------|
| 1 | Amit |
| 2 | Rahul |
| 3 | Neha |

Suppose there is **no unique identifier**.

```
Name = Amit
```

Now there are two customers named Amit.

Which one should the bank transfer money to?

Impossible to determine.

That's why every table needs a **unique identifier**.

---

# What is a Key?

## Definition

A **Key** is one or more columns that help identify, relate, or uniquely distinguish rows in a table.

Keys help with:

- Uniqueness
- Relationships
- Searching
- Joining tables
- Performance

---

# Types of Database Keys

```
Database Keys

│

├── Primary Key

├── Foreign Key

├── Candidate Key

├── Alternate Key

├── Composite Key

├── Super Key

├── Unique Key

└── Surrogate Key
```

---

# 1. Primary Key (PK)

## Definition

A Primary Key uniquely identifies every row in a table.

Every table should have one Primary Key.

---

## Example

Customer

| CustomerId | Name |
|------------|------|
| 1 | Amit |
| 2 | Rahul |
| 3 | Neha |

CustomerId is Primary Key.

---

## SQL

```sql
CREATE TABLE Customer
(
    CustomerId INT PRIMARY KEY,

    Name VARCHAR(100)
);
```

---

## Rules

Primary Key

- Unique
- Cannot be NULL
- One Primary Key per table

---

## Why?

Without PK

```
Customer

Amit

Amit

Amit
```

How will you update one specific Amit?

Impossible.

---

## Banking Example

```
AccountNumber
```

is Primary Key.

---

## Internal Working

SQL Server automatically creates

```
Unique Index
```

on Primary Key.

Searching becomes very fast.

---

# 2. Foreign Key (FK)

## Definition

A Foreign Key connects two tables.

It maintains

```
Referential Integrity
```

---

Example

Customer

| CustomerId |
|------------|
| 1 |
| 2 |

Orders

| OrderId | CustomerId |
|----------|------------|
| 101 | 1 |
| 102 | 1 |
| 103 | 2 |

CustomerId inside Orders

↓

Foreign Key

---

## SQL

```sql
CREATE TABLE Orders
(
    OrderId INT PRIMARY KEY,

    CustomerId INT,

    FOREIGN KEY(CustomerId)
    REFERENCES Customer(CustomerId)
);
```

---

## Why?

Suppose

Customer

```
1
2
```

Order

```
CustomerId = 999
```

Customer 999 doesn't exist.

Without FK

Database allows bad data.

With FK

SQL Server rejects it.

---

## Real World

```
Order

↓

Customer
```

```
Transaction

↓

Account
```

```
Employee

↓

Department
```

---

# Internal Working

When inserting

```
Order(CustomerId = 1)
```

SQL Server checks

```
Customer table
```

If found

Insert succeeds.

Else

Insert fails.

---

# 3. Candidate Key

## Definition

A column (or set of columns) that **can uniquely identify** a row.

There may be multiple candidate keys.

One becomes the Primary Key.

---

Example

Employee

| EmployeeId | PAN | Email |
|------------|-----|--------|
| 1 | ABC123 | a@test.com |

All three are unique.

Possible keys

- EmployeeId
- PAN
- Email

All are Candidate Keys.

---

# 4. Alternate Key

Candidate Keys

```
EmployeeId

PAN

Email
```

Choose

```
EmployeeId
```

as Primary Key.

Remaining

```
PAN

Email
```

↓

Alternate Keys.

Usually enforced using

```
UNIQUE
```

---

SQL

```sql
CREATE TABLE Employee
(
    EmployeeId INT PRIMARY KEY,

    PAN VARCHAR(20) UNIQUE,

    Email VARCHAR(100) UNIQUE
);
```

---

# 5. Composite Key

Primary Key made from multiple columns.

---

Example

StudentCourse

```
StudentId

CourseId
```

One student

Many courses

Need both columns together.

---

SQL

```sql
PRIMARY KEY
(
StudentId,
CourseId
)
```

---

Why?

StudentId alone

↓

Not unique.

CourseId alone

↓

Not unique.

Together

↓

Unique.

---

Example

| Student | Course |
|----------|--------|
| 1 | SQL |
| 1 | C# |

Unique combination.

---

# 6. Super Key

Any combination of columns that uniquely identifies a row.

Example

```
EmployeeId
```

Unique.

Also

```
EmployeeId

Email
```

Unique.

Also

```
EmployeeId

Name

DOB
```

Still unique.

All are Super Keys.

Smallest one

↓

Candidate Key.

---

# 7. Unique Key

Similar to Primary Key.

Difference

| Primary | Unique |
|----------|---------|
| One per table | Many allowed |
| No NULL | SQL Server allows one NULL |
| Main identifier | Alternate uniqueness |

---

SQL

```sql
Email VARCHAR(100) UNIQUE
```

---

Real World

Customer

```
CustomerId

Email

Mobile
```

Email

↓

Unique

Mobile

↓

Unique

---

# 8. Surrogate Key

Artificial key.

Generated by database.

Example

```sql
IDENTITY(1,1)
```

---

Customer

| CustomerId | Aadhaar |
|------------|----------|
| 1 | XXXXX |

CustomerId

Generated.

Business doesn't care.

Database uses it.

---

Why?

Business values change.

Employee Code

```
EMP100
```

Later

```
EMP200
```

Primary Key changes.

Bad.

Instead

```
EmployeeId

1

2

3
```

Never changes.

---

# Database Constraints

Constraints enforce rules.

Think of them as the database's "security guards."

---

# Types of Constraints

```
Constraints

Primary Key

Foreign Key

Unique

Check

Not Null

Default
```

---

# 1. NOT NULL

Column cannot be empty.

SQL

```sql
Name VARCHAR(100) NOT NULL
```

Bad

```
NULL
```

Good

```
Amit
```

---

Real World

Bank Account

Holder Name

Cannot be NULL.

---

# 2. UNIQUE

No duplicates.

Example

Email

```
amit@test.com

amit@test.com
```

Rejected.

---

SQL

```sql
Email VARCHAR(100) UNIQUE
```

---

# 3. CHECK Constraint

Validates data.

Age

Must be

18+

```sql
CHECK
(
Age>=18
)
```

---

Salary

Positive

```sql
CHECK
(
Salary>0
)
```

---

Order Status

```sql
CHECK
(
Status IN
(
'Pending',

'Shipped',

'Delivered'
)
)
```

---

# 4. DEFAULT Constraint

Assigns default value.

```sql
CreatedDate DATETIME

DEFAULT GETDATE()
```

Insert

```sql
INSERT Customer(Name)

VALUES('Amit')
```

Automatically

```
CreatedDate

Today
```

---

# 5. PRIMARY KEY Constraint

Already discussed.

Ensures

Unique

Not Null

---

# 6. FOREIGN KEY Constraint

Already discussed.

Ensures

Relationship.

---

# Complete Example

```sql
CREATE TABLE Customer
(
    CustomerId INT IDENTITY(1,1),

    Name VARCHAR(100) NOT NULL,

    Email VARCHAR(100) UNIQUE,

    Age INT CHECK(Age>=18),

    CreatedDate DATETIME
    DEFAULT GETDATE(),

    PRIMARY KEY(CustomerId)
);
```

---

# Internal Working

```mermaid
flowchart LR

A[Insert Request]

-->B[Check NOT NULL]

-->C[Check UNIQUE]

-->D[Check CHECK Constraint]

-->E[Check FK]

-->F[Insert Row]
```

Every insert/update passes through these validations.

If any validation fails, SQL Server rejects the operation.

---

# Real-World Examples

## Banking

| Column | Constraint |
|---------|------------|
| AccountNumber | Primary Key |
| CustomerId | Foreign Key |
| Balance | CHECK (Balance >= 0) |
| Email | UNIQUE |
| Name | NOT NULL |

---

## E-Commerce

Order

```
OrderId

PK
```

CustomerId

```
FK
```

Order Status

```
CHECK
```

CreatedDate

```
DEFAULT
```

---

## Healthcare

Patient

```
PatientId

PK
```

DoctorId

```
FK
```

BloodGroup

```
CHECK
```

Email

```
UNIQUE
```

---

# Performance Considerations

| Key / Constraint | Performance Impact |
|------------------|--------------------|
| Primary Key | Fast lookups due to index |
| Foreign Key | Slight overhead on inserts/updates, faster joins when indexed |
| Unique | Requires uniqueness checks on writes |
| Check | Minimal validation cost |
| Not Null | Negligible overhead |
| Default | Very low overhead |

---

# Best Practices

## Primary Keys

- Prefer surrogate integer keys (`IDENTITY` or `SEQUENCE`) for internal relationships.
- Keep them stable; never use values that can change.

---

## Foreign Keys

- Always create indexes on foreign key columns if they are frequently joined.
- Enforce referential integrity unless there is a very specific reason not to.

---

## Unique Constraints

- Use them for business identifiers like Email, PAN, Aadhaar, or Username.

---

## Check Constraints

- Push simple business validation into the database.
- Example: `Price > 0`, `Quantity >= 0`.

---

## Default Constraints

- Use for audit fields such as `CreatedDate`, `IsActive`, or `CreatedBy` (when appropriate).

---

# Common Mistakes

❌ Using Email as Primary Key

Email can change.

---

❌ Forgetting Foreign Keys

Leads to orphan records.

---

❌ No Unique Constraint on Email

Allows duplicate accounts.

---

❌ Storing Negative Quantity

Missing CHECK constraint.

---

❌ Using Composite Primary Keys Everywhere

Can complicate joins and foreign key references. Use them when they naturally model the domain (e.g., bridge tables).

---

# Debugging Constraint Issues

Common SQL Server errors:

```text
Violation of PRIMARY KEY constraint
```

Duplicate primary key value.

---

```text
Violation of UNIQUE KEY constraint
```

Duplicate unique value.

---

```text
The INSERT statement conflicted with the FOREIGN KEY constraint
```

Referenced parent row does not exist.

---

```text
The CHECK constraint was violated
```

Data does not satisfy the validation rule.

---

# Easy Analogy

Imagine a **university**:

- **Primary Key** → Student Roll Number (unique identity).
- **Foreign Key** → Department ID on the student record (links student to a department).
- **Unique Constraint** → Student Email (no two students share the same email).
- **NOT NULL** → Student Name (every student must have a name).
- **CHECK Constraint** → Age must be at least 16.
- **DEFAULT Constraint** → Admission Date defaults to today's date if not supplied.

---

# Comparison Table

| Feature | Primary Key | Foreign Key | Unique | Check | Not Null | Default |
|----------|-------------|-------------|---------|--------|-----------|----------|
| Uniqueness | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Allows NULL | ❌ | ✅ (unless NOT NULL) | One NULL (SQL Server) | Depends | ❌ | ✅ |
| Links Tables | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Validates Business Rules | ❌ | Partially | ❌ | ✅ | ✅ | Provides default |
| Auto Index | ✅ | ❌ (manual index recommended) | ✅ | ❌ | ❌ | ❌ |

---

# Interview Questions

## Beginner (5)

1. What is a Primary Key?
2. What is a Foreign Key?
3. What is the difference between Primary Key and Unique Key?
4. Why do we use NOT NULL?
5. What is a CHECK constraint?

---

## Intermediate (5)

1. What is the difference between Candidate Key and Alternate Key?
2. When would you use a Composite Key?
3. Why should Foreign Keys be indexed?
4. What is a Surrogate Key, and why is it preferred?
5. How does SQL Server enforce referential integrity?

---

## Senior (10)

1. Should every table have a surrogate key? Why or why not?
2. When would you intentionally avoid a foreign key?
3. How do unique constraints affect insert performance?
4. How do clustered and non-clustered indexes interact with primary keys?
5. How would you design keys for a distributed system?
6. What problems arise from using business keys as primary keys?
7. How do cascading deletes work with foreign keys?
8. How would you enforce complex business rules that CHECK constraints cannot express?
9. How do keys impact partitioning strategies?
10. How do you migrate a production table's primary key safely?

---

# Interview Questions (10+ Years Experience)

## 1. Why do most enterprise systems prefer surrogate keys over natural keys?

**Why Interviewers Ask**

To assess your understanding of long-term schema stability.

**Expected Answer**

Surrogate keys are immutable, compact, and efficient for indexing. Business identifiers (email, PAN, account number) may change over time.

**Production Example**

UBS stores an internal `CustomerId` as the primary key, while account numbers and customer identifiers are business attributes that may change or be replaced.

---

## 2. Why doesn't SQL Server automatically create indexes for foreign keys?

**Expected Answer**

Because not every foreign key is queried frequently. Automatic indexing would increase storage and write costs. Developers should create indexes based on query patterns.

---

## 3. What happens internally during a foreign key insert?

SQL Server:

1. Reads the parent index.
2. Verifies the referenced row exists.
3. Applies locks as needed.
4. Inserts the child row if validation succeeds.

---

## 4. When should you use a composite primary key?

Ideal for bridge tables like:

```text
StudentCourse
--------------
StudentId
CourseId
```

The combination is naturally unique.

---

## 5. Why are CHECK constraints preferable to application-only validation?

Because the database becomes the final line of defense. Even if another application writes directly to the database, invalid data is still rejected.

---

## Key Takeaways

- **Primary Key** uniquely identifies a row.
- **Foreign Key** creates relationships between tables.
- **Candidate Keys** are all possible unique identifiers.
- **Alternate Keys** are candidate keys not chosen as the primary key.
- **Composite Keys** use multiple columns to form a unique identifier.
- **Super Keys** uniquely identify rows but may include unnecessary columns.
- **Unique Constraints** enforce uniqueness without being the primary key.
- **Surrogate Keys** are artificial, stable identifiers preferred in enterprise systems.
- Constraints protect your data from becoming inconsistent and should be viewed as an essential part of your application's business rules—not just database features.
