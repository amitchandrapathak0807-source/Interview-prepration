# AsNoTracking() vs Tracking in Entity Framework Core
## Complete Guide with Simple Examples

> **Interview Level:** ⭐⭐⭐⭐⭐
>
> This is one of the most frequently asked EF Core interview questions.
>
> Almost every senior .NET interview asks:
>
> - What is Change Tracking?
> - What is `AsNoTracking()`?
> - When should you use it?
> - What happens internally?

---

# What is Change Tracking?

Before understanding `AsNoTracking()`, we first need to understand **Change Tracking**.

## Definition

Change Tracking is a feature of Entity Framework Core that **keeps track of every entity loaded into DbContext**.

It remembers:

- Original values
- Current values
- Entity state
- Modified properties

So later, when you call:

```csharp
await _context.SaveChangesAsync();
```

EF knows exactly what changed.

---

# Real World Analogy

Imagine a teacher checking assignments.

## Tracking Mode

Teacher writes down:

```
Student Name

Original Marks

Updated Marks
```

Teacher knows exactly what changed.

---

## AsNoTracking Mode

Teacher only reads the assignment.

No notes.

No memory.

If student changes the paper later,

Teacher doesn't know.

---

# Example Database

Customer Table

| Id | Name | City |
|----|------|------|
| 1 | Amit | Pune |
| 2 | Rahul | Delhi |

---

# Tracking Query (Default)

```csharp
var customer = await _context.Customers
    .FirstAsync(x => x.Id == 1);
```

No `AsNoTracking()`.

Default behavior:

```
Tracking Enabled
```

---

# Internal Working

```text
Database

↓

Customer Row

↓

Create Customer Object

↓

Store inside Change Tracker

↓

Return Object
```

---

# Memory

```text
DbContext

│

├── Customer Id = 1

│      State = Unchanged

│      Original Name = Amit

│      Current Name = Amit

│

└── Change Tracker
```

EF remembers this object.

---

# Now Change Data

```csharp
customer.Name = "Amit Sharma";
```

What happens?

EF notices

```
Original

↓

Amit

Current

↓

Amit Sharma
```

State becomes

```
Modified
```

---

# SaveChanges()

```csharp
await _context.SaveChangesAsync();
```

EF generates

```sql
UPDATE Customers

SET Name='Amit Sharma'

WHERE Id=1
```

Automatically.

No Update() call needed.

---

# Complete Example

```csharp
using var context = new AppDbContext();

var customer = await context.Customers
    .FirstAsync(x => x.Id == 1);

customer.Name = "Amit Sharma";

await context.SaveChangesAsync();
```

Output

Database updated.

---

# Now Let's Use AsNoTracking()

```csharp
var customer = await _context.Customers

.AsNoTracking()

.FirstAsync(x => x.Id == 1);
```

Now EF says

```
I'll just read.

I won't remember anything.
```

---

# Internal Working

```text
Database

↓

Customer Row

↓

Create Object

↓

Return Object

↓

Forget Everything
```

No Change Tracker.

---

# Memory

```text
DbContext

↓

Empty
```

No entity stored.

---

# Now Modify

```csharp
customer.Name = "Amit Sharma";
```

Object changes.

But EF doesn't know.

---

# SaveChanges()

```csharp
await context.SaveChangesAsync();
```

Generated SQL

```
Nothing
```

Database unchanged.

Because EF wasn't tracking.

---

# Complete Example

```csharp
using var context = new AppDbContext();

var customer = await context.Customers

.AsNoTracking()

.FirstAsync(x => x.Id == 1);

customer.Name = "Amit Sharma";

await context.SaveChangesAsync();
```

Result

```
No Update
```

---

# Why?

Because

```
Customer

never entered

Change Tracker
```

---

# Visual Comparison

## Tracking

```text
Database

↓

Customer

↓

Change Tracker

↓

Modify

↓

SaveChanges

↓

UPDATE SQL
```

---

## AsNoTracking

```text
Database

↓

Customer

↓

Return Object

↓

Modify

↓

SaveChanges

↓

Nothing
```

---

# Internal Memory Comparison

## Tracking

```text
DbContext

↓

Customer(1)

↓

State

Unchanged
```

Later

```text
Customer

↓

Modified
```

---

## AsNoTracking

```text
DbContext

↓

Empty
```

Always.

---

# Real Banking Example

Suppose

Customer Dashboard

Shows

- Name
- Balance
- Last Login

User only viewing.

Should EF track?

No.

Use

```csharp
_context.Customers

.AsNoTracking()
```

Much faster.

---

# Another Example

Transfer Money

Need

```
Load Account

↓

Debit

↓

Credit

↓

Save
```

Need Tracking.

```csharp
var account =
await _context.Accounts

.FirstAsync();
```

Tracking enabled.

---

# What Happens Internally?

Tracking

```
Entity

↓

Snapshot Created

↓

Original Values Stored

↓

Current Values Compared
```

AsNoTracking

```
Entity

↓

Return

↓

Done
```

No Snapshot.

---

# Performance Comparison

Imagine

```
100,000 Customers
```

Tracking

