# SQL Window Functions Explained

## Difference between `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`

| Function | Duplicate Rank | Gap in Ranking? |
|----------|----------------|-----------------|
| `ROW_NUMBER()` | ❌ No | ❌ No |
| `RANK()` | ✅ Yes | ✅ Yes |
| `DENSE_RANK()` | ✅ Yes | ❌ No |

---

# Sample Employee Table

| EmpId | Name | Department | Salary |
|------:|------|------------|-------:|
| 1 | Amit | IT | 100000 |
| 2 | Rahul | IT | 90000 |
| 3 | Priya | IT | 90000 |
| 4 | John | HR | 80000 |
| 5 | Alice | HR | 70000 |

---

# What is a Window Function?

A **Window Function** performs a calculation **for each row** while still returning **every row**.

> **Definition:**
>
> A Window Function calculates something for each row **without removing the row**.

Unlike `GROUP BY`, which combines rows into a single result, Window Functions keep every row visible.

---

# Example 1 - `ROW_NUMBER()`

## Requirement

Give every employee a **unique number** based on salary.

```sql
SELECT
    Name,
    Salary,
    ROW_NUMBER() OVER (ORDER BY Salary DESC) AS RowNum
FROM Employee;
```

### Output

| Name | Salary | RowNum |
|------|-------:|-------:|
| Amit | 100000 | 1 |
| Rahul | 90000 | 2 |
| Priya | 90000 | 3 |
| John | 80000 | 4 |
| Alice | 70000 | 5 |

### Explanation

Even though **Rahul** and **Priya** have the same salary, they receive different row numbers.

Think of it like assigning **roll numbers in a classroom**:

```
Amit   → Roll No. 1
Rahul  → Roll No. 2
Priya  → Roll No. 3
John   → Roll No. 4
Alice  → Roll No. 5
```

Every person gets a **unique number**.

---

# Example 2 - `RANK()`

## Requirement

Rank employees based on salary.

```sql
SELECT
    Name,
    Salary,
    RANK() OVER (ORDER BY Salary DESC) AS RankNo
FROM Employee;
```

### Output

| Name | Salary | Rank |
|------|-------:|-----:|
| Amit | 100000 | 1 |
| Rahul | 90000 | 2 |
| Priya | 90000 | 2 |
| John | 80000 | 4 |
| Alice | 70000 | 5 |

### Explanation

Rahul and Priya have the same salary, so they both receive **Rank 2**.

Notice that **Rank 3 is skipped**.

```
1
2
2
4
5
```

This is why `RANK()` creates gaps.

---

# Example 3 - `DENSE_RANK()`

## Requirement

Rank employees without leaving gaps.

```sql
SELECT
    Name,
    Salary,
    DENSE_RANK() OVER (ORDER BY Salary DESC) AS RankNo
FROM Employee;
```

### Output

| Name | Salary | Rank |
|------|-------:|-----:|
| Amit | 100000 | 1 |
| Rahul | 90000 | 2 |
| Priya | 90000 | 2 |
| John | 80000 | 3 |
| Alice | 70000 | 4 |

### Explanation

Rahul and Priya share Rank 2.

Unlike `RANK()`, the next rank is **3**, not 4.

```
1
2
2
3
4
```

No gaps are created.

---

# Comparison

## `ROW_NUMBER()`

```
1
2
3
4
5
```

Every row gets a unique number.

---

## `RANK()`

```
1
2
2
4
5
```

Duplicate values share the same rank, and the next rank is skipped.

---

## `DENSE_RANK()`

```
1
2
2
3
4
```

Duplicate values share the same rank, but no rank is skipped.

---

# Example 4 - `PARTITION BY`

## Requirement

Find employee rankings **inside each department**.

```sql
SELECT
    Name,
    Department,
    Salary,
    RANK() OVER (
        PARTITION BY Department
        ORDER BY Salary DESC
    ) AS DeptRank
FROM Employee;
```

### Output

| Department | Name | Salary | Rank |
|------------|------|-------:|-----:|
| IT | Amit | 100000 | 1 |
| IT | Rahul | 90000 | 2 |
| IT | Priya | 90000 | 2 |
| HR | John | 80000 | 1 |
| HR | Alice | 70000 | 2 |

### Explanation

`PARTITION BY` divides the data into separate groups.

Ranking starts again from **1** inside each department.

