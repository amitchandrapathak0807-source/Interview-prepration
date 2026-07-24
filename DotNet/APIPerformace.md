# Index Seek vs Index Scan (SQL Server Interview)

One of the most common SQL Server interview questions is:

> **What is the difference between an Index Seek and an Index Scan?**

The key difference is **how much of the index SQL Server reads**.

- **Index Seek** → Reads only the required rows.
- **Index Scan** → Reads the entire index (or a large portion of it).

Think of it like searching for a word in a dictionary.

- **Index Seek** = Open directly to the page containing the word.
- **Index Scan** = Start from page 1 and read every page until you find it.

---

# Example Table

Suppose we have an `Employee` table with **1 million rows**.

```sql
CREATE TABLE Employee
(
    EmployeeId INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(200),
    Salary DECIMAL(10,2)
);
```

Create an index:

```sql
CREATE INDEX IX_Email
ON Employee(Email);
```

---

# 1. Index Seek

Query:

```sql
SELECT *
FROM Employee
WHERE Email = 'john@gmail.com';
```

### Execution

```
Index

A
B
C
D
...
J  <-- SQL Server jumps directly here
...
Z
```

SQL Server knows exactly where the value exists.

Execution Plan

```
Index Seek
```

Rows Read

```
1
```

Performance

```
Very Fast
```

Time

```
2-5 ms
```

---

# Why?

The index is sorted.

Example:

```
abc@gmail.com
adam@gmail.com
amit@gmail.com
john@gmail.com
mary@gmail.com
```

SQL Server performs something similar to a binary search and jumps directly to the matching entry.

Complexity

```
O(log n)
```

---

# 2. Index Scan

Query

```sql
SELECT *
FROM Employee
WHERE Salary > 50000;
```

Suppose there is **no index on Salary**.

Execution

```
Row 1
Row 2
Row 3
Row 4
...
Row 1,000,000
```

Execution Plan

```
Index Scan
```

Rows Read

```
1,000,000
```

Performance

```
Slower
```

Time

```
800 ms
```

---

# Another Example

Suppose Email has an index.

Query:

```sql
SELECT *
FROM Employee
WHERE Email LIKE '%gmail.com';
```

Execution Plan

```
Index Scan
```

Why?

The wildcard at the beginning (`%gmail.com`) prevents SQL Server from locating a starting point in the index.

It must inspect every index entry.

---

# Index Seek Example

```sql
SELECT *
FROM Employee
WHERE Email LIKE 'john%';
```

Execution Plan

```
Index Seek
```

Because SQL Server can directly seek to the first value beginning with `john`.

---

# Visual Comparison

## Index Seek

```
Index

A
B
C
D
E
F
G
H
I
J  <-- Jump directly
K
L
```

Only a few pages are read.

---

## Index Scan

```
Index

A
B
C
D
E
F
G
H
I
J
K
L
```

Every page is read.

---

# Real-Life Analogy

## Index Seek

Searching a phone contact:

```
John Smith
```

You type:

```
John
```

Phone jumps directly.

Time:

```
1 second
```

---

## Index Scan

You only remember:

```
Ends with Smith
```

Now you manually check every contact.

Time:

```
Much Longer
```

---

# When Does SQL Server Choose an Index Scan?

- No suitable index exists.
- A function is applied to the indexed column.
- Leading wildcard (`LIKE '%abc'`).
- Implicit data type conversion.
- The query returns a very large percentage of the table (e.g., 80–90%). In such cases, scanning can be cheaper than seeking many rows.

Example:

```sql
SELECT *
FROM Employee
WHERE Salary > 0;
```

If nearly every row qualifies, SQL Server may choose an **Index Scan** because reading the entire index sequentially is more efficient than many random lookups.

---

# How to Convert a Scan into a Seek

### ❌ Function on Indexed Column

```sql
WHERE YEAR(HireDate) = 2025;
```

✅ Rewrite:

```sql
WHERE HireDate >= '2025-01-01'
AND HireDate < '2026-01-01';
```

---

### ❌ Leading Wildcard

```sql
WHERE Name LIKE '%John';
```

✅ Rewrite:

```sql
WHERE Name LIKE 'John%';
```

---

### ❌ Missing Index

```sql
WHERE Email = 'abc@gmail.com';
```

Create an index:

```sql
CREATE INDEX IX_Email
ON Employee(Email);
```

---

### ❌ Implicit Conversion

```sql
WHERE EmployeeId = '100';
```

✅ Rewrite:

```sql
WHERE EmployeeId = 100;
```

---

# Index Seek vs Index Scan

| Feature | Index Seek | Index Scan |
|---------|------------|------------|
| Reads | Only matching rows | Entire index (or a large range) |
| Speed | Fast | Slower |
| I/O | Low | High |
| CPU | Low | Higher |
| Uses Index Efficiently | ✅ Yes | ⚠️ Not fully |
| Typical Complexity | O(log n) | O(n) |
| Preferred? | ✅ Yes (when selective) | ⚠️ Sometimes necessary |

---

# Important Interview Point

> **Is an Index Scan always bad?**

**No.**

An Index Scan can be the best choice when:

- Most rows are needed (high selectivity).
- The table is small.
- No selective predicate exists.
- A sequential scan is cheaper than many random index lookups.

The optimizer chooses the plan with the **lowest estimated cost**, so an Index Scan is not inherently a problem.

---

# Interview Answer (1 Minute)

> **"An Index Seek means SQL Server uses the index to navigate directly to the required rows, similar to finding a word in a dictionary. It reads only the relevant pages, resulting in low I/O and excellent performance. An Index Scan, on the other hand, reads the entire index or a large portion of it because it cannot efficiently locate the starting point or because scanning is estimated to be cheaper. Scans commonly occur due to missing indexes, non-SARGable predicates like `YEAR(DateColumn)`, leading wildcards such as `LIKE '%abc'`, implicit conversions, or queries that return a large percentage of the table. While seeks are generally preferred for selective queries, scans are not always bad—they can be the optimal plan depending on the data and query."**
