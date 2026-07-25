# SQL Server Stored Procedure Explained
## Complete Guide (Beginner → Architect | 10+ Years Experience)

> **Interview Level:** ⭐⭐⭐⭐⭐
>
> Stored Procedures are one of the most frequently asked SQL Server interview topics.
>
> Companies like:
>
> - Microsoft
> - Amazon
> - UBS
> - JP Morgan
> - Goldman Sachs
> - Point72
>
> expect you to know **not just what a Stored Procedure is, but why it exists, how it works internally, and when to use it.**

---

# Table of Contents

1. Goal
2. Problem
3. What is a Stored Procedure?
4. Why Do We Need It?
5. Internal Working
6. Life Cycle
7. Parameters
8. Output Parameters
9. Transactions
10. Error Handling
11. Execution Plan
12. Performance
13. Best Practices
14. Common Mistakes
15. Interview Questions

---

# Goal

Let's first understand **why Stored Procedures were introduced**.

Imagine you're building a Banking Application.

Customer clicks

```
Transfer Money
```

What happens?

Application needs to:

1. Check Sender Account
2. Check Balance
3. Deduct Amount
4. Credit Receiver
5. Insert Transaction History
6. Commit Transaction

---

# Without Stored Procedure

Your C# code may execute multiple SQL statements.

```sql
SELECT Balance
FROM Account
WHERE Id = 1;

UPDATE Account
SET Balance = Balance - 1000
WHERE Id = 1;

UPDATE Account
SET Balance = Balance + 1000
WHERE Id = 2;

INSERT INTO Transactions(...);
```

---

# Problems

- Multiple database calls
- More network latency
- Business logic duplicated
- Hard to maintain
- Risk of inconsistent updates

---

# Solution

Move database-related logic into a Stored Procedure.

Now C# executes only:

```sql
EXEC TransferMoney
```

Everything happens inside SQL Server.

---

# What is a Stored Procedure?

## Definition

A Stored Procedure is a **precompiled collection of SQL statements** stored inside the database.

It can contain:

- SELECT
- INSERT
- UPDATE
- DELETE
- IF
- WHILE
- TRY...CATCH
- Transactions
- Variables

Think of it as a SQL function that performs one business operation.

---

# Real-World Analogy

Imagine a coffee machine.

Without it:

You manually:

- Boil water
- Add coffee
- Add milk
- Add sugar

With a coffee machine:

Press one button.

Everything happens automatically.

Stored Procedure works similarly.

---

# Example

Instead of writing

```sql
SELECT *
FROM Customer
WHERE CustomerId = 10;
```

again and again,

Create

```sql
CREATE PROCEDURE GetCustomer
    @CustomerId INT
AS
BEGIN
    SELECT *
    FROM Customer
    WHERE CustomerId = @CustomerId;
END;
```

Execute

```sql
EXEC GetCustomer 10;
```

---

# Internal Working

Suppose

Application executes

```sql
EXEC GetCustomer 10;
```

Internally

```text
Application

↓

SQL Server

↓

Find Stored Procedure

↓

Check Permissions

↓

Compile (if needed)

↓

Execution Plan

↓

Read Data

↓

Return Result
```

---

# Where is it Stored?

Inside SQL Server Database.

```
Database

│

├── Tables

├── Views

├── Stored Procedures

├── Functions

└── Triggers
```

---

# What Happens the First Time?

Suppose

```sql
EXEC GetCustomer 10;
```

SQL Server

1. Parses SQL.
2. Validates syntax.
3. Optimizes query.
4. Creates Execution Plan.
5. Stores plan in Plan Cache.
6. Executes query.

---

# What Happens the Second Time?

Same procedure called again.

```sql
EXEC GetCustomer 20;
```

SQL Server

doesn't create a new execution plan.

Instead

```text
Execution Plan Cache

↓

Reuse Existing Plan

↓

Execute
```

This reduces CPU usage.

---

# Execution Plan

Example

```sql
SELECT *
FROM Customer
WHERE CustomerId = @CustomerId;
```

Optimizer checks

```
Should I

Use Index?

Or

Table Scan?
```

Suppose

CustomerId

is Primary Key.

Execution Plan

```
Index Seek
```

Fast.

---

# Parameters

Stored Procedures support input parameters.

Example

