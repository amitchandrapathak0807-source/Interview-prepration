# System Design Calculations & Capacity Planning
## How Senior Engineers Estimate Users, Storage, QPS, Bandwidth, Servers, and Databases

> **Interview Level:** ⭐⭐⭐⭐⭐
>
> This is one of the most important skills in a **System Design Interview**.
>
> Companies like:
>
> - Uber
> - Amazon
> - Microsoft
> - Google
> - Meta
> - Netflix
> - Point72
> - Goldman Sachs
>
> expect you to estimate the system before designing it.

---

# Why Do We Do Calculations?

Imagine the interviewer asks:

> **Design Uber**

The first mistake many candidates make is:

```
User

↓

API

↓

Microservice

↓

Kafka

↓

Redis
```

❌ Wrong approach.

A senior engineer first asks:

> **How big is the system?**

Because the architecture depends on the scale.

---

# Step 1 — Gather Requirements

Always ask the interviewer:

### Functional Requirements

- Book Ride
- Cancel Ride
- Track Driver
- Pay
- Rate Driver

---

### Non-Functional Requirements

- Availability
- Scalability
- Latency
- Security
- Fault Tolerance

---

### Scale Questions

Ask:

```
How many users?

How many active users?

How many requests/day?

Peak traffic?

Storage?

Retention?
```

If interviewer doesn't answer,

make assumptions.

---

# Standard Interview Assumptions

These are commonly accepted.

| Metric | Value |
|---------|------|
| Total Users | 100 Million |
| Daily Active Users | 10 Million |
| Monthly Active Users | 30 Million |
| Peak Traffic | 10x Average |
| Read : Write | Depends on System |
| Availability | 99.99% |

---

# Step 2 — Estimate Users

Suppose

```
100 Million Registered Users
```

Not everyone uses Uber daily.

Assume

```
10%

Daily Active
```

```
100 Million

↓

10 Million Daily Active Users
```

---

# Step 3 — Estimate Requests

Suppose

Each active user books

```
2 rides/day
```

Then

```
10 Million Users

×

2

=

20 Million Ride Requests/day
```

---

# Step 4 — Calculate QPS

QPS

```
Queries Per Second
```

Formula

```
QPS

=

Total Requests

/

86400
```

There are

```
86400

seconds/day
```

---

Example

```
20 Million Requests/day
```

```
20,000,000

/

86,400

=

231 QPS
```

Average

```
231 Requests/sec
```

---

# Step 5 — Peak QPS

Traffic isn't uniform.

Morning

High

Night

Low

Usually

Multiply

```
Average QPS

×

5

or

×

10
```

Example

```
231

×

10

=

2310 Peak QPS
```

Design for

```
2300 Requests/sec
```

NOT

231.

---

# Step 6 — Read vs Write Ratio

Uber

Ride Booking

Write

Tracking Driver

Read

Typical

```
Read

80%

Write

20%
```

Example

```
2300 Peak

↓

Reads

1840

Writes

460
```

Now

Caching decisions become easier.

---

# Step 7 — Storage Estimation

Suppose

Ride Table

One Ride

Stores

```
RideId

UserId

DriverId

Pickup

Drop

Status

Fare

Time
```

Assume

```
1 KB

per ride
```

---

20 Million rides/day

```
20,000,000

×

1 KB

=

20 GB/day
```

---

Yearly

```
20

×

365

=

7300 GB

=

7.3 TB/year
```

Only Ride Table.

---

# Step 8 — Images

Suppose

Driver documents

```
500 KB
```

Drivers

```
1 Million
```

Storage

```
500 KB

×

1 Million

=

500 GB
```

Usually

Stored in

Azure Blob

S3

Not SQL.

---

# Step 9 — Bandwidth

Suppose

One API Response

```
5 KB
```

Peak

```
2300 Requests/sec
```

Bandwidth

```
2300

×

5 KB

=

11500 KB/sec

=

11 MB/sec
```

---

Daily

```
11 MB

×

86400

=

950 GB/day
```

---

# Step 10 — Database Size

Ride

```
7 TB/year
```

Payment

```
3 TB
```

Logs

```
12 TB
```

Need

Partitioning.

---

# Step 11 — Cache Size

Most requested

Drivers nearby.

Suppose

One Driver

```
500 bytes
```

Nearby Drivers

```
100,000
```

Memory

```
500

×

100,000

=

50 MB
```

Very small.

Perfect for Redis.

---

# Step 12 — Server Estimation

Suppose

One Server handles

```
500 Requests/sec
```

