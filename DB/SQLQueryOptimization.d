# SQL Query Optimization Guide (SQL Server)

## 1. Check the Execution Plan (Most Important)

> Never optimize a query blindly. Always analyze how SQL Server executes it first.

### Enable Performance Statistics

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
```

Or press:

```
Ctrl + M
```

to enable the **Actual Execution Plan** in SQL Server Management Studio (SSMS).

### What to Look For

- Table Scan ❌
- Clustered Index Scan ⚠️
- Index Seek ✅
- Key Lookup ⚠️
- Sort ⚠️
- Hash Match ⚠️
- Nested Loop ✅
- Missing Index Recommendations

Example:

```
Table Scan
Cost = 92%
```

A **Table Scan** usually means SQL Server is reading every row in the table instead of using an index.

---

# 2. Use Proper Indexes

### Without Index

```sql
SELECT *
FROM Employee
WHERE Email = 'abc@gmail.com';
```

If `Email` is not indexed:

```
Employee Table
--------------
1
2
3
...
1,000,000
```

SQL Server must scan every row.

Execution Time:

```
2.5 seconds
```

### Create an Index

```sql
CREATE INDEX IX_Email
ON Employee(Email);
```

Now SQL Server performs an **Index Seek**.

Execution Time:

```
5 ms
```

**Performance Improvement:** ~500x faster

---

# 3. Avoid SELECT *

### Bad

```sql
SELECT *
FROM Employee;
```

### Problems

- Reads unnecessary columns
- Higher Disk I/O
- More Network Traffic
- Larger Memory Usage
- Prevents Covering Indexes

### Good

```sql
SELECT
    EmployeeId,
    Name,
    Salary
FROM Employee;
```

Only required columns are fetched.

---

# 4. Filter Early

### Bad

```sql
SELECT *
FROM Orders o
JOIN Customer c
ON o.CustomerId = c.Id;
```

The join processes every row.

### Good

```sql
SELECT *
FROM Orders o
JOIN Customer c
ON o.CustomerId = c.Id
WHERE o.OrderDate >= '2025-01-01';
```

Filtering first reduces rows participating in the join.

---

# 5. Avoid Functions on Indexed Columns (Make Queries SARGable)

### Bad

```sql
SELECT *
FROM Employee
WHERE YEAR(HireDate) = 2025;
```

Since SQL Server must calculate `YEAR()` for every row, it cannot use the index.

### Good

```sql
SELECT *
FROM Employee
WHERE HireDate >= '2025-01-01'
AND HireDate < '2026-01-01';
```

Now SQL Server performs an **Index Seek**.

---

# 6. Avoid Leading Wildcards

### Bad

```sql
WHERE Name LIKE '%John'
```

Cannot use an index.

### Good

```sql
WHERE Name LIKE 'John%'
```

Allows an **Index Seek**.

---

# 7. Use EXISTS Instead of IN (Large Data)

### Bad

```sql
SELECT *
FROM Employee
WHERE DepartmentId IN
(
    SELECT DepartmentId
    FROM Department
);
```

### Better

```sql
SELECT *
FROM Employee e
WHERE EXISTS
(
    SELECT 1
    FROM Department d
    WHERE d.DepartmentId = e.DepartmentId
);
```

**Why?**

- `EXISTS` stops after the first matching row.
- Often performs better on large datasets.

---

# 8. Avoid DISTINCT if Possible

### Bad

```sql
SELECT DISTINCT Name
FROM Employee;
```

### Why?

`DISTINCT` requires:

- Sorting
- Hashing

Both are expensive.

Instead, identify why duplicates are being produced.

---

# 9. Prefer JOINs Over Subqueries (When Appropriate)

### Bad

```sql
SELECT *
FROM Employee
WHERE DepartmentId IN
(
    SELECT Id
    FROM Department
);
```

### Good

```sql
SELECT e.*
FROM Employee e
INNER JOIN Department d
ON e.DepartmentId = d.Id;
```

The SQL Server optimizer can often optimize joins more effectively.

---

# 10. Avoid Cursors

### Bad

```
Cursor

Row 1
Row 2
Row 3
...
```

Processes one row at a time.

### Good

```sql
UPDATE Employee
SET Salary = Salary * 1.1
WHERE Department = 'IT';
```

Set-based operations are significantly faster.

---

# 11. Batch Large Updates

### Bad

```sql
UPDATE Orders
SET Status = 'Done';
```

This updates millions of rows in one transaction.

### Good

```sql
WHILE 1 = 1
BEGIN

    UPDATE TOP (1000)
    Orders
    SET Status = 'Done'
    WHERE Status = 'Pending';

    IF @@ROWCOUNT = 0
        BREAK;

END
```

### Benefits

- Less Locking
- Smaller Transaction Log
- Better Concurrency
- Reduced Blocking

---

# 12. Avoid Unnecessary ORDER BY

### Bad

```sql
SELECT *
FROM Employee
ORDER BY Name;
```

Sorting is expensive.

If ordering isn't required, remove it.

---

# 13. Prefer UNION ALL Over UNION

### UNION

```sql
SELECT Name FROM A

