# SQL Views and Materialized Views Explained
## Complete Guide (Beginner → Architect | 10+ Years Experience)

> **Interview Level:** ⭐⭐⭐⭐⭐
>
> Views and Materialized Views are among the most frequently asked SQL interview topics.
>
> Interviewers don't just ask:
>
> - What is a View?
>
> They ask:
>
> - Why do Views exist?
> - Why not query tables directly?
> - What is the difference between View and Materialized View?
> - When should you use them?
> - What happens internally?
> - How do they affect performance?

---

# Table of Contents

1. Goal
2. Problem
3. What is a View?
4. Internal Working
5. Types of Views
6. Advantages
7. Disadvantages
8. What is a Materialized View?
9. Internal Working
10. View vs Materialized View
11. Real-world Examples
12. Performance
13. Best Practices
14. Common Mistakes
15. Interview Questions

---

# Goal

Let's first understand why Views were invented.

Suppose you're building an Internet Banking application.

Database Tables

```
Customer

Account

Transaction

Loan

Card
```

Now the business wants:

Customer Dashboard

Showing

```
Customer Name

Account Number

Current Balance

Last Transaction

Branch Name
```

Data comes from multiple tables.

---

# Traditional Query

Every developer writes

```sql
SELECT
    c.Name,
    a.AccountNumber,
    a.Balance,
    t.Amount,
    b.BranchName
FROM Customer c
JOIN Account a
    ON c.CustomerId = a.CustomerId
JOIN Transactions t
    ON a.AccountId = t.AccountId
JOIN Branch b
    ON a.BranchId = b.BranchId;
```

---

# Problem

Imagine

100 developers.

Every developer writes

this JOIN.

Problems

- Duplicate SQL
- Hard to maintain
- High chance of mistakes
- Security issues
- Difficult to change

---

# Solution

Create

```
View
```

Now developers simply query

```sql
SELECT *

FROM CustomerDashboard;
```

Simple.

---

# What is a View?

## Definition

A View is a **virtual table**.

It **does not store data**.

It only stores

```
SQL Query
```

Whenever someone queries the View,

SQL Server executes the stored SQL.

---

# Think of View Like This

Imagine

```
Excel

↓

Filter

↓

Filtered Sheet
```

The filtered sheet

doesn't duplicate data.

It simply shows

filtered results.

View works similarly.

---

# Example

Tables

Customer

| Id | Name |
|----|------|
| 1 | Amit |

Account

| Id | CustomerId | Balance |
|----|------------|---------|
| 1 | 1 | 50000 |

---

View

```sql
CREATE VIEW CustomerBalance
AS
SELECT
    c.Name,
    a.Balance
FROM Customer c
JOIN Account a
ON c.Id = a.CustomerId;
```

---

Query

```sql
SELECT *

FROM CustomerBalance;
```

Output

| Name | Balance |
|------|----------|
| Amit | 50000 |

---

# Internal Working

Suppose

You execute

```sql
SELECT *

FROM CustomerBalance;
```

Internally

SQL Server performs

```text
View

↓

Reads Stored SQL

↓

Expands Query

↓

Executes Original SQL

↓

Returns Result
```

Notice

View

contains

NO DATA.

Only SQL.

---

# Internal Flow

```text
Application

↓

SELECT *

FROM CustomerBalance

↓

SQL Server

↓

Retrieve View Definition

↓

Execute Underlying SQL

↓

Join Tables

↓

Return Result
```

---

# Proof

Suppose

Customer

changes

```
Amit

↓

Amit Sharma
```

Immediately

```sql
SELECT *

FROM CustomerBalance
```

Returns

```
Amit Sharma
```

Why?

Because

View executes

every time.

---

# Can We Insert Into a View?

Sometimes

YES.

If

View

uses

```
Single Table
```

Example

```sql
CREATE VIEW ActiveCustomers

AS

SELECT *

FROM Customer

WHERE Active=1;
```

Possible

```sql
INSERT

UPDATE
```

---

But

If

View

contains

```
JOIN

GROUP BY

DISTINCT

UNION
```

Usually

Not updatable.

---

# Types of Views

## 1. Simple View

Single Table.

```sql
CREATE VIEW ActiveCustomers

AS

SELECT *

FROM Customer

WHERE Active=1;
```

---

## 2. Complex View

Multiple Tables.

```sql
Customer

JOIN

Account

JOIN

Branch
```

---

# Advantages of Views

- Hide complex SQL.
- Reuse logic.
- Improve security.
- Simplify reporting.
- Consistent queries.

---

# Disadvantages

- Doesn't improve performance.
- Complex Views may become slow.
- Every query executes underlying SQL.

---

# Performance

Important Interview Point

Many people think

Views

store data.

Wrong.

Every execution

```
Runs SQL Again.
```

If SQL

takes

10 seconds,

View

also takes

10 seconds.

---

# Then Why Materialized View?

Imagine

Monthly Sales Report.

Query

takes

```
45 seconds.
```

CEO opens dashboard.

Waits

45 seconds.

Bad experience.

Need faster solution.

---

# What is Materialized View?

## Definition

Materialized View stores

```
Query

+

Result
```

Unlike a normal View,

it physically stores the data.

---

# Think Like This

Normal View

```
Recipe
```

Materialized View

```
Cooked Food
```

Recipe

You cook

every time.

Materialized View

Food already prepared.

Just serve.

---

# Internal Working