Need

```
2300 Peak
```

Servers

```
2300

/

500

=

4.6

≈ 5 Servers
```

Always

Add

```
30%

buffer
```

Need

```
7 Servers
```

---

# Step 13 — Database Connections

Suppose

Each API

Uses

```
1 Connection
```

Peak

```
2300
```

Need

Connection Pool

Don't open

2300 SQL Connections.

Instead

```
100

or

200

pool
```

---

# Step 14 — Replication

Reads

1800/sec

Writes

450/sec

One Primary

```
Writes
```

Multiple Replicas

```
Reads
```

Architecture

```
Primary

↓

Replica1

Replica2

Replica3
```

---

# Step 15 — Growth

Always estimate

```
5 Years
```

Current

```
100 Million Users
```

Growth

```
20%

Yearly
```

Future

```
250 Million+
```

Design accordingly.

---

# Capacity Planning Summary

| Metric | Formula | Example |
|---------|----------|----------|
| Daily Active Users (DAU) | Registered × Active % | 100M × 10% = 10M |
| Daily Requests | DAU × Requests/User | 10M × 2 = 20M |
| Average QPS | Requests ÷ 86400 | 20M ÷ 86400 = 231 |
| Peak QPS | Avg QPS × Peak Factor | 231 × 10 = 2310 |
| Storage/Day | Records × Record Size | 20M × 1KB = 20GB |
| Storage/Year | Daily × 365 | 7.3TB |
| Bandwidth | QPS × Response Size | 2300 × 5KB ≈ 11MB/s |
| Servers | Peak QPS ÷ Server Capacity | 2300 ÷ 500 ≈ 5 |
| Cache Size | Objects × Object Size | 100K × 500B = 50MB |

---

# Cheat Sheet for Interviews

## Users

```
Registered Users

↓

Daily Active Users

↓

Concurrent Users
```

---

## Traffic

```
Users

↓

Requests/User

↓

Requests/day

↓

QPS

↓

Peak QPS
```

---

## Storage

```
Records/day

×

Record Size

↓

Daily Storage

↓

Yearly Storage
```

---

## Servers

```
Peak QPS

/

Server Capacity

=

Servers Needed
```

---

## Bandwidth

```
Peak QPS

×

Response Size

=

Network Throughput
```

---

# Typical Assumptions Used in Interviews

| Parameter | Typical Value |
|------------|---------------|
| Active Users | 10% of total users |
| Peak Traffic | 5–10 × average |
| Read:Write Ratio | 80:20 (read-heavy) |
| Server Capacity | 500–2000 RPS (depends on workload) |
| Availability | 99.9%–99.99% |
| API Response Size | 2–10 KB |
| Record Size | 500 B–2 KB |
| Growth Rate | 20–50% annually |

---

# How Senior Engineers Think

Instead of immediately drawing boxes, they think:

```text
How many users?

↓

How many requests?

↓

How much storage?

↓

How many reads?

↓

How many writes?

↓

Peak traffic?

↓

Can one database handle it?

↓

Need cache?

↓

Need replicas?

↓

Need sharding?

↓

Now draw architecture.
```

The calculations drive the architecture—not the other way around.

---

# Interview Questions (10+ Years Experience)

### Q1. Why do we calculate Peak QPS instead of Average QPS?

**Expected Answer**

Traffic is bursty. Designing for average load leads to failures during peak hours (morning commute, festivals, promotions). Systems must be sized for expected peak traffic plus a safety margin.

---

### Q2. Why estimate storage before selecting a database?

**Expected Answer**

Storage growth influences partitioning, indexing strategy, backup windows, replication costs, retention policies, and whether sharding will eventually be required.

---

### Q3. Why calculate Read/Write ratio?

**Expected Answer**

It determines architectural choices:

- Read-heavy → Redis, read replicas, CDN, caching.
- Write-heavy → Partitioning, append-only logs, Kafka, optimized write paths.

---

### Q4. Why estimate future growth?

**Expected Answer**

Architectures should scale for projected business growth. Choosing a design that only supports today's load often results in expensive migrations later.

---

# Next Step

For the **Uber LLD/System Design**, after these calculations, the next step is:

1. **Capacity Planning (Completed) ✅**
2. **Database Design (Tables & Relationships)**
3. **API Design**
4. **Low-Level Class Design**
5. **Service Layer**
6. **Concurrency Handling**
7. **Ride Matching Algorithm**
8. **Caching Strategy**
9. **Message Queues**
10. **Deployment & Scaling**
