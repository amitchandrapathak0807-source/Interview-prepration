# Repository Pattern & Unit of Work in C#
## Complete Guide (Beginner to Architect Level)

> **Interview Level:** ⭐⭐⭐⭐⭐ (Frequently Asked in Microsoft, UBS, Amazon, Goldman Sachs, JP Morgan, Point72, etc.)

These two patterns are among the most misunderstood design patterns in .NET interviews.

Many developers know **what** they are but fail to explain **why** they exist and **how they work internally**.

---

# Table of Contents

1. What Problem Do They Solve?
2. Repository Pattern
3. Unit of Work Pattern
4. Why Repository Alone is Not Enough
5. Why Unit of Work Exists
6. Internal Working
7. Complete Banking Example
8. Generic Repository
9. Unit of Work Implementation
10. Dependency Injection
11. EF Core Integration
12. Advantages & Disadvantages
13. Common Mistakes
14. Best Practices
15. Interview Questions (10+ Years)

---

# Why Do We Need These Patterns?

Imagine a Banking Application.

We have:

```
Customer
Account
Transaction
Loan
Notification
```

Suppose your controller directly accesses EF Core.

```csharp
public class AccountController : ControllerBase
{
    private readonly BankingDbContext _db;

    public AccountController(BankingDbContext db)
    {
        _db = db;
    }

    public async Task Create()
    {
        _db.Customers.Add(...);

        _db.Accounts.Add(...);

        _db.SaveChanges();
    }
}
```

Problems:

- Business logic inside controller
- Hard to test
- Hard to replace EF
- Duplicate queries
- Violates Separation of Concerns

---

# Real World Analogy

Imagine a Restaurant.

Customer

↓

Waiter

↓

Kitchen

Instead of

Customer

↓

Kitchen

Repository

=

Waiter

Database

=

Kitchen

You never directly talk to the kitchen.

---

# What is Repository Pattern?

## Definition

Repository Pattern acts as a layer between the Business Logic and the Database.

It hides database implementation details.

```
Controller

↓

Service

↓

Repository

↓

Entity Framework

↓

SQL Server
```

---

# Why Repository Exists?

Without Repository

Every service writes SQL.

```
OrderService

↓

SQL

CustomerService

↓

SQL

PaymentService

↓

SQL
```

Duplicate code.

Hard to maintain.

---

With Repository

```
OrderService

↓

OrderRepository

↓

Database
```

---

# Responsibilities of Repository

- CRUD Operations
- Query Database
- Hide EF Core
- Return Domain Objects
- Centralize Data Access

---

# Architecture

```mermaid
flowchart TD

Controller

-->

Service

-->

Repository

-->

DbContext

-->

SQL Server
```

---

# Generic Repository Interface

```csharp
public interface IRepository<T>
    where T : class
{
    Task<T?> GetByIdAsync(int id);

    Task<IEnumerable<T>> GetAllAsync();

    Task AddAsync(T entity);

    void Update(T entity);

    void Delete(T entity);
}
```

Notice

Repository doesn't know

Customer

Order

Employee

Only

```
T
```

Generic.

---

# Generic Repository Implementation

```csharp
public class Repository<T> : IRepository<T>
    where T : class
{
    protected readonly BankingDbContext _context;

    protected readonly DbSet<T> _dbSet;

    public Repository(BankingDbContext context)
    {
        _context = context;

        _dbSet = context.Set<T>();
    }

    public async Task<T?> GetByIdAsync(int id)
    {
        return await _dbSet.FindAsync(id);
    }

    public async Task<IEnumerable<T>> GetAllAsync()
    {
        return await _dbSet.ToListAsync();
    }

    public async Task AddAsync(T entity)
    {
        await _dbSet.AddAsync(entity);
    }

    public void Update(T entity)
    {
        _dbSet.Update(entity);
    }

    public void Delete(T entity)
    {
        _dbSet.Remove(entity);
    }
}
```

Notice

No SaveChanges()

Very important.

Why?

Wait.

---

# Customer Repository

Sometimes Generic Repository isn't enough.

Need business-specific methods.

```csharp
public interface ICustomerRepository
{
    Task<Customer?> GetByEmailAsync(string email);

    Task<IEnumerable<Customer>> GetPremiumCustomersAsync();
}
```

Implementation

```csharp
public class CustomerRepository
    : Repository<Customer>,
      ICustomerRepository
{
    public CustomerRepository(BankingDbContext context)
        : base(context)
    {
    }

    public async Task<Customer?> GetByEmailAsync(string email)
    {
        return await _context.Customers
            .FirstOrDefaultAsync(x => x.Email == email);
    }
}
```

---

# Problem with Repository Alone

Imagine Money Transfer.

Transfer

₹1000

Need

```
Update Account A

Update Account B

Insert Transaction

Insert Audit

Send Notification
```

Suppose

```csharp
_repository.Update(accountA);

_context.SaveChanges();
```

Success.

Then

```csharp
_repository.Update(accountB);
```

Fails.

Money deducted

But not credited.

Data corruption.

