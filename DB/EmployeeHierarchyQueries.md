# Employee Hierarchy Using Recursive CTE (SQL Server)

## What is an Employee Hierarchy?

An employee hierarchy represents a **manager-subordinate relationship**.

Example:

```text
CEO (1)
│
├── Manager A (2)
│   ├── Employee A1 (4)
│   └── Employee A2 (5)
│
└── Manager B (3)
    ├── Employee B1 (6)
    └── Employee B2 (7)
```

---

# Sample Table

## Employee

| Id | Name        | ManagerId |
| -: | ----------- | --------: |
|  1 | CEO         |      NULL |
|  2 | Manager A   |         1 |
|  3 | Manager B   |         1 |
|  4 | Employee A1 |         2 |
|  5 | Employee A2 |         2 |
|  6 | Employee B1 |         3 |
|  7 | Employee B2 |         3 |

Notice:

* `ManagerId` refers to another employee's `Id`.
* The CEO has no manager, so `ManagerId = NULL`.

---

# Problem Statement

Display the complete employee hierarchy starting from the CEO.

Expected Output:

| Level | Name        | Manager   |
| ----: | ----------- | --------- |
|     0 | CEO         | NULL      |
|     1 | Manager A   | CEO       |
|     1 | Manager B   | CEO       |
|     2 | Employee A1 | Manager A |
|     2 | Employee A2 | Manager A |
|     2 | Employee B1 | Manager B |
|     2 | Employee B2 | Manager B |

---

# Solution Using Recursive CTE

```sql
WITH EmployeeHierarchy AS
(
    -- Anchor Member (Root of the hierarchy)
    SELECT
        Id,
        Name,
        ManagerId,
        0 AS Level
    FROM Employee
    WHERE ManagerId IS NULL

    UNION ALL

    -- Recursive Member
    SELECT
        e.Id,
        e.Name,
        e.ManagerId,
        eh.Level + 1
    FROM Employee e
    INNER JOIN EmployeeHierarchy eh
        ON e.ManagerId = eh.Id
)

SELECT *
FROM EmployeeHierarchy
ORDER BY Level, Id;
```

---

# How It Works

## Step 1 - Anchor Member

Start with the employee who has **no manager**.

```sql
SELECT
    Id,
    Name,
    ManagerId,
    0 AS Level
FROM Employee
WHERE ManagerId IS NULL;
```

Output:

| Id | Name | Level |
| -: | ---- | ----: |
|  1 | CEO  |     0 |

This is the starting point.

---

## Step 2 - Recursive Member

Now find employees reporting to the CEO.

```sql
SELECT
    e.Id,
    e.Name,
    e.ManagerId,
    eh.Level + 1
FROM Employee e
INNER JOIN EmployeeHierarchy eh
ON e.ManagerId = eh.Id;
```

First iteration:

| Name      | Level |
| --------- | ----: |
| Manager A |     1 |
| Manager B |     1 |

Second iteration:

| Name        | Level |
| ----------- | ----: |
| Employee A1 |     2 |
| Employee A2 |     2 |
| Employee B1 |     2 |
| Employee B2 |     2 |

The recursion stops automatically when there are no more employees to process.

---

# Visual Representation

```text
Iteration 1

CEO

↓

Iteration 2

Manager A
Manager B

↓

Iteration 3

Employee A1
Employee A2
Employee B1
Employee B2

↓

No more rows

Stop
```

---

# Complete Output

| Level | Employee    |
| ----: | ----------- |
|     0 | CEO         |
|     1 | Manager A   |
|     1 | Manager B   |
|     2 | Employee A1 |
|     2 | Employee A2 |
|     2 | Employee B1 |
|     2 | Employee B2 |

---

# Where Is This Used?

Recursive CTEs are commonly used for:

* Employee hierarchies
* Organization charts
* Folder and file structures
* Category and subcategory trees
* Bill of Materials (BOM)
* Comment/reply threads
* Menu structures

---

# Interview Questions

### Q1. Why use a Recursive CTE?

Because the number of hierarchy levels is unknown, recursion lets SQL Server keep traversing parent-child relationships until no more matching rows exist.

---

### Q2. What are the two parts of a Recursive CTE?

1. **Anchor Member** – Returns the starting rows (for example, the CEO).
2. **Recursive Member** – Repeatedly joins the CTE back to the table to find child rows.

---

### Q3. Why is `UNION ALL` used instead of `UNION`?

`UNION ALL` is faster because it doesn't remove duplicates. Recursive CTEs typically don't require duplicate elimination.

---

### Q4. How does SQL Server know when to stop?

Recursion ends automatically when the recursive query returns **no new rows**.

---

# Interview Answer (1 Minute)

> "A Recursive CTE is used to query hierarchical data such as employee-manager relationships. It consists of an anchor member, which retrieves the root node (for example, the CEO), and a recursive member, which repeatedly joins the employee table to the CTE to find subordinates. SQL Server continues executing the recursive member until no additional rows are returned. Recursive CTEs are commonly used for organization charts, folder hierarchies, category trees, and bill-of-material structures."
