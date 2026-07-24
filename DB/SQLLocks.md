# SQL Server Locks (Complete Guide)

> **Interview Level:** Senior Software Engineer / Tech Lead / Architect (10+ Years)

SQL Locks are one of the **most frequently asked SQL Server interview topics** because every application that reads or writes data relies on them.

Many developers know terms like:

- Shared Lock
- Exclusive Lock
- Update Lock

But they don't understand **why locks exist**.

Let's understand SQL Locks from scratch with real-world examples.

---

# Chapter 1 - Why Do We Need Locks?

Imagine you own a bank.

Account balance:

```
Amit = ₹10,000
```

Two ATMs are running at the same time.

ATM 1

```
Withdraw ₹5,000
```

ATM 2

```
Withdraw ₹7,000
```

Both requests arrive at exactly the same time.

---

## Without Locks

ATM 1 reads

```
Balance = ₹10,000
```

ATM 2 also reads

```
Balance = ₹10,000
```

ATM 1 deducts ₹5,000

```
Balance = ₹5,000
```

ATM 2 deducts ₹7,000 based on the value it already read.

Final balance becomes

```
₹3,000
```

But the customer withdrew

```
₹12,000
```

from an account that only had

```
₹10,000
```

The database is corrupted.

---

# What Caused This?

Both transactions accessed the same row at the same time.

Neither transaction knew the other one was modifying it.

This is exactly why databases use **Locks**.

---

# What is a Lock?

A lock is a mechanism used by SQL Server to control concurrent access to data.

Think of it like a meeting room.

Suppose there is only one conference room.

Rahul enters the room.

He locks the door.

Priya arrives.

She cannot enter until Rahul leaves.

The lock prevents conflicts.

SQL Server works the same way.

---

# Chapter 2 - How SQL Server Executes a Query

Suppose we execute

```sql
UPDATE Accounts
SET Balance = Balance - 1000
WHERE AccountId = 1;
```

SQL Server performs:

1. Finds the row.
2. Places a lock on the row.
3. Updates the balance.
4. Commits the transaction.
5. Releases the lock.

The lock exists only for the duration of the transaction.

---

# Chapter 3 - Types of Locks

SQL Server supports many lock types.

The most important ones are:

- Shared Lock (S)
- Exclusive Lock (X)
- Update Lock (U)
- Intent Locks (IS, IX, SIX)
- Schema Locks
- Bulk Update Lock

We'll cover each one.

---

# 1. Shared Lock (S)

## Purpose

Allows reading.

Prevents modification while the read is in progress.

---

## Example

Suppose Rahul executes

```sql
SELECT *
FROM Accounts
WHERE AccountId = 1;
```

SQL Server places a **Shared Lock** on that row.

While Rahul is reading:

Other users can also read.

But nobody can modify the row.

---

## Example

Current balance

```
₹10,000
```

Rahul starts reading.

Priya executes

```sql
UPDATE Accounts
SET Balance = 20000
WHERE AccountId = 1;
```

Priya waits.

Why?

Because Rahul still has a Shared Lock.

---

## Shared Lock Compatibility

```
Read

✔

Read

Allowed
```

```
Read

✘

Write

Blocked
```

---

# 2. Exclusive Lock (X)

## Purpose

Used when modifying data.

No other transaction can:

- Read
- Write

until the lock is released (under default locking behavior).

---

## Example

```sql
UPDATE Products
SET Price = 500
WHERE ProductId = 10;
```

SQL Server places an Exclusive Lock.

Now:

Any other

```sql
SELECT
```

or

```sql
UPDATE
```

must wait (unless snapshot/versioning is used).

---

## Real Example

Imagine a cashier counting cash.

Nobody else should touch the cash while counting.

Exclusive Lock works exactly like that.

---

# Exclusive Lock Compatibility

```
Write

✘

Write

Blocked
```

```
Write

✘

Read

Blocked
```

---

# 3. Update Lock (U)

This is one of the most misunderstood locks.

---

## Why Was Update Lock Introduced?