First Time

```sql
CREATE MATERIALIZED VIEW
```

Database executes

```
SQL

↓

Stores Result

↓

Disk
```

Now

Query

```sql
SELECT *

FROM MonthlySales
```

No JOIN.

No Aggregation.

Reads

precomputed data.

Very fast.

---

# Example

Orders

```
10 Million Rows
```

Monthly Report

```sql
SELECT

SUM(Amount)

GROUP BY Month
```

Without Materialized View

Every request

scans

10 Million rows.

---

With Materialized View

Already

stored.

```
January

₹25,00,00,000

February

₹28,00,00,000
```

Query becomes instant.

---

# Internal Flow

```text
Application

↓

Materialized View

↓

Stored Data

↓

Return Result
```

No expensive recalculation.

---

# But There is a Problem

Suppose

New Order

arrives.

Materialized View

still has

old data.

Need

```
Refresh
```

---

# Refresh Types

## Complete Refresh

Delete everything.

Recalculate everything.

Slow.

---

## Incremental Refresh

Only

new changes.

Fast.

---

# SQL Server Note

SQL Server **does not have true Materialized Views** like Oracle or PostgreSQL.

Instead,

SQL Server provides

```
Indexed Views
```

An Indexed View stores the result physically using a **clustered index**, making it similar to a materialized view.

Example

```sql
CREATE VIEW dbo.TotalSales
WITH SCHEMABINDING
AS
SELECT
    CustomerId,
    COUNT_BIG(*) AS TotalOrders,
    SUM(Amount) AS TotalAmount
FROM dbo.Orders
GROUP BY CustomerId;
GO

CREATE UNIQUE CLUSTERED INDEX IX_TotalSales
ON dbo.TotalSales(CustomerId);
```

---

# View vs Materialized View

| Feature | View | Materialized View / Indexed View |
|----------|------|----------------------------------|
| Stores Data | ❌ No | ✅ Yes |
| Stores Query | ✅ Yes | ✅ Yes |
| Always Latest | ✅ Yes | Depends on Refresh/Maintenance |
| Performance | Slower | Faster |
| Storage | No | Yes |
| Best For | OLTP | Reporting/Analytics |

---

# Banking Example

Dashboard

Needs

```
Balance

Loan

Cards

Last Transaction
```

Use

```
View
```

Reason

Must always show

latest data.

---

# E-commerce Example

Monthly Sales Report

Need

```
Last 5 Years

Grouped Data
```

Use

```
Materialized View

(or Indexed View in SQL Server)
```

Reason

Expensive aggregation.

---

# Uber Example

Live Ride Status

```
Current Driver

Current Location
```

Use

View

Need real-time data.

---

Ride Analytics

```
Total Rides

Per City

Last Month
```

Materialized View

Fast reporting.

---

# Healthcare Example

Patient Details

Real-time.

Use

View.

Hospital Dashboard

```
Monthly Admissions

Revenue

Doctor Performance
```

Materialized View.

---

# Performance Comparison

| Operation | View | Materialized View |
|------------|------|------------------|
| SELECT | Slower | Faster |
| INSERT | Fast | Slower (maintains stored result) |
| UPDATE | Fast | Slower |
| DELETE | Fast | Slower |
| Storage | None | Extra Storage |

---

# Best Practices

## Use View When

- Need latest data.
- Simplify joins.
- Hide complexity.
- Restrict columns.
- Improve security.

---

## Use Materialized/Indexed View When

- Heavy aggregations.
- Reporting.
- BI dashboards.
- Expensive joins.
- Data changes less frequently than it is read.

---

# Common Mistakes

❌ Thinking Views improve performance.

They don't.

They execute the underlying query every time.

---

❌ Using Views everywhere.

Sometimes

stored procedures

or

direct SQL

are better.

---

❌ Using Materialized Views for frequently changing transactional tables.

Maintenance cost becomes high.

---

# Debugging Slow Views

Check

```
Execution Plan
```

Look for

- Table Scan
- Index Scan
- Hash Match
- Sort
- Missing Index

Use

```sql
SET STATISTICS IO ON;

SET STATISTICS TIME ON;
```

---

# Interview Questions

## Beginner

### What is a View?

A virtual table that stores a SQL query but not the actual data.

---

### Does a View store data?

No.

It stores only the query definition.

---

### Why use Views?

To simplify queries, reuse logic, and improve security.

---

# Intermediate

### Difference between View and Table?

Table stores data.

View stores SQL.

---

### Can we update a View?

Simple Views usually can be updated.

Complex Views involving joins or aggregations are generally not directly updatable.

---

### Do Views improve performance?

No.

They execute the underlying query every time.

---

# Senior (10+ Years)

### Why doesn't a View improve performance?

Because SQL Server expands the View definition into the original query during optimization. It still has to execute the joins, filters, and aggregations unless it's an Indexed View.

---

### When would you choose an Indexed View?

For frequently executed, expensive aggregations where the overhead of maintaining the indexed data is acceptable.

---

### Why aren't Materialized Views used for highly transactional systems?

Every insert, update, or delete may require maintaining the stored result, increasing write cost and reducing throughput.

---

# One-Line Interview Answer

> **A View is a virtual table that stores only a SQL query and always returns the latest data by executing that query. A Materialized View (or Indexed View in SQL Server) physically stores the query result, providing much faster reads at the cost of additional storage and maintenance during data changes.**