---

Need

```
Single Transaction
```

This is why Unit of Work exists.

---

# What is Unit of Work?

## Definition

Unit of Work groups multiple database operations into one transaction.

Either

Everything succeeds

OR

Everything fails.

---

# Real World Analogy

Imagine Online Shopping.

You order:

- Laptop
- Mouse
- Keyboard

Payment fails.

Should Amazon ship only Laptop?

No.

Everything rolls back.

That's Unit of Work.

---

# Architecture

```mermaid
flowchart TD

Controller

-->

Service

-->

UnitOfWork

-->

Repository1

Repository2

Repository3

-->

DbContext

-->

SQL Server
```

---

# Unit of Work Interface

```csharp
public interface IUnitOfWork
{
    ICustomerRepository Customers
    {
        get;
    }

    IAccountRepository Accounts
    {
        get;
    }

    ITransactionRepository Transactions
    {
        get;
    }

    Task<int> SaveChangesAsync();

    Task BeginTransactionAsync();

    Task CommitAsync();

    Task RollbackAsync();
}
```

---

# Unit of Work Implementation

```csharp
public class UnitOfWork : IUnitOfWork
{
    private readonly BankingDbContext _context;

    public ICustomerRepository Customers
    {
        get;
    }

    public IAccountRepository Accounts
    {
        get;
    }

    public ITransactionRepository Transactions
    {
        get;
    }

    public UnitOfWork(
        BankingDbContext context,
        ICustomerRepository customerRepository,
        IAccountRepository accountRepository,
        ITransactionRepository transactionRepository)
    {
        _context = context;

        Customers = customerRepository;

        Accounts = accountRepository;

        Transactions = transactionRepository;
    }

    public async Task<int> SaveChangesAsync()
    {
        return await _context.SaveChangesAsync();
    }

    public async Task BeginTransactionAsync()
    {
        await _context.Database.BeginTransactionAsync();
    }

    public async Task CommitAsync()
    {
        await _context.Database.CommitTransactionAsync();
    }

    public async Task RollbackAsync()
    {
        await _context.Database.RollbackTransactionAsync();
    }
}
```

---

# Complete Banking Example

Money Transfer

```text
Customer A

↓

Debit ₹1000

↓

Customer B

↓

Credit ₹1000

↓

Insert Transaction

↓

Insert Audit

↓

Commit
```

Service

```csharp
public class TransferService
{
    private readonly IUnitOfWork _unitOfWork;

    public TransferService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task TransferAsync()
    {
        await _unitOfWork.BeginTransactionAsync();

        try
        {
            var sender =
                await _unitOfWork.Accounts.GetByIdAsync(1);

            var receiver =
                await _unitOfWork.Accounts.GetByIdAsync(2);

            sender.Balance -= 1000;

            receiver.Balance += 1000;

            _unitOfWork.Accounts.Update(sender);

            _unitOfWork.Accounts.Update(receiver);

            await _unitOfWork.Transactions.AddAsync(
                new Transaction());

            await _unitOfWork.SaveChangesAsync();

            await _unitOfWork.CommitAsync();
        }
        catch
        {
            await _unitOfWork.RollbackAsync();

            throw;
        }
    }
}
```

---

# Internal Working

```text
Request

↓

DbContext Created

↓

Repository uses same DbContext

↓

Entity Framework Change Tracker

↓

Tracks Changes

↓

SaveChanges()

↓

Generates SQL

↓

Transaction

↓

Commit

↓

Dispose DbContext
```

---

# How EF Core Change Tracker Helps

```csharp
customer.Name = "Amit";

account.Balance -= 500;
```

No SQL yet.

EF tracks changes.

When

```csharp
SaveChanges()
```

EF generates

```sql
UPDATE Customer...

UPDATE Account...
```

inside one transaction.

---

# Repository vs Unit of Work

| Repository | Unit of Work |
|------------|--------------|
| Accesses one table/entity | Coordinates multiple repositories |
| CRUD Operations | Transaction Management |
| Query Logic | Commit/Rollback |
| Focused on data access | Focused on consistency |
| No transaction logic | Owns transaction boundary |

---

# Advantages

## Repository

- Separation of Concerns
- Easy Unit Testing
- Reusable Queries
- Cleaner Controllers
- Better Maintainability

---

## Unit of Work

- Atomic Transactions
- Consistency
- Rollback Support
- Multiple Repositories
- Prevent Partial Updates

---

# Disadvantages

## Repository

- Can become unnecessary with simple EF Core usage.
- Too many repositories may increase boilerplate code.

## Unit of Work

- EF Core's `DbContext` already behaves like a Unit of Work.
- Adding another abstraction may be redundant if it only wraps `SaveChanges()`.

---

# Repository + Unit of Work in EF Core

This is one of the most common interview questions.

**Important:**

`DbContext` already provides:

- Change Tracking
- Transactions
- SaveChanges()
- Repository-like access through `DbSet<T>`

So why create Repository + Unit of Work?

Reasons:

