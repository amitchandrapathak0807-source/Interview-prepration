# Entity Framework (EF Core) Interview Questions
## Complete Interview Guide (Beginner → Architect | 10+ Years Experience)

> **Companies**
>
> - Microsoft
> - Amazon
> - UBS
> - Goldman Sachs
> - JP Morgan
> - Morgan Stanley
> - Point72
> - Oracle
> - Adobe

---

# Beginner Level (10 Questions)

## 1. What is Entity Framework?

### Expected Answer

Entity Framework (EF Core) is Microsoft's ORM (Object Relational Mapper) that maps C# objects to database tables.

Instead of writing SQL manually:

```sql
SELECT *
FROM Customers
WHERE Id = 1
```

You write

```csharp
var customer = await _context.Customers
    .FindAsync(1);
```

---

## 2. What is ORM?

Expected Answer

ORM converts

```
C# Objects

↓

Database Tables

↓

Back to Objects
```

Example

```csharp
Customer customer = new Customer();
```

becomes

```
Customer Table
```

---

## 3. Difference between EF6 and EF Core?

| EF6 | EF Core |
|------|----------|
| Windows only | Cross-platform |
| Slower | Faster |
| Old Architecture | Modern Architecture |
| Full Framework | .NET Core/.NET |
| Less Performance | Better Performance |

---

## 4. What is DbContext?

Expected Answer

DbContext is the heart of EF Core.

Responsibilities

- Database Connection
- Change Tracking
- Transactions
- SaveChanges()
- LINQ Translation
- Identity Resolution

Think of it as

```
Session

between

Application

and

Database
```

---

## 5. What is DbSet?

Example

```csharp
public DbSet<Customer> Customers { get; set; }
```

Represents

```
Customer Table
```

Supports

- Add
- Update
- Delete
- Query

---

## 6. What is Change Tracking?

EF tracks

```
Added

Modified

Deleted

Unchanged
```

Example

```csharp
customer.Name = "Amit";
```

No SQL yet.

SQL generated only after

```csharp
SaveChanges();
```

---

## 7. Difference between SaveChanges and SaveChangesAsync?

SaveChanges()

```
Synchronous
```

SaveChangesAsync()

```
Non-blocking

Recommended for APIs
```

---

## 8. What is Migration?

Migration is EF's mechanism to version-control database schema changes.

Commands

```bash
dotnet ef migrations add InitialCreate

dotnet ef database update
```

---

## 9. What is Scaffold?

Reverse engineering.

Database

↓

Generate

```
DbContext

Entities
```

Command

```bash
dotnet ef dbcontext scaffold
```

---

## 10. What is LINQ?

Language Integrated Query

Example

```csharp
var customers =
_context.Customers
.Where(x=>x.City=="Pune");
```

---

# Intermediate Level (15 Questions)

---

## 1. How does EF Core translate LINQ?

Example

```csharp
_context.Customers
.Where(x=>x.City=="Pune");
```

Pipeline

```
LINQ

↓

Expression Tree

↓

Query Compiler

↓

SQL Generator

↓

SQL Server

↓

Results

↓

Materialization

↓

Objects
```

---

## 2. What is IQueryable?

Deferred execution.

SQL isn't generated immediately.

```csharp
var query =
_context.Customers
.Where(x=>x.IsActive);
```

No SQL.

SQL generated only after

```csharp
ToList();
```

---

## 3. Difference between IQueryable and IEnumerable?

| IQueryable | IEnumerable |
|------------|--------------|
| Database Query | In Memory |
| SQL Generated | No SQL |
| Lazy | Immediate |
| Better Performance | More Memory |

---

## 4. What is Deferred Execution?

SQL executes only when needed.

```csharp
var query =
_context.Customers;

query.Where(x=>x.City=="Delhi");

query.OrderBy(x=>x.Name);

query.ToList();
```

One SQL generated.

---

## 5. What is AsNoTracking()?

Disables Change Tracking.

```csharp
_context.Customers
.AsNoTracking()
.ToListAsync();
```

Benefits

- Faster
- Less Memory
- Read-only

---

## 6. What is Eager Loading?

```csharp
.Include(x=>x.Orders)
```

Loads related data immediately.

---

## 7. Lazy Loading?

Loads when accessed.

```csharp
customer.Orders
```

Triggers SQL.

---

## 8. Explicit Loading?

```csharp
_context.Entry(customer)

.Collection(x=>x.Orders)

.Load();
```

---

## 9. Difference?

| Type | SQL Calls |
|------|-----------|
| Lazy | Multiple |
| Eager | Single |
| Explicit | Controlled |

---