```
100,000 Objects

+

100,000 Snapshots

+

Dictionary Entries
```

Memory

High.

CPU

Higher.

---

AsNoTracking

```
100,000 Objects

Only
```

No Snapshot.

No Dictionary.

Lower Memory.

---

# Benchmark (Approximate)

| Operation | Tracking | AsNoTracking |
|------------|----------|--------------|
| Memory | High | Low |
| CPU | More | Less |
| Speed | Slower | Faster |
| Change Detection | Yes | No |
| SaveChanges | Works | No Effect |
| Read-only APIs | ❌ | ✅ Best Choice |

---

# When Should You Use Tracking?

When you

- Update data
- Delete data
- Insert related data
- SaveChanges()
- Business workflow

Example

```csharp
var customer = await context.Customers
    .FirstAsync();

customer.City = "Mumbai";

await context.SaveChangesAsync();
```

Perfect.

---

# When Should You Use AsNoTracking?

When

- Dashboard
- Reports
- Search Screen
- Read-only API
- Dropdown
- Export
- Analytics

Example

```csharp
var customers = await context.Customers

.AsNoTracking()

.ToListAsync();
```

Perfect.

---

# What If I Want to Update an AsNoTracking Entity?

Example

```csharp
var customer = await context.Customers

.AsNoTracking()

.FirstAsync();
```

Later

```csharp
customer.Name = "New Name";
```

Need

```csharp
context.Customers.Update(customer);

await context.SaveChangesAsync();
```

Now EF starts tracking again.

---

# Tracking States

EF keeps

| State | Meaning |
|---------|----------|
| Added | New Object |
| Modified | Changed |
| Deleted | Removed |
| Unchanged | Loaded |
| Detached | Not Tracked |

---

# How to Check?

```csharp
Console.WriteLine(

context.Entry(customer).State

);
```

Output

Tracking

```
Unchanged
```

After modification

```
Modified
```

AsNoTracking

```
Detached
```

---

# AsNoTrackingWithIdentityResolution()

A commonly asked senior interview question.

Suppose this query:

```csharp
var orders = await context.Orders
    .Include(o => o.Customer)
    .AsNoTracking()
    .ToListAsync();
```

If **100 orders belong to the same customer**:

With `AsNoTracking()`

```
Order1 → New Customer Object

Order2 → New Customer Object

Order3 → New Customer Object
```

100 different `Customer` instances.

More memory.

---

With

```csharp
.AsNoTrackingWithIdentityResolution()
```

```
Order1 ─┐
Order2 ─┼──► Same Customer Object
Order3 ─┘
```

No change tracking,

but EF avoids creating duplicate entity instances within that query.

---

# Common Mistakes

### Mistake 1

```csharp
var customer = await context.Customers

.AsNoTracking()

.FirstAsync();

customer.Name = "Amit";

await context.SaveChangesAsync();
```

Developer expects update.

Nothing happens.

---

### Mistake 2

Using Tracking for every API.

Example

Dashboard

Search

Reports

This wastes memory.

---

### Mistake 3

Using AsNoTracking everywhere.

Then wondering why updates don't work.

---

# Best Practices

✅ Read-only APIs

```csharp
AsNoTracking()
```

---

✅ Update APIs

```csharp
Tracking
```

---

✅ Large Reports

```csharp
Projection

+

AsNoTracking()
```

---

✅ High-performance APIs

```csharp
Select()

+

AsNoTracking()
```

---

# Interview Questions

## Beginner

### What is Change Tracking?

Tracks entity changes inside `DbContext`.

---

### What is AsNoTracking()?

Disables Change Tracking.

---

### Does AsNoTracking improve performance?

Yes.

Less memory.

Less CPU.

---

## Senior

### What happens internally when using AsNoTracking()?

- No snapshot is created.
- Entity is not stored in the Change Tracker.
- Entity state is `Detached`.
- `SaveChanges()` ignores modifications unless the entity is attached.

---

### When would you NOT use AsNoTracking()?

Whenever the entity will be updated in the same `DbContext`.

---

### Difference between AsNoTracking() and AsNoTrackingWithIdentityResolution()?

| Feature | AsNoTracking | AsNoTrackingWithIdentityResolution |
|----------|--------------|------------------------------------|
| Change Tracking | ❌ | ❌ |
| Duplicate Object Instances | Yes | No |
| Memory Usage | Lowest | Slightly Higher |
| Best For | Simple read-only queries | Read-only queries with repeated related entities |

---

# Easy Rule to Remember

| Scenario | Use |
|----------|-----|
| Read only | `AsNoTracking()` |
| Read + Update | Tracking (default) |
| Dashboard | `AsNoTracking()` |
| Search API | `AsNoTracking()` |
| Money Transfer | Tracking |
| Edit Customer | Tracking |
| Reporting | `AsNoTracking()` |
| Bulk Read | `AsNoTracking()` |

---

# One-Line Interview Answer

> **Tracking** means EF Core remembers the entity and automatically detects changes during `SaveChanges()`. **AsNoTracking()** skips the Change Tracker, reducing memory and CPU usage, making it ideal for read-only queries where no updates are required.