Suppose two users execute

```sql
UPDATE Products

SET Quantity = Quantity - 1

WHERE ProductId = 100;
```

Both queries first need to locate the row.

Initially they read the row.

If SQL Server only used Shared Locks:

Both sessions could read.

Later both try converting Shared Lock to Exclusive Lock.

Each waits for the other.

This creates a **Deadlock**.

---

## Solution

SQL Server first acquires an Update Lock.

Only one Update Lock is allowed.

Later

Update Lock

becomes

Exclusive Lock.

Deadlocks reduce significantly.

---

# Update Lock Flow

```
Read

↓

Update Lock

↓

Exclusive Lock

↓

Update

↓

Commit
```

---

# 4. Intent Locks

Intent Locks are used when SQL Server wants to lock lower-level objects.

Hierarchy:

```
Database

↓

Table

↓

Page

↓

Row
```

Suppose SQL Server wants to lock a row.

Before locking the row:

It places an Intent Lock on the table.

Why?

To inform other transactions:

> "Someone is locking something inside this table."

---

# Types

```
IS

Intent Shared

IX

Intent Exclusive

SIX

Shared + Intent Exclusive
```

---

## Example

Updating one row.

SQL Server:

```
Table

↓

Intent Exclusive

↓

Row

↓

Exclusive Lock
```

Without intent locks:

SQL Server would have to inspect every row to know whether a table lock is safe.

Intent locks make lock management efficient.

---

# 5. Schema Locks

Used when changing database structure.

Example

```sql
ALTER TABLE Employees
ADD Salary INT;
```

During schema modification:

Other queries may be blocked.

Types:

- Schema Stability (Sch-S)
- Schema Modification (Sch-M)

---

# 6. Bulk Update Lock

Used during bulk operations.

Example

```sql
BULK INSERT Employees
FROM 'employees.csv';
```

Optimized for high-speed inserts.

---

# Chapter 4 - Lock Granularity

SQL Server can lock different levels.

- Row
- Page
- Table
- Database

---

## Row Lock

Locks only one row.

```
Employee

100
```

Only that row is locked.

Most efficient.

---

## Page Lock

A page contains multiple rows (typically 8 KB).

Instead of locking one row:

SQL Server locks the entire page.

Useful when many rows on the same page are affected.

---

## Table Lock

Entire table is locked.

No one else can access it (depending on lock type).

Used for:

- Large updates.
- Bulk operations.

---

## Database Lock

Entire database is locked.

Rare.

Usually during maintenance.

---

# Chapter 5 - Lock Escalation

Suppose a query updates

```
500,000 Rows
```

Should SQL Server create

```
500,000 Row Locks?
```

No.

Too much memory.

Instead

SQL Server automatically converts

```
Thousands of Row Locks

↓

One Table Lock
```

This is called **Lock Escalation**.

---

# Example

```sql
UPDATE Orders

SET Status='Closed';
```

Entire table affected.

SQL Server often escalates to a table lock.

---

# Chapter 6 - Blocking

Suppose Rahul executes

```sql
BEGIN TRANSACTION;

UPDATE Accounts

SET Balance=Balance-1000

WHERE Id=1;
```

Rahul goes to lunch.

Transaction remains open.

Priya executes

```sql
UPDATE Accounts

SET Balance=Balance+1000

WHERE Id=1;
```

Priya waits.

Not because SQL Server is slow.

Because Rahul still owns the lock.

This is called **Blocking**.

---

# Chapter 7 - Deadlock

Deadlocks are one of the most common interview questions.

---

## Example

Rahul

Locks

```
Account A
```

Needs

```
Account B
```

Priya

Locks

```
Account B
```

Needs

```
Account A
```

Both wait forever.

SQL Server detects this cycle.

It chooses one transaction as the **Deadlock Victim**, rolls it back, and allows the other to continue.

---

# How to Prevent Deadlocks

- Access tables in the same order.
- Keep transactions short.
- Use appropriate indexes.
- Avoid user interaction inside transactions.
- Reduce lock duration.
- Use `UPDLOCK` when appropriate.