```sql
CREATE PROCEDURE GetAccount
    @AccountId INT
AS
BEGIN
    SELECT *
    FROM Account
    WHERE AccountId = @AccountId;
END;
```

Execute

```sql
EXEC GetAccount 1001;
```

---

# Multiple Parameters

```sql
CREATE PROCEDURE GetCustomer

    @City NVARCHAR(50),

    @Status BIT

AS
BEGIN
    SELECT *
    FROM Customer
    WHERE City = @City
      AND IsActive = @Status;
END;
```

---

# Output Parameters

Example

```sql
CREATE PROCEDURE GetBalance

    @AccountId INT,

    @Balance DECIMAL(18,2) OUTPUT

AS
BEGIN
    SELECT @Balance = Balance
    FROM Account
    WHERE AccountId = @AccountId;
END;
```

Execute

```sql
DECLARE @Amount DECIMAL(18,2);

EXEC GetBalance
    1001,
    @Amount OUTPUT;

SELECT @Amount;
```

---

# Transactions

Very common in Banking.

```sql
BEGIN TRANSACTION;

UPDATE Account
SET Balance = Balance - 1000
WHERE Id = 1;

UPDATE Account
SET Balance = Balance + 1000
WHERE Id = 2;

COMMIT;
```

If something fails

```sql
ROLLBACK;
```

---

# TRY...CATCH

```sql
BEGIN TRY

    BEGIN TRANSACTION;

    -- SQL Statements

    COMMIT;

END TRY

BEGIN CATCH

    ROLLBACK;

    THROW;

END CATCH;
```

This ensures the database remains consistent.

---

# Banking Example

Transfer ₹1000

```text
Check Balance

↓

Debit Sender

↓

Credit Receiver

↓

Insert Transaction

↓

Commit
```

Everything succeeds,

or everything rolls back.

---

# Stored Procedure Life Cycle

```text
Developer Creates Procedure

↓

Stored in SQL Server

↓

Application Executes

↓

Execution Plan Generated

↓

Plan Cached

↓

Result Returned

↓

Plan Reused
```

---

# Performance

## Advantages

### Less Network Calls

Instead of sending

5 SQL statements,

send

```
EXEC TransferMoney
```

---

### Plan Reuse

Execution plan

is reused,

saving CPU.

---

### Better Security

Users can execute procedures

without direct access

to underlying tables.

Grant

```sql
EXECUTE
```

instead of

```sql
SELECT
```

---

### Centralized Logic

Business rules

remain in one place.

---

# Disadvantages

- Business logic split between C# and SQL.
- Harder to version control.
- Debugging is more difficult.
- Database vendor-specific.
- Large procedures become difficult to maintain.

---

# Execution Plan Cache

```text
EXEC GetCustomer

↓

Plan Cache

↓

Exists?

↓

Yes

↓

Reuse

↓

Execute
```

No recompilation.

---

# Parameter Sniffing

One of the most popular senior interview questions.

Suppose

First execution

```sql
EXEC GetOrders 'Mumbai';
```

Optimizer creates

Execution Plan

based on

Mumbai.

Later

```sql
EXEC GetOrders 'SmallVillage';
```

SQL Server

may reuse

the same execution plan,

even though a different plan would be better.

This is called

```
Parameter Sniffing
```

Possible solutions

- `OPTION (RECOMPILE)`
- `OPTIMIZE FOR`
- Local variables
- Query tuning

---

# Dynamic SQL

Example

```sql
DECLARE @Sql NVARCHAR(MAX);

SET @Sql =
'SELECT *
 FROM Customer
 WHERE City = @City';

EXEC sp_executesql
    @Sql,
    N'@City NVARCHAR(50)',
    @City='Pune';
```

Always use parameterized dynamic SQL.

Never concatenate user input.

---

# SQL Injection Protection

❌ Wrong

```sql
SET @Sql =
'SELECT * FROM Customer WHERE Name=''' + @Name + '''';
```

Allows SQL Injection.

---

✅ Correct

Use

```sql
sp_executesql
```

with parameters.

---

# Stored Procedure vs Query

| Query | Stored Procedure |
|---------|-----------------|
| Written every time | Stored once |
| More network calls | One call |
| No plan reuse guarantee | Better plan reuse |
| Hard to maintain | Centralized |
| Less secure | More secure |

