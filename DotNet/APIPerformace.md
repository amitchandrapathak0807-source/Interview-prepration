# C# API Performance Troubleshooting Guide

## Scenario

Suppose we have the following API:

```http
GET /api/orders/12345
```

Expected Response Time:
- < 300 ms

Current Response Time:
- 6-8 seconds

Your task is to identify where the time is being spent.

---

# Step 1: Reproduce the Issue

Never start optimizing blindly.

Measure first.

Tools:

- Postman
- Swagger
- curl
- k6
- JMeter

Example

```
GET /api/orders/12345
```

Response Time

```
7.2 seconds
```

Now we know the issue is reproducible.

---

# Step 2: Check Logs

First thing I check is application logs.

Example

```
Request Started
Time : 10:00:00.000

Request Completed
Time : 10:00:07.240
```

Now we know

Total Time

```
7240 ms
```

But where?

Need detailed logging.

Example

```csharp
_logger.LogInformation("Fetching Order");

var order = await repository.GetOrder(id);

_logger.LogInformation("Fetching Customer");

var customer = await repository.GetCustomer(order.CustomerId);

_logger.LogInformation("Generating Invoice");

var invoice = await invoiceService.Generate(order);
```

Output

```
Fetch Order       50ms
Fetch Customer    40ms
Invoice Service   6900ms
```

Problem Found.

---

# Step 3: Use ASP.NET Core Logging

Measure each middleware.

Example

```csharp
app.Use(async (context, next) =>
{
    var sw = Stopwatch.StartNew();

    await next();

    sw.Stop();

    Console.WriteLine($"Request took {sw.ElapsedMilliseconds} ms");
});
```

Output

```
Request took 7200 ms
```

---

# Step 4: Check SQL Queries

Usually this is the biggest bottleneck.

Enable logging

```csharp
options.LogTo(Console.WriteLine)
       .EnableSensitiveDataLogging();
```

Look for

- Slow SQL
- Multiple Queries
- Full Table Scan
- Missing Index

Example

Generated SQL

```sql
SELECT *
FROM Orders
```

Table

```
5 Million Rows
```

Bad.

Instead

```sql
SELECT OrderId,
       CustomerId,
       Status
FROM Orders
WHERE OrderId = 123
```

Huge improvement.

---

# Step 5: Check Execution Plan

Suppose SQL query takes

```
5.8 seconds
```

Open Actual Execution Plan.

Look for

❌ Table Scan

Instead of

✅ Index Seek

Example

Before

```
Table Scan

Cost : 92%
```

After creating index

```sql
CREATE INDEX IX_Orders_OrderId
ON Orders(OrderId);
```

Now

```
Index Seek

Cost : 3%
```

Query

```
5800ms

↓

20ms
```

---

# Step 6: Check EF Core

Bad

```csharp
var orders = await context.Orders.ToListAsync();
```

Loads entire table.

Good

```csharp
var order = await context.Orders
            .Where(x => x.Id == id)
            .Select(x => new
            {
                x.Id,
                x.Status
            })
            .FirstOrDefaultAsync();
```

Only required columns.

---

# Step 7: Check N+1 Query Problem

Bad

```csharp
foreach(var order in orders)
{
    var customer = context.Customers
        .First(x=>x.Id==order.CustomerId);
}
```

100 Orders

↓

101 SQL Queries

Better

```csharp
.Include(x=>x.Customer)
```

or

Projection

```csharp
.Select(...)
```

Single Query.

---

# Step 8: Check External APIs

Suppose

```
Order API

↓

Payment API

↓

Shipping API

↓

Notification API
```

Each takes

```
2 sec
```

Total

```
6 seconds
```

Measure individually.

Example

```csharp
var sw = Stopwatch.StartNew();

await paymentClient.Get();

sw.Stop();

Console.WriteLine(sw.ElapsedMilliseconds);
```

Output

```
Payment API

1980 ms
```

Found bottleneck.

---

# Step 9: Check Parallel Calls

Bad

```csharp
var payment = await GetPayment();

var shipment = await GetShipment();

var invoice = await GetInvoice();
```

Total

```
2 + 2 + 2

=

6 sec
```

Good

```csharp
var paymentTask = GetPayment();
var shipmentTask = GetShipment();
var invoiceTask = GetInvoice();

await Task.WhenAll(paymentTask,
                   shipmentTask,
                   invoiceTask);
```

Total

```
≈2 seconds
```

---

# Step 10: Check Thread Blocking

Bad

```csharp
Thread.Sleep(3000);
```

Bad

```csharp
Task.Result
```