```
IT Department

Amit   → Rank 1
Rahul  → Rank 2
Priya  → Rank 2

--------------------

HR Department

John   → Rank 1
Alice  → Rank 2
```

Think of `PARTITION BY` as applying the same calculation separately for each group.

---

# Example 5 - Running Total

## Requirement

Show the cumulative salary.

```sql
SELECT
    Name,
    Salary,
    SUM(Salary) OVER (ORDER BY EmpId) AS RunningTotal
FROM Employee;
```

### Output

| Name | Salary | Running Total |
|------|-------:|--------------:|
| Amit | 100000 | 100000 |
| Rahul | 90000 | 190000 |
| Priya | 90000 | 280000 |
| John | 80000 | 360000 |
| Alice | 70000 | 430000 |

### How Running Total Works

```
Amit

100000

↓

Rahul

100000 + 90000 = 190000

↓

Priya

190000 + 90000 = 280000

↓

John

280000 + 80000 = 360000

↓

Alice

360000 + 70000 = 430000
```

Each row includes the sum of all previous rows.

---

# Example 6 - `LAG()`

## Requirement

Show the previous employee's salary.

```sql
SELECT
    Name,
    Salary,
    LAG(Salary) OVER (ORDER BY Salary DESC) AS PreviousSalary
FROM Employee;
```

### Output

| Name | Salary | Previous Salary |
|------|-------:|----------------:|
| Amit | 100000 | NULL |
| Rahul | 90000 | 100000 |
| Priya | 90000 | 90000 |
| John | 80000 | 90000 |
| Alice | 70000 | 80000 |

### Explanation

`LAG()` returns the value from the **previous row**.

```
Current Row  ← Previous Row
```

Example:

```
Rahul

Current Salary = 90000

Previous Salary = Amit's Salary = 100000
```

---

# Example 7 - `LEAD()`

## Requirement

Show the next employee's salary.

```sql
SELECT
    Name,
    Salary,
    LEAD(Salary) OVER (ORDER BY Salary DESC) AS NextSalary
FROM Employee;
```

### Output

| Name | Salary | Next Salary |
|------|-------:|------------:|
| Amit | 100000 | 90000 |
| Rahul | 90000 | 90000 |
| Priya | 90000 | 80000 |
| John | 80000 | 70000 |
| Alice | 70000 | NULL |

### Explanation

`LEAD()` returns the value from the **next row**.

```
Current Row → Next Row
```

Example:

```
Rahul

Current Salary = 90000

Next Salary = Priya's Salary = 90000
```

---

# Summary

| Function | Purpose |
|----------|---------|
| `ROW_NUMBER()` | Assigns a unique number to every row |
| `RANK()` | Gives the same rank to duplicates and skips the next rank |
| `DENSE_RANK()` | Gives the same rank to duplicates without skipping ranks |
| `PARTITION BY` | Splits data into groups before applying a window function |
| `SUM() OVER()` | Calculates a running total |
| `LAG()` | Returns the previous row's value |
| `LEAD()` | Returns the next row's value |

---

# Interview Questions (10+ Years Experience)

### 1. What is the difference between `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`?

- `ROW_NUMBER()` assigns a unique number to every row.
- `RANK()` assigns the same rank to duplicates and skips the next rank.
- `DENSE_RANK()` assigns the same rank to duplicates without skipping ranks.

---

### 2. When would you use `ROW_NUMBER()`?

Use it when you need:
- Pagination
- Removing duplicate records
- Selecting the latest record per group
- Assigning a unique sequence

---

### 3. When should you use `RANK()`?

Use `RANK()` when the ranking should reflect ties, such as:
- Sports rankings
- Leaderboards
- Competition results

---

### 4. When should you use `DENSE_RANK()`?

Use `DENSE_RANK()` when rankings should remain continuous without gaps, such as:
- Employee grading
- Product rankings
- Department performance reports

---

### 5. What is the purpose of `PARTITION BY`?

`PARTITION BY` divides the data into logical groups, and the window function operates independently within each group.

---

### 6. What is the difference between `GROUP BY` and Window Functions?

| GROUP BY | Window Function |
|----------|-----------------|
| Reduces rows | Keeps all rows |
| Returns one row per group | Returns every row |
| Used for aggregation | Used for row-wise calculations |

---

### 7. What are common real-world uses of Window Functions?

- Pagination
- Top-N records per department
- Running totals
- Previous and next row comparisons
- Ranking reports
- Trend analysis
- Time-series analytics
- Duplicate detection