---

# Stored Procedure vs Function

| Stored Procedure | Function |
|------------------|----------|
| Can modify data | Usually should not modify data |
| Can return multiple result sets | Returns a value or table |
| Supports transactions | Cannot manage transactions like procedures |
| Called using EXEC | Used in SQL expressions |

---

# Stored Procedure vs View

| Stored Procedure | View |
|------------------|------|
| Accepts parameters | No parameters (SQL Server) |
| Business logic | Virtual table |
| INSERT/UPDATE/DELETE | Mostly SELECT |
| EXEC | SELECT |

---

# Best Practices

- Keep procedures focused on one business operation.
- Use `SET NOCOUNT ON`.
- Use parameters instead of string concatenation.
- Wrap write operations in transactions.
- Use `TRY...CATCH`.
- Avoid returning unnecessary columns.
- Create proper indexes.
- Review execution plans regularly.
- Log failures for troubleshooting.

---

# Common Mistakes

### ❌ Returning `SELECT *`

Always return only required columns.

---

### ❌ Long Stored Procedures

A 3000-line procedure is difficult to maintain.

Break large operations into smaller procedures where appropriate.

---

### ❌ Ignoring Execution Plan

Never assume a procedure is fast.

Always inspect

- Actual Execution Plan
- `SET STATISTICS IO ON`
- `SET STATISTICS TIME ON`

---

### ❌ No Error Handling

Always use

```sql
TRY...CATCH
```

---

### ❌ Building SQL Using String Concatenation

Risk of SQL Injection.

---

# How to Debug a Slow Stored Procedure

## Step 1

Enable

```sql
SET STATISTICS IO ON;

SET STATISTICS TIME ON;
```

---

## Step 2

View

Actual Execution Plan

Look for

- Table Scan
- Index Scan
- Key Lookup
- Sort
- Hash Match
- Missing Index

---

## Step 3

Check blocking

```sql
sp_who2
```

or

Dynamic Management Views (DMVs).

---

## Step 4

Check parameter sniffing.

---

## Step 5

Review indexes.

---

# Real Production Example (UBS)

Money Transfer

```text
API

↓

EXEC TransferMoney

↓

Validate Account

↓

Check Balance

↓

Debit Sender

↓

Credit Receiver

↓

Insert Audit

↓

Commit

↓

Return Success
```

One database call.

One transaction.

Consistent data.

---

# Interview Questions

## Beginner

### What is a Stored Procedure?

A precompiled collection of SQL statements stored inside the database.

---

### Why use Stored Procedures?

- Reduce network calls.
- Reuse SQL logic.
- Improve security.
- Centralize business logic.

---

### Can Stored Procedures accept parameters?

Yes.

Input and output parameters.

---

# Intermediate

### Difference between Stored Procedure and Function?

Procedures perform operations and can modify data.

Functions return a value or table and are intended for use in SQL expressions.

---

### What is an Execution Plan?

A strategy generated by SQL Server showing how it will retrieve or modify data efficiently.

---

### What is Parameter Sniffing?

SQL Server reuses an execution plan generated from an earlier parameter value, which may not be optimal for different parameter values.

---

# Senior (10+ Years)

### Why are Stored Procedures faster?

**Expected Answer**

Not because they are "precompiled" forever, but because SQL Server caches and reuses execution plans when appropriate, reducing compilation overhead. They also reduce network round trips and centralize database operations.

---

### Should all business logic be placed inside Stored Procedures?

No.

Business rules that belong to the application domain should remain in the application. Stored Procedures are best suited for data-intensive operations, complex reporting, bulk processing, and transactional database logic.

---

### When would you avoid Stored Procedures?

- Applications requiring database portability.
- Simple CRUD APIs using EF Core.
- Systems where business logic should stay in the application layer.

---

### When would you definitely use Stored Procedures?

- Complex financial transactions.
- Bulk imports/exports.
- Reporting queries.
- Batch processing.
- High-performance database operations.
- Legacy enterprise systems.

---

# One-Line Interview Answer

> **A Stored Procedure is a reusable, parameterized collection of SQL statements stored in SQL Server. It executes on the database server, supports transactions and error handling, reduces network round trips, enables execution plan reuse, improves security through controlled access, and is commonly used for complex transactional and data-intensive operations.**