Bad

```csharp
Task.Wait();
```

Good

```csharp
await Task.Delay(3000);
```

Always use async/await.

---

# Step 11: Check Connection Pool Exhaustion

Symptoms

```
Random delays

Timeout expired

Waiting for connection
```

Bad

```csharp
new SqlConnection()
```

Never disposed.

Good

```csharp
await using var connection = new SqlConnection(cs);
```

Also check

```
Max Pool Size
```

---

# Step 12: Check HTTP Client Usage

Bad

```csharp
new HttpClient();
```

inside every request.

Causes

```
Socket Exhaustion
```

Good

```csharp
builder.Services.AddHttpClient();
```

Use IHttpClientFactory.

---

# Step 13: Check Memory Usage

Monitor

- RAM
- GC Collections
- LOH

Tools

```
dotnet-counters

dotnet-trace

Visual Studio Diagnostic Tools

PerfView
```

Example

```
GC

Gen0 : 500/sec

Gen1 : 150/sec

Gen2 : 40/sec
```

Too many allocations.

---

# Step 14: Check CPU Usage

If CPU

```
95%
```

Look for

- Infinite loops
- Serialization
- LINQ
- Regex
- JSON Conversion

Use

```
dotnet-trace

Visual Studio Profiler
```

---

# Step 15: Check Serialization

Large Objects

```
20 MB JSON
```

Example

```csharp
return Ok(bigObject);
```

Instead

Return only required fields.

```csharp
.Select(...)
```

Compress Response

```csharp
app.UseResponseCompression();
```

---

# Step 16: Check Caching

Repeated query

```sql
SELECT *
FROM Countries
```

Runs

```
1000 times/minute
```

Use

```csharp
IMemoryCache
```

Example

```csharp
cache.GetOrCreate("Countries", ...);
```

Response

```
250 ms

↓

5 ms
```

---

# Step 17: Check Middleware

Too many middleware

```
Authentication

↓

Authorization

↓

Logging

↓

Compression

↓

Localization

↓

Custom Middleware

↓

Controller
```

Measure each.

---

# Step 18: Distributed Tracing

If Microservices

Use

- OpenTelemetry
- Jaeger
- Zipkin
- Azure Application Insights

See

```
API

↓

Service A

↓

Service B

↓

SQL

↓

Redis
```

Know exactly where time is spent.

---

# Step 19: Check Network Latency

Sometimes application is fast.

Network is slow.

Example

Server

```
20 ms
```

Browser

```
3 sec
```

Check

- DNS
- VPN
- Firewall
- Load Balancer
- Reverse Proxy

---

# Step 20: Load Testing

Use

- k6
- JMeter

Example

```
100 Users

↓

500 Users

↓

1000 Users
```

Observe

- CPU
- Memory
- Response Time
- SQL
- Errors

---

# Example Investigation Timeline

User reports:

```
GET /api/orders/12345

7.2 sec
```

### Step 1

Logs

```
Request

7200 ms
```

↓

### Step 2

SQL Query

```
5800 ms
```

↓

Execution Plan

```
Table Scan
```

↓

### Step 3

Added Index

```
5800 ms

↓

25 ms
```

↓

### Step 4

External Payment API

```
1900 ms
```

↓

### Step 5

Parallelized API Calls

```
1900 + 1800 + 1700

↓

1950 ms
```

↓

### Step 6

Enabled Memory Cache

```
Database

↓

No DB Hit
```

↓

### Final Result

| Stage | Before | After |
|---------|--------|-------|
| SQL | 5800 ms | 25 ms |
| External APIs | 6000 ms | 1950 ms |
| JSON Serialization | 300 ms | 60 ms |
| Total API Time | 7200 ms | 280 ms |

---

# Interview Answer (2-3 Minutes)

> "When an API is slow, I follow a structured approach instead of guessing. First, I reproduce the issue using Postman or a load testing tool and measure the response time. Then, I add detailed logging or use Application Insights/OpenTelemetry to identify where the time is spent—whether in middleware, business logic, database, or external API calls.
>
> If the database is slow, I inspect the generated SQL, execution plan, and look for table scans, missing indexes, N+1 query issues, or inefficient EF Core queries. For external services, I measure each dependency individually and parallelize independent calls using `Task.WhenAll`. I also check for blocking calls like `.Result` or `.Wait()`, verify proper use of `IHttpClientFactory`, monitor CPU, memory, and garbage collection, and use caching where appropriate. Finally, I validate improvements through load testing with k6 or JMeter to ensure the optimization scales under production traffic."