UNION

SELECT Name FROM B;
```

Removes duplicates.

Requires sorting or hashing.

### UNION ALL

```sql
SELECT Name FROM A

UNION ALL

SELECT Name FROM B;
```

No duplicate elimination.

Much faster.

---

# 14. Keep Statistics Updated

SQL Server uses statistics to estimate row counts.

Update statistics:

```sql
UPDATE STATISTICS Employee;
```

or

```sql
EXEC sp_updatestats;
```

Outdated statistics often produce poor execution plans.

---

# 15. Avoid Implicit Conversions

### Bad

```sql
WHERE EmployeeId = '100'
```

`EmployeeId` is an `INT`.

SQL Server performs an implicit conversion.

### Good

```sql
WHERE EmployeeId = 100
```

Now indexes can be used efficiently.

---

# 16. Choose Appropriate Data Types

### Bad

```sql
VARCHAR(MAX)
```

for

```
FirstName
```

### Better

```sql
VARCHAR(50)
```

Smaller rows mean:

- More rows per page
- Less disk I/O
- Better cache utilization

---

# 17. Use Covering Indexes

### Query

```sql
SELECT
    Name,
    Salary
FROM Employee
WHERE DepartmentId = 10;
```

### Covering Index

```sql
CREATE INDEX IX_Department
ON Employee(DepartmentId)
INCLUDE(Name, Salary);
```

Benefits:

- Eliminates Key Lookups
- Faster execution

---

# 18. Avoid OR When Possible

### Bad

```sql
WHERE City = 'Pune'
OR City = 'Mumbai';
```

Sometimes SQL Server chooses a table scan.

### Alternative

```sql
SELECT *
FROM Employee
WHERE City = 'Pune'

UNION ALL

SELECT *
FROM Employee
WHERE City = 'Mumbai';
```

Always compare execution plans to determine which approach performs better.

---

# 19. Join Smaller Result Sets First

Instead of joining:

```
1 Million Rows
JOIN
10 Million Rows
```

Filter first:

```
10,000 Rows
JOIN
20,000 Rows
```

Smaller joins require less CPU and memory.

---

# 20. Normalize and Denormalize Appropriately

Highly normalized databases can require many joins.

Example:

```
15 Table Join
```

Possible optimizations:

- Indexed Views
- Materialized Views
- Summary Tables
- Reporting Tables
- Denormalized Read Models

Use only when justified by performance requirements.

---

# Example Query Optimization

## Before

```sql
SELECT *
FROM Orders
WHERE YEAR(OrderDate) = 2025
AND CustomerName LIKE '%John%';
```

### Problems

- Uses `SELECT *`
- `YEAR()` prevents Index Seek
- Leading wildcard prevents Index Seek

---

## After

```sql
SELECT
    OrderId,
    CustomerName,
    Amount
FROM Orders
WHERE OrderDate >= '2025-01-01'
AND OrderDate < '2026-01-01'
AND CustomerName LIKE 'John%';
```

### Improvements

- Index Seek on `OrderDate`
- Index Seek on `CustomerName` (if indexed)
- Reduced Disk I/O
- Less Network Traffic
- Faster Execution

---

# Common Execution Plan Operators

| Operator | Meaning | Performance |
|----------|---------|-------------|
| Index Seek | Directly locates matching rows | ✅ Best |
| Index Scan | Reads the entire index | ⚠️ Depends on selectivity |
| Table Scan | Reads every row in the table | ❌ Usually avoid |
| Key Lookup | Retrieves additional columns from clustered index | ⚠️ Expensive for many rows |
| Hash Match | Used for joins/aggregations | ⚠️ CPU intensive |
| Nested Loop | Efficient for small outer datasets | ✅ Good |
| Merge Join | Efficient when inputs are sorted | ✅ Good |
| Sort | Explicit sorting operation | ⚠️ Expensive |

---

# Typical Interview Answer (2 Minutes)

> **"Whenever I optimize a SQL query, the first thing I do is examine the execution plan rather than making assumptions. I enable `SET STATISTICS IO ON` and `SET STATISTICS TIME ON` to understand logical reads and execution time. I then look for expensive operators like Table Scans, Key Lookups, Sorts, and Hash Matches.**
>
> **Next, I verify whether the query is SARGable by avoiding functions on indexed columns, leading wildcards, and implicit data type conversions. I ensure that appropriate indexes exist, including covering indexes when necessary, and avoid `SELECT *` to reduce I/O. I also filter data as early as possible, prefer `UNION ALL` over `UNION` when duplicate removal isn't needed, and keep table statistics updated so the optimizer can generate efficient execution plans.**
>
> **Finally, I compare the execution plans and performance metrics before and after each change. Query optimization should always be driven by measurable improvements rather than assumptions."**
