# ACID Properties & CAP Theorem (Complete Guide with Real-World Examples)

> **Interview Level:** Senior Software Engineer / Tech Lead / Architect (10+ Years)

These are two of the **most frequently asked database and system design concepts**.

Many people memorize:

- ACID = Atomicity, Consistency, Isolation, Durability
- CAP = Consistency, Availability, Partition Tolerance

But they don't actually understand **why these concepts exist**.

Let's understand them from scratch.

---

# Part 1 - Why Do We Need ACID?

Imagine you have a banking application.

Suppose Amit has

```
₹10,000
```

Rahul has

```
₹5,000
```

Amit wants to transfer

```
₹2,000
```

to Rahul.

---

## What should happen?

Before transfer

```
Amit = ₹10,000

Rahul = ₹5,000
```

After transfer

```
Amit = ₹8,000

Rahul = ₹7,000
```

Simple.

Now let's see what happens internally.

---

# Behind the Scenes

One transfer actually consists of multiple operations.

```sql
UPDATE Accounts
SET Balance = Balance - 2000
WHERE UserId = 'Amit';

UPDATE Accounts
SET Balance = Balance + 2000
WHERE UserId = 'Rahul';
```

Looks simple.

But imagine the electricity goes off after the first query.

Database now contains:

```
Amit = ₹8,000

Rahul = ₹5,000
```

₹2,000 disappeared.

This is unacceptable.

This is exactly why ACID properties exist.

---

# What is ACID?

ACID is a set of guarantees provided by a database to ensure that transactions are processed safely and reliably.

```
A

Atomicity

C

Consistency

I

Isolation

D

Durability
```

Let's understand each one.

---

# A - Atomicity

## Definition

A transaction should happen **completely or not at all**.

There is no "half completed" transaction.

---

## Example

Bank Transfer

```
Step 1

Deduct ₹2,000 from Amit

Step 2

Add ₹2,000 to Rahul
```

Suppose power fails after Step 1.

Without Atomicity

```
Amit = ₹8,000

Rahul = ₹5,000
```

Money disappeared.

---

## With Atomicity

Database automatically rolls back.

Final state

```
Amit = ₹10,000

Rahul = ₹5,000
```

Nothing changed.

---

## Real SQL Example

```sql
BEGIN TRANSACTION;

UPDATE Accounts
SET Balance = Balance - 2000
WHERE UserId='Amit';

UPDATE Accounts
SET Balance = Balance + 2000
WHERE UserId='Rahul';

COMMIT;
```

If any statement fails:

```sql
ROLLBACK;
```

Everything is undone.

---

## Real Life Analogy

Imagine buying a movie ticket online.

Steps:

- Deduct money.
- Reserve seat.
- Send confirmation.

If seat reservation fails:

Should money still be deducted?

No.

Either all three happen or none happen.

That's Atomicity.

---

# C - Consistency

## Definition

A transaction should always move the database from **one valid state to another valid state**.

Rules should never be violated.

---

## Example

Suppose a bank rule says:

```
Balance can never become negative.
```

Amit has

```
₹1,000
```

He tries to transfer

```
₹5,000
```

Without Consistency

Database becomes

```
Amit = -₹4,000
```

Rule broken.

---

## With Consistency

Database rejects the transaction.

Balance remains

```
₹1,000
```

Business rules stay intact.

---

## Another Example

Suppose EmployeeId must be unique.

Existing

```
EmployeeId = 100
```

Insert

```
EmployeeId = 100
```

Database rejects it.

Consistency maintained.

---

# Consistency Isn't Only About Constraints

It also includes:

- Foreign Keys
- Primary Keys
- Check Constraints
- Business Rules
- Triggers
- Unique Constraints

---

# I - Isolation

## Definition

Multiple transactions should not interfere with each other.

---

## Real Example

Suppose there is only **one movie ticket left**.

Two users book simultaneously.

```
Rahul

↓

Book Seat A1

Priya

↓

Book Seat A1
```

Without Isolation

Both see:

```
Seat Available
```

Both pay.

Now two people own one seat.

Impossible.

---

## With Isolation

Database locks or manages concurrency.

Rahul books first.

Priya waits.

When Rahul finishes:

Database checks again.

Seat is no longer available.

Priya gets:

```
Seat already booked.
```

---

## Another Example

Suppose current balance is

```
₹10,000
```

Transaction A

```
Reads

₹10,000
```

Transaction B

```
Updates

₹12,000
```

Should Transaction A suddenly see half-updated data?

No.

Isolation ensures predictable behavior.

---

# Isolation Levels

| Level | Prevents |
|--------|----------|
| Read Uncommitted | Nothing |
| Read Committed | Dirty Reads |
| Repeatable Read | Dirty + Non-repeatable Reads |
| Serializable | All concurrency issues |
| Snapshot | Uses row versioning |