## 10. What is N+1 Query Problem?

Wrong

```csharp
foreach(var customer in customers)
{
    Console.WriteLine(customer.Orders.Count);
}
```

Produces

```
1 query

+

1000 queries
```

Correct

```csharp
.Include(x=>x.Orders)
```

---

## 11. What is Projection?

Instead of

```csharp
SELECT *
```

Use

```csharp
.Select(x=>new CustomerDto
{
Name=x.Name
});
```

Less Data

Better Performance

---

## 12. First vs Single?

| First | Single |
|---------|---------|
| Returns first | Expects exactly one |
| Doesn't fail if multiple | Throws exception |

---

## 13. Find vs FirstOrDefault?

Find()

Uses cache first.

Faster.

---

## 14. Add vs AddAsync?

AddAsync

Only useful for async value generators.

Usually

```csharp
Add()
```

is enough.

---

## 15. Attach vs Update?

Attach

```
Unchanged
```

Update

```
Modified
```

---

# Senior Level (20 Questions)

---

## 1. Explain Change Tracker Internals

States

```
Added

Modified

Deleted

Detached

Unchanged
```

EF compares original values with current values.

Only changed columns are updated.

---

## 2. What happens internally during SaveChanges()?

Pipeline

```
Detect Changes

↓

Validate

↓

Generate SQL

↓

Begin Transaction

↓

Execute SQL

↓

Commit

↓

Accept Changes
```

---

## 3. Explain Identity Resolution

Same entity

Loaded twice

EF returns same object reference.

Not duplicate objects.

---

## 4. What is Optimistic Concurrency?

Uses

```
RowVersion
```

```csharp
[Timestamp]

byte[] RowVersion
```

---

## 5. How does EF detect concurrency conflict?

SQL

```sql
UPDATE Customer

SET Name='Amit'

WHERE

Id=1

AND

RowVersion=@OldVersion
```

No rows updated

↓

Concurrency Exception

---

## 6. How to improve EF performance?

Expected Answer

- AsNoTracking
- Projection
- Compiled Queries
- Bulk Insert
- Split Queries
- Avoid Lazy Loading
- Batch Updates
- Proper Indexes

---

## 7. Explain Split Query

```csharp
.AsSplitQuery()
```

Avoids Cartesian Explosion.

---

## 8. What is Cartesian Explosion?

```
Customer

Orders

Payments

Addresses
```

One huge JOIN

Millions of duplicate rows.

---

## 9. Explain Compiled Query

Compile LINQ once.

Reuse.

Less CPU.

---

## 10. ExecuteUpdate?

EF7+

```csharp
await _context.Customers

.Where(x=>x.Active)

.ExecuteUpdateAsync(...);
```

No entities loaded.

Very fast.

---

## 11. ExecuteDelete?

Deletes directly.

No tracking.

---

## 12. Batch SaveChanges

EF batches SQL.

Fewer network trips.

---

## 13. Global Query Filters

Example

Soft Delete.

```csharp
HasQueryFilter(x=>!x.IsDeleted)
```

---

## 14. Shadow Properties

Property

Exists in DB

Not in C# class.

---

## 15. Owned Entity

Example

Address

Owned by Customer.

No separate identity.

---

## 16. Value Converter

Store Enum

As String.

---

## 17. Value Comparer

Custom equality.

Useful for collections.

---

## 18. Interceptors

Intercept

- Query
- Save
- Connection

---

## 19. Explain Transactions

```csharp
BeginTransaction

Commit

Rollback
```

---

## 20. Repository Pattern vs DbContext?

Modern answer

DbContext already

- Repository
- Unit Of Work

Custom Repository only when needed.

---

# Architect Level (15 Questions)

---

## 1. Why does DbContext have Scoped Lifetime?

One request

↓

One DbContext

Avoids

- Thread issues
- Memory leaks
- Stale tracking

---

## 2. Is DbContext Thread Safe?

No.

Never share across threads.

---

## 3. How would you handle millions of inserts?

Expected Answer

- Bulk Insert
- SqlBulkCopy
- EF Extensions
- Disable Tracking
- Batch

---

## 4. How to avoid memory leaks?

- Dispose DbContext
- AsNoTracking
- Pagination

---

## 5. When not to use EF?

- Huge bulk operations
- Complex reporting
- High-frequency trading
- Massive ETL

Use

```
Dapper

ADO.NET

SqlBulkCopy
```

---

## 6. Explain Connection Pooling

ADO.NET pools physical SQL connections.

DbContext itself is **not** pooled unless you explicitly configure DbContext pooling.

---

## 7. Explain DbContext Pooling

