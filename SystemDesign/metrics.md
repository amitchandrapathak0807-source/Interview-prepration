# System Design Metrics - Step-by-Step Calculation Guide

> This guide contains **only the calculations** used in system design interviews.

---

# Step 1: Estimate Total Users

Usually given by interviewer.

Example

```
Total Registered Users = 100 Million
```

Formula

```
Total Users = Given Value
```

---

# Step 2: Calculate Daily Active Users (DAU)

Assumption

Usually 5%–20%.

Take 10%.

Formula

```
DAU = Total Users × Active Percentage
```

Example

```
Total Users = 100 Million

Active = 10%

DAU

= 100,000,000 × 10%

= 10,000,000 Users
```

---

# Step 3: Calculate Requests Per User

Assumption depends on application.

Example

Uber

```
Each user books

2 rides/day
```

Formula

```
Total Requests

=

DAU × Requests Per User
```

Example

```
10,000,000

×

2

=

20,000,000 Requests/day
```

---

# Step 4: Calculate Average QPS

There are

```
86400 Seconds

in one day
```

Formula

```
Average QPS

=

Total Requests

/

86400
```

Example

```
20,000,000

/

86400

=

231 QPS
```

Meaning

```
Average

231 Requests

every second
```

---

# Step 5: Calculate Peak QPS

Traffic isn't constant.

Assume

```
Peak = 10×

Average
```

Formula

```
Peak QPS

=

Average QPS

×

Peak Factor
```

Example

```
231

×

10

=

2310 Peak QPS
```

---

# Step 6: Read Requests

Suppose

```
80%

Reads
```

Formula

```
Read QPS

=

Peak QPS

×

Read Percentage
```

Example

```
2310

×

80%

=

1848 Read QPS
```

---

# Step 7: Write Requests

Formula

```
Write QPS

=

Peak QPS

×

Write Percentage
```

Example

```
2310

×

20%

=

462 Write QPS
```

---

# Step 8: Storage Per Record

Estimate one record size.

Example

Ride

```
1 KB
```

Formula

```
Storage Per Record

=

Estimated Size
```

---

# Step 9: Daily Storage

Formula

```
Daily Storage

=

Requests Per Day

×

Record Size
```

Example

```
20 Million

×

1 KB

=

20 GB/day
```

---

# Step 10: Monthly Storage

Formula

```
Monthly Storage

=

Daily Storage

×

30
```

Example

```
20 GB

×

30

=

600 GB
```

---

# Step 11: Yearly Storage

Formula

```
Yearly Storage

=

Daily Storage

×

365
```

Example

```
20 GB

×

365

=

7300 GB

=

7.3 TB
```

---

# Step 12: Bandwidth Per Second

Assume

```
API Response

5 KB
```

Formula

```
Bandwidth/sec

=

Peak QPS

×

Response Size
```

Example

```
2310

×

5 KB

=

11550 KB/sec

≈11.3 MB/sec
```

---

# Step 13: Daily Bandwidth

Formula

```
Bandwidth/day

=

Bandwidth/sec

×

86400
```

Example

```
11.3 MB

×

86400

≈950 GB/day
```

---

# Step 14: Number of Servers

Assume

```
One Server

Handles

500 Requests/sec
```

Formula

```
Servers

=

Peak QPS

/

Server Capacity
```

Example

```
2310

/

500

=

4.62

≈5 Servers
```

---

# Step 15: Buffer Servers

Always add

```
30%
```

Formula

```
Final Servers

=

Calculated Servers

×

1.3
```

Example

```
5

×

1.3

=

6.5

≈7 Servers
```

---

# Step 16: Database Size After N Years

Formula

```
Database Size

=

Yearly Storage

×

Years
```

Example

```
7.3 TB

×

5

=

36.5 TB
```

---

# Step 17: Concurrent Users

Assumption

Usually

```
5%

to

10%

of DAU
```

Formula

```
Concurrent Users

=

DAU

×

Concurrency %
```

Example

```
10 Million

×

5%

=

500,000 Concurrent Users
```

---

# Step 18: Connection Pool Size

Assumption

Never create one DB connection per user.

Typical

```
100–500
```

per application instance.

---

# Step 19: Cache Size

Formula

```
Cache

=

Objects

×

Object Size
```

Example

```
100,000 Drivers

×

500 Bytes

=

50 MB
```

---

# Step 20: Growth Projection

Formula

```
Future Users

=

Current Users

×

(1 + Growth Rate)^Years
```

Example

```
100 Million

Growth

20%

5 Years

=

100 × (1.2)^5

≈249 Million Users
```

---

# Complete Formula Sheet

| Metric | Formula |
|---------|----------|
| DAU | Total Users × Active % |
| Requests/Day | DAU × Requests/User |
| Average QPS | Requests ÷ 86400 |
| Peak QPS | Average QPS × Peak Factor |
| Read QPS | Peak QPS × Read % |
| Write QPS | Peak QPS × Write % |
| Daily Storage | Requests × Record Size |
| Monthly Storage | Daily × 30 |
| Yearly Storage | Daily × 365 |
| Bandwidth/sec | Peak QPS × Response Size |
| Daily Bandwidth | Bandwidth/sec × 86400 |
| Servers | Peak QPS ÷ Server Capacity |
| Final Servers | Servers × 1.3 |
| Concurrent Users | DAU × Concurrency % |
| Cache Size | Objects × Object Size |
| Future Users | Current × (1 + Growth)^Years |