(We'll discuss these in detail separately.)

---

# D - Durability

## Definition

Once a transaction is committed, it should survive even if:

- Power fails.
- Server crashes.
- Database restarts.

---

## Example

Suppose Amit transfers money.

Database says

```
Transaction Successful
```

Immediately after that:

Server crashes.

Should the transfer disappear?

No.

---

## How?

Databases maintain:

- Transaction Logs
- Write-Ahead Logs (WAL)
- Redo Logs

Before confirming success, changes are safely recorded.

After restart:

Database replays committed transactions.

---

## Real Life Example

Imagine sending an email.

You receive

```
Sent Successfully
```

Then your laptop crashes.

Should the email disappear?

No.

The mail server has already persisted it.

That's Durability.

---

# ACID Summary

| Property | Meaning |
|-----------|---------|
| Atomicity | All or Nothing |
| Consistency | Rules Never Break |
| Isolation | Transactions Don't Interfere |
| Durability | Committed Data Never Lost |

---

# Part 2 - CAP Theorem

Now let's move from databases to distributed systems.

---

# Why Does CAP Exist?

Imagine Instagram has only one database.

Easy.

Now imagine:

```
India

USA

Europe
```

Each region has its own database.

Question

What happens if network communication fails?

This introduces a new problem:

**Distributed Systems.**

---

# What is CAP Theorem?

Eric Brewer proposed that in a distributed system, you cannot simultaneously guarantee all three:

- Consistency
- Availability
- Partition Tolerance

You can guarantee **at most two**.

---

# What Do These Mean?

```
C

Consistency

A

Availability

P

Partition Tolerance
```

Let's understand each.

---

# C - Consistency

Every user sees the **same data**.

Example:

Amit changes his profile picture.

Immediately afterward:

Rahul opens Amit's profile.

He should also see the new picture.

Not the old one.

All nodes return the same value.

---

# A - Availability

Every request receives a response.

Even if the response contains slightly stale data.

Example:

Suppose one database server is down.

Should Instagram return

```
500 Internal Server Error
```

for everyone?

No.

Users should still get a response.

---

# P - Partition Tolerance

A partition means network communication between servers is interrupted.

Imagine:

```
India Database

×

USA Database
```

Network cable breaks.

Servers cannot communicate.

This is called a **Network Partition**.

---

# Why Is Partition Tolerance Mandatory?

In a distributed system:

Networks fail.

Routers fail.

Switches fail.

Cloud regions fail.

Therefore every real distributed system **must tolerate partitions**.

You cannot choose to ignore network failures.

---

# Example

Suppose Instagram has:

```
Server A (India)

Server B (USA)
```

Normally

```
India

⇄

USA
```

Now network fails.

```
India

X

USA
```

The two servers cannot synchronize.

Now you must make a choice.

---

# Choice 1 - Consistency First (CP)

Suppose Amit changes his username.

India database updates.

USA database cannot be updated because of the network failure.

Question:

Should USA continue serving requests?

If consistency is required:

No.

USA refuses requests.

Users receive an error.

Why?

Serving stale data would violate consistency.

---

# Result

```
Consistency

✔

Availability

✘

Partition Tolerance

✔
```

This is called a **CP System**.

Examples:

- HBase
- ZooKeeper
- etcd

---

# Choice 2 - Availability First (AP)

Instead of refusing requests,

USA continues serving users.

Users receive the old username.

Later, when the network recovers:

Data synchronizes.

Users briefly see stale data, but the system remains available.

---

# Result

```
Availability

✔

Consistency

✘ (temporarily)

Partition Tolerance

✔
```

This is called an **AP System**.

Examples:

- Cassandra
- DynamoDB
- Riak

---

# Can We Have CA?

Only if there is **no network partition**.

Single SQL Server

```
Consistency

✔

Availability

✔

Partition

Not Applicable
```

But in real distributed systems, partitions are inevitable.

Therefore modern distributed systems usually choose:

- CP
- AP

---

# ACID vs CAP

| ACID | CAP |
|------|-----|
| Database Transactions | Distributed Systems |
| Focuses on one transaction | Focuses on multiple servers |
| Ensures correctness | Defines distributed trade-offs |
| Used in SQL databases | Used in distributed databases |

---

# Real World Comparison

## Banking System

Choose:

```
CP
```

Reason:

Incorrect balances are unacceptable.

If necessary, temporarily reject requests.

Consistency is more important.

---

## Instagram Likes

Choose:

```
AP
```

Suppose Rahul likes a photo.

Priya sees:

```
99 Likes
```

for a few seconds.

Actual value:

```
100 Likes
```

Perfectly acceptable.

Users prefer availability over perfect consistency.

---

## Airline Seat Booking

Choose:

```
CP
```

Selling the same seat twice is unacceptable.

Better to reject requests than create inconsistent bookings.

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. Can a distributed system guarantee ACID and CAP together?

### Answer

Yes, but they address different concerns. ACID governs **transaction correctness within a database**, while CAP describes **trade-offs in distributed systems during network partitions**. A distributed SQL database may provide ACID transactions within a node while still needing to choose between Consistency and Availability when partitions occur.

---

## Q2. Why can't a distributed system provide all three CAP guarantees?

### Answer

During a network partition, servers cannot communicate. At that moment:

- If the system continues serving requests, different nodes may return different data, sacrificing **Consistency**.
- If the system refuses requests until synchronization is restored, it sacrifices **Availability**.

Since Partition Tolerance is mandatory in distributed systems, only one of Consistency or Availability can be fully guaranteed during a partition.

---

## Q3. Why do banks prefer CP while social media platforms often prefer AP?

### Answer

Banking systems handle financial transactions where correctness is critical. Returning stale or conflicting account balances is unacceptable, so they prioritize **Consistency**, even if some requests are temporarily unavailable.

Social media platforms like Instagram can tolerate short-lived inconsistencies. For example, showing 999 likes instead of 1,000 for a few seconds has minimal business impact. Therefore, they prioritize **Availability**, ensuring users can continue interacting with the platform even during network issues.

---

## Q4. Does SQL Server satisfy ACID?

### Answer

Yes. SQL Server is an ACID-compliant relational database. It provides:

- **Atomicity** through transactions (`BEGIN TRANSACTION`, `COMMIT`, `ROLLBACK`).
- **Consistency** through constraints, triggers, and transaction rules.
- **Isolation** through configurable isolation levels and locking/versioning.
- **Durability** through transaction logs and recovery mechanisms.