```csharp
builder.Services.AddDbContextPool<AppDbContext>();
```

Reuses DbContext instances.

Lower allocations.

---

## 8. Explain EF Pipeline

```
LINQ

↓

Expression Tree

↓

Query Compiler

↓

SQL

↓

ADO.NET

↓

SQL Server

↓

Result

↓

Materialization

↓

Tracking
```

---

## 9. Explain Materialization

Database rows

↓

Objects

---

## 10. Explain SQL Generation

EF converts

```
Expression Tree

↓

SQL
```

---

## 11. Explain Query Cache

Same LINQ

↓

Compiled

↓

Reused

---

## 12. Explain Compiled Models

EF Core 6+

Startup faster.

Large applications.

---

## 13. Explain Database Interceptors

Logging

Auditing

Security

Caching

---

## 14. Explain Execution Strategy

Automatic retry

Azure SQL

Transient Faults

---

## 15. Explain Resiliency

Retry

Circuit Breaker

Timeout

Cancellation Token

---

# 10+ Years Experience Interview Questions

---

## 1. Explain the entire lifecycle of an EF query.

Expected Answer

```
LINQ

↓

Expression Tree

↓

Query Translation

↓

Query Optimization

↓

Query Compilation

↓

Cache Lookup

↓

SQL Generation

↓

ADO.NET

↓

SQL Server

↓

Execution Plan

↓

Result

↓

Materialization

↓

Change Tracker
```

---

## 2. Why is DbContext not thread-safe?

### Why Interviewers Ask

To test understanding of EF Core internals.

### Expected Answer

`DbContext` maintains mutable state such as:

- Change Tracker
- Entity State Manager
- Identity Map
- Transactions

Concurrent access can corrupt this internal state or cause inconsistent tracking. Use one scoped `DbContext` per request and never share it across threads.

---

## 3. Why is Lazy Loading dangerous?

Expected Answer

Causes

- N+1 Queries
- Hidden SQL
- Performance issues

Prefer

```
Projection

Include()

Explicit Loading
```

---

## 4. Why does AsNoTracking improve performance?

Expected Answer

EF skips:

- Change Tracker
- Snapshot creation
- Identity resolution (unless using `AsNoTrackingWithIdentityResolution`)

Result

- Lower memory
- Faster queries

---

## 5. Difference between ExecuteUpdate and Update?

| ExecuteUpdate | Update |
|--------------|---------|
| Direct SQL | Loads Entity |
| No Tracking | Uses Tracking |
| Faster | Slower |
| Best for bulk updates | Best for domain logic |

---

## 6. How would you optimize a slow EF query?

Expected Answer

1. Check generated SQL using `ToQueryString()`.
2. View SQL Server execution plan.
3. Verify indexes.
4. Use projection instead of loading entire entities.
5. Apply `AsNoTracking()` for read-only queries.
6. Avoid `Include()` if unnecessary.
7. Use pagination (`Skip`/`Take`).
8. Consider compiled queries for hot paths.

---

## 7. What is the biggest mistake developers make with EF?

Expected Answer

Treating EF like an in-memory collection.

Example

```csharp
var customers =
_context.Customers.ToList();

customers.Where(x=>x.City=="Pune");
```

This loads the entire table into memory before filtering.

Instead

```csharp
var customers =
await _context.Customers
.Where(x=>x.City=="Pune")
.ToListAsync();
```

The filtering happens in SQL.

---

## 8. When would you choose Dapper over EF Core?

Expected Answer

- High-performance read-heavy APIs
- Complex reporting queries
- Stored procedure-heavy systems
- Low-latency financial/trading applications

Use EF Core when domain modeling, change tracking, and productivity are more important than squeezing out every millisecond.

---

## 9. How do you debug EF Core performance issues?

### Visual Studio

- Diagnostic Tools
- Memory Usage
- CPU Usage

### EF Core

```csharp
optionsBuilder
    .LogTo(Console.WriteLine)
    .EnableSensitiveDataLogging();
```

Useful APIs

```csharp
query.ToQueryString();
```

### SQL Server

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
```

View the Actual Execution Plan (`Ctrl + M`).

---

## 10. What are the most important EF Core best practices in production?

- Use one scoped `DbContext` per request.
- Prefer async APIs.
- Use `AsNoTracking()` for read-only queries.
- Project to DTOs instead of loading full entities.
- Avoid Lazy Loading in APIs.
- Keep transactions short.
- Add indexes for frequently filtered columns.
- Use optimistic concurrency (`RowVersion`) where appropriate.
- Log generated SQL in non-production debugging environments.
- Profile SQL regularly rather than assuming EF is the bottleneck.

---

