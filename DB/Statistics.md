# What do these SQL Server commands mean?

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
```

These commands tell **SQL Server** to display **performance statistics** after executing a query.

They are commonly used when optimizing slow SQL queries.

---

# 1. `SET STATISTICS IO ON`

## What does it do?

It shows **how much data SQL Server had to read from disk or memory** to execute your query.

Think of it as:

> **"How much work did SQL Server do to find my data?"**

After running your query, you'll see output like:

```text
Table 'Employee'.

Scan count 1,
logical reads 350,
physical reads 0,
read-ahead reads 20
```

---

## Meaning of each value

### Scan Count

```
Scan count = 1
```

How many times SQL Server searched the table or index.

Lower is generally better.

---

### Logical Reads ⭐ (Most Important)

```
Logical reads = 350
```

This tells you:

> SQL Server read **350 pages** from memory.

One SQL Server page = **8 KB**

So:

```
350 × 8 KB
= 2800 KB
≈ 2.8 MB read
```

The fewer logical reads, the faster your query is likely to be.

---

### Physical Reads

```
Physical reads = 0
```

This means SQL Server **did not need to read from disk**.

Instead, the data was already in memory (buffer cache).

If you see:

```
Physical reads = 50
```

SQL Server had to go to the hard disk, which is much slower.

---

### Read-ahead Reads

```
Read-ahead reads = 20
```

SQL Server predicted that it would soon need more pages and loaded them into memory in advance.

This is an optimization feature.

---

# Example

Suppose you execute:

```sql
SELECT *
FROM Employee
WHERE Department = 'IT';
```

Output:

```text
Table 'Employee'.

Scan count 1,
logical reads 200,
physical reads 0
```

Meaning:

- SQL Server searched the table once.
- It read 200 pages from memory.
- It didn't need to access the disk.
- The query is relatively efficient.

---

# 2. `SET STATISTICS TIME ON`

## What does it do?

It shows **how much CPU time and total elapsed time** SQL Server spent executing the query.

Example output:

```text
SQL Server Execution Times:

CPU time = 15 ms,
elapsed time = 22 ms.
```

---

## CPU Time

```
CPU time = 15 ms
```

The amount of time the CPU spent actually processing the query.

---

## Elapsed Time

```
Elapsed time = 22 ms
```

The total wall-clock time from start to finish.

This includes:

- CPU processing
- Waiting for disk
- Waiting for locks
- Waiting for network
- Other delays

---

# CPU Time vs Elapsed Time

Imagine ordering food at a restaurant.

```
Chef cooking
= CPU Time

Waiting for your order
= Elapsed Time
```

Example:

```
CPU Time = 5 ms

Elapsed Time = 100 ms
```

The CPU only worked for 5 ms, but the query spent 95 ms waiting (for disk, locks, etc.).

---

# Complete Example

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM Employee
WHERE Salary > 90000;
```

Output:

```text
Table 'Employee'.

Scan count 1
Logical reads 120
Physical reads 0

SQL Server Execution Times:

CPU time = 8 ms
Elapsed time = 11 ms
```

### Interpretation

- SQL Server scanned the table once.
- It read 120 pages from memory.
- No disk access was needed.
- CPU spent 8 ms processing.
- Total query completed in 11 ms.

This is a healthy, efficient query.

---

# Why are these commands important?

Whenever a query is slow, these commands help identify the bottleneck.

For example:

### Case 1: High Logical Reads

```text
Logical Reads = 50,000
```

Possible causes:

- Missing index
- Table scan
- Poor query design

---

### Case 2: High Physical Reads

```text
Physical Reads = 8,000
```

Possible causes:

- Data not in memory
- Disk I/O bottleneck

---

### Case 3: High CPU Time

```text
CPU Time = 2,500 ms
```

Possible causes:

- Expensive joins
- Complex calculations
- Large sort operations

---

### Case 4: High Elapsed Time but Low CPU Time

```text
CPU Time = 10 ms
Elapsed Time = 2,000 ms
```

Possible causes:

- Blocking
- Locks
- Waiting for disk
- Network delays

---

# Interview Question (10+ Years Experience)

**Q:** Which metric do you check first when optimizing a SQL Server query?

**Answer:**

The first thing to check is the **Actual Execution Plan**, followed by:

1. **Logical Reads** (`SET STATISTICS IO ON`) – to determine how much data SQL Server is reading.
2. **CPU Time** and **Elapsed Time** (`SET STATISTICS TIME ON`) – to understand processing time versus wait time.
3. **Execution Plan Operators** – look for:
   - Table Scan
   - Clustered Index Scan
   - Key Lookup
   - Sort
   - Hash Match
   - Missing Index warnings

In practice, **Logical Reads** are often the most useful indicator because reducing the amount of data SQL Server reads usually leads to better overall query performance.