---

# Chapter 8 - Lock Compatibility Matrix (Simplified)

| Requested \ Existing | Shared (S) | Update (U) | Exclusive (X) |
|----------------------|------------|------------|---------------|
| **Shared (S)** | ✔ | ✔ (usually only one U holder; S can coexist with U) | ✘ |
| **Update (U)** | ✔ | ✘ | ✘ |
| **Exclusive (X)** | ✘ | ✘ | ✘ |

---

# Chapter 9 - Monitoring Locks

View active locks

```sql
SELECT *

FROM sys.dm_tran_locks;
```

Find blocking sessions

```sql
EXEC sp_who2;
```

Or

```sql
SELECT *

FROM sys.dm_exec_requests;
```

---

# Chapter 10 - Real Production Example

Suppose Instagram stores likes.

Two users like the same post simultaneously.

Without locking:

```
LikeCount

100

↓

101

↓

101
```

Wrong.

Correct value:

```
102
```

SQL Server uses locks (and atomic updates) to ensure correctness.

---

# Summary

| Lock Type | Purpose |
|------------|----------|
| Shared (S) | Read |
| Exclusive (X) | Write |
| Update (U) | Prevent deadlocks during updates |
| Intent (IS/IX/SIX) | Indicate lower-level locks |
| Schema (Sch-S/Sch-M) | Protect metadata |
| Bulk Update | High-speed bulk operations |

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. What is the difference between a Shared Lock and an Exclusive Lock?

### Answer

A **Shared Lock (S)** is acquired during read operations. Multiple transactions can hold Shared Locks on the same resource simultaneously, allowing concurrent reads. However, a Shared Lock prevents conflicting write operations.

An **Exclusive Lock (X)** is acquired during insert, update, or delete operations. While an Exclusive Lock is held, no other transaction can acquire Shared or Exclusive Locks on the same resource (under standard locking), ensuring that modifications occur safely.

---

## Q2. Why does SQL Server use an Update Lock instead of directly acquiring an Exclusive Lock?

### Answer

During an update, SQL Server typically needs to locate and read the target row before modifying it. If multiple sessions first acquired Shared Locks and later attempted to upgrade to Exclusive Locks, they could deadlock.

An **Update Lock (U)** solves this problem. SQL Server acquires an Update Lock while locating the row. Only one Update Lock is allowed on a resource, reducing the chance of conversion deadlocks. When the modification begins, the Update Lock is upgraded to an Exclusive Lock.

---

## Q3. What is Lock Escalation, and why is it important?

### Answer

Lock Escalation occurs when SQL Server replaces many fine-grained locks (such as thousands of row locks) with a single coarse-grained lock (such as a table lock). This reduces memory overhead and improves lock management efficiency.

For example, updating 500,000 rows individually would require hundreds of thousands of row locks. SQL Server may instead escalate to a table lock, reducing memory consumption at the cost of lower concurrency.

---

## Q4. What is the difference between Blocking and Deadlocking?

### Answer

**Blocking** occurs when one transaction waits for another transaction to release a lock. It is normal behavior and resolves once the blocking transaction commits or rolls back.

**Deadlocking** occurs when two or more transactions wait on each other in a circular dependency. Since neither can proceed, SQL Server detects the cycle and automatically chooses one transaction as the deadlock victim, rolling it back so the other transaction can continue.

---

## Q5. How would you reduce locking and improve concurrency in SQL Server?

### Answer

Several techniques help reduce locking and improve concurrency:

- Keep transactions as short as possible.
- Create appropriate indexes to reduce scan duration.
- Access tables in a consistent order to reduce deadlocks.
- Use row versioning (`READ COMMITTED SNAPSHOT` or `SNAPSHOT`) where appropriate.
- Avoid holding transactions open during user interaction.
- Batch large updates to reduce lock escalation.
- Monitor blocking using Dynamic Management Views (DMVs) and optimize long-running queries.