- Hide EF Core from business layer.
- Easier testing and mocking.
- Centralize reusable queries.
- Support changing ORM (rare in practice).
- Enforce architecture boundaries.

---

# Dependency Injection

```csharp
builder.Services.AddScoped<
    ICustomerRepository,
    CustomerRepository>();

builder.Services.AddScoped<
    IUnitOfWork,
    UnitOfWork>();
```

Scoped lifetime is recommended because one HTTP request should use one `DbContext`.

---

# Common Mistakes

❌ Calling `SaveChanges()` inside every repository method.

```csharp
Add();

SaveChanges();
```

Each repository commits independently.

This breaks transaction consistency.

---

❌ Creating a new `DbContext` in every repository.

Each repository would have its own transaction.

Always share the same scoped `DbContext`.

---

❌ Returning `IQueryable` directly from repositories without clear boundaries.

This leaks persistence concerns into higher layers.

---

❌ Creating one repository for every tiny query.

Use repositories to encapsulate meaningful business data access.

---

# Best Practices

- Use **one `DbContext` per request** (`Scoped` lifetime).
- Call `SaveChanges()` once per business transaction.
- Keep business logic in Services, not Repositories.
- Keep repositories focused on persistence.
- Use asynchronous APIs.
- Wrap multi-step business operations in transactions.
- Log transaction failures.
- Use optimistic concurrency (`RowVersion`) where needed.

---

# Production Perspective

### Banking (UBS)

Money transfer:

- Debit Account
- Credit Account
- Insert Transaction
- Insert Audit
- Publish Event

All should succeed or fail together.

---

### Amazon

Order placement:

- Create Order
- Reserve Inventory
- Create Payment Record
- Create Shipment Request

Commit once.

---

### Healthcare

Patient registration:

- Create Patient
- Create Insurance Record
- Create Medical History
- Assign Doctor

Rollback everything if any step fails.

---

# Interview Questions

## Beginner (5)

1. What is the Repository Pattern?
2. Why do we use a Repository instead of `DbContext` directly?
3. What is the Unit of Work Pattern?
4. What is the difference between Repository and Unit of Work?
5. Why shouldn't repositories call `SaveChanges()`?

---

## Intermediate (5)

1. How does EF Core implement Unit of Work internally?
2. Why should repositories share the same `DbContext`?
3. When would you create a custom repository instead of using a generic one?
4. What is the role of Change Tracker?
5. How do transactions work with `SaveChanges()`?

---

## Senior (10)

1. Is Repository Pattern still useful with EF Core? Explain the trade-offs.
2. Why is `DbContext` considered both a Repository and Unit of Work?
3. How would you implement distributed transactions across microservices?
4. How would you handle concurrency conflicts using `RowVersion`?
5. Should repositories expose `IQueryable`? Why or why not?
6. How do you design repositories for CQRS?
7. How do you unit test services using repositories?
8. What are the drawbacks of a Generic Repository?
9. How do you optimize repository performance for read-heavy workloads?
10. How do repositories fit into Clean Architecture?

---

# Interview Questions (10+ Years Experience)

## 1. Does EF Core already implement Repository and Unit of Work?

**Why Interviewers Ask**

To determine whether you understand EF Core internals rather than just applying patterns mechanically.

**Expected Answer**

Yes.

- `DbSet<TEntity>` behaves like a Repository.
- `DbContext` behaves like a Unit of Work because it tracks entity changes and commits them through `SaveChanges()`.

However, custom repositories may still provide value by encapsulating business-specific queries and hiding ORM details.

---

## 2. Why is calling `SaveChanges()` inside a repository a bad practice?

**Ideal Answer**

It creates multiple independent transactions and prevents atomic business operations spanning multiple repositories.

---

## 3. Would you always use Repository Pattern with EF Core?

**Ideal Answer**

No.

For small CRUD applications, injecting `DbContext` directly is often sufficient. In large enterprise systems with complex business rules, reusable queries, and architectural boundaries, repositories can improve maintainability.

---

## 4. How would you implement money transfer across two microservices?

**Ideal Answer**

Do **not** use a database transaction across services. Use:

- Saga Pattern
- Outbox Pattern
- Event-driven architecture
- Idempotent consumers
- Compensation logic

---

## 5. What is the biggest mistake teams make with Generic Repositories?

**Ideal Answer**

Treating them as a one-size-fits-all abstraction. Generic repositories often become too generic for complex queries or too bloated with entity-specific methods. Strike a balance by combining a generic base repository with specialized repositories where needed.

---

# Key Takeaways

- **Repository Pattern** abstracts data access.
- **Unit of Work** ensures multiple operations succeed or fail together.
- **Repository ≠ Transaction Manager**.
- **Unit of Work = Transaction Boundary**.
- In EF Core:
  - `DbSet<T>` acts like a Repository.
  - `DbContext` acts like a Unit of Work.
- Use custom repositories when they add business value, not just to wrap EF Core.
- Keep `SaveChanges()` at the application/service level, not inside repositories.
- For microservices, prefer sagas and eventual consistency over distributed database transactions.
