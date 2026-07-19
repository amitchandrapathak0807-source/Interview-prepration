# Clustered Index vs Non-Clustered Index

## What is an Index?

An **index** is a data structure that helps SQL Server find rows faster without scanning the entire table.

Think of it like a **book**:

* **Clustered Index** → Pages in the book are physically arranged in chapter order.
* **Non-Clustered Index** → The index at the back of the book tells you which page to go to.

---

# Clustered Index

A **Clustered Index** determines the **physical order** of data in the table.

* Data rows are stored in sorted order.
* A table can have **only ONE** clustered index.
* Usually created on the **Primary Key**.

### Example

```sql
CREATE TABLE Employee
(
    EmployeeId INT PRIMARY KEY,
    Name VARCHAR(100),
    Department VARCHAR(50),
    Salary DECIMAL(10,2)
);
```

SQL Server creates a Clustered Index on `EmployeeId` by default.

### Physical Storage

```text
Employee Table

EmployeeId

1

2

3

4

5

6

7

8
```

Rows are physically stored in EmployeeId order.

Searching for EmployeeId = 5

```text
1 → 2 → 3 → 4 → 5 ✔
```

SQL Server quickly reaches the row.

---

# Non-Clustered Index

A **Non-Clustered Index** stores the indexed column separately from the actual table.

Instead of storing complete rows, it stores:

```text
Indexed Value

↓

Pointer

↓

Actual Data Row
```

A table can have **multiple Non-Clustered Indexes**.

### Example

```sql
CREATE NONCLUSTERED INDEX IX_Employee_Name
ON Employee(Name);
```

Now SQL Server creates a separate index.

```text
Name Index

Amit  ------> EmployeeId 2

John  ------> EmployeeId 7

Neha  ------> EmployeeId 4
```

When searching:

```sql
SELECT *
FROM Employee
WHERE Name = 'Neha';
```

SQL Server

```text
Name Index

↓

Find "Neha"

↓

EmployeeId = 4

↓

Go to actual table

↓

Return complete row
```

---

# Example

Suppose the table contains:

| EmployeeId | Name  | Department |
| ---------- | ----- | ---------- |
| 1          | John  | HR         |
| 2          | Amit  | IT         |
| 3          | Neha  | Finance    |
| 4          | Rahul | IT         |

Clustered Index

```text
EmployeeId

1

2

3

4
```

Non-Clustered Index on Name

```text
Amit  → Row 2

John  → Row 1

Neha  → Row 3

Rahul → Row 4
```

Searching by:

```sql
WHERE EmployeeId = 3
```

Uses **Clustered Index**

Searching by:

```sql
WHERE Name = 'Neha'
```

Uses **Non-Clustered Index**

---

# Key Differences

| Feature        | Clustered Index            | Non-Clustered Index          |
| -------------- | -------------------------- | ---------------------------- |
| Data Storage   | Data is physically sorted  | Separate index structure     |
| Number Allowed | Only 1                     | Multiple                     |
| Leaf Nodes     | Actual table data          | Pointer to table data        |
| Lookup Speed   | Very fast for Primary Key  | Extra lookup may be required |
| Storage        | No extra storage for data  | Requires additional storage  |
| Best For       | Range queries, Primary Key | Frequently searched columns  |

---

# When to Use Clustered Index

Use on:

* Primary Key
* Frequently used range queries
* Sorting
* BETWEEN queries
* ORDER BY
* Joins using Primary Key

Example

```sql
SELECT *
FROM Orders
WHERE OrderId BETWEEN 1000 AND 2000;
```

A Clustered Index performs very efficiently because rows are stored sequentially.

---

# When to Use Non-Clustered Index

Use on:

* Name
* Email
* Mobile Number
* Department
* Status
* Foreign Keys
* Frequently searched columns

Example

```sql
SELECT *
FROM Employee
WHERE Email = 'amit@gmail.com';
```

Creating a Non-Clustered Index on `Email` significantly speeds up this lookup.

---

# Real-World Example

Imagine a phone book.

## Clustered Index

Names are already arranged alphabetically.

```text
Amit

John

Neha

Rahul
```

You can directly find "Neha."

---

## Non-Clustered Index

Imagine a book.

The pages are not arranged by topic.

At the back of the book:

```text
SQL Server ........ Page 120

RabbitMQ .......... Page 230

Kafka ............. Page 315
```

The index tells you where to go.

---

# Advantages

## Clustered Index

* Fast range scans
* Fast sorting
* Efficient ORDER BY
* Efficient BETWEEN queries

---

## Non-Clustered Index

* Multiple indexes allowed
* Faster searches on non-primary columns
* Improves JOIN performance
* Ideal for frequently searched attributes

---

# Disadvantages

## Clustered Index

* Only one per table
* Inserts/updates can be slower because data may need to be reordered

---

## Non-Clustered Index

* Consumes additional storage
* Inserts, updates, and deletes are slightly slower because indexes must also be updated
* May require an extra lookup (Key Lookup) to fetch complete row data

---

# Interview Answer (1 Minute)

> A Clustered Index determines the physical order of data in a table, so the table itself is stored in the order of the clustered index key. Since data can only be stored in one physical order, a table can have only one clustered index, typically on the primary key. A Non-Clustered Index is a separate structure that stores indexed column values along with pointers to the actual data rows. A table can have multiple non-clustered indexes to optimize searches on frequently queried columns like Name, Email, or Department. I typically use a clustered index on the primary key and create non-clustered indexes on columns that are frequently used in WHERE, JOIN, ORDER BY, or GROUP BY clauses.

---

# Quick Revision

| Clustered Index                | Non-Clustered Index                 |
| ------------------------------ | ----------------------------------- |
| Physical ordering of data      | Separate lookup structure           |
| One per table                  | Multiple per table                  |
| Fast range queries             | Fast point lookups                  |
| Usually Primary Key            | Usually searchable columns          |
| Leaf nodes contain actual data | Leaf nodes contain pointers to data |
| Best for ORDER BY and BETWEEN  | Best for WHERE Name, Email, Status  |
