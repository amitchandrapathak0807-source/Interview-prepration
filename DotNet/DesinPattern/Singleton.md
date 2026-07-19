# Singleton Design Pattern in C# (Complete Interview Guide)

---

# What is the Singleton Pattern?

The **Singleton Pattern** is a **Creational Design Pattern** that ensures:

1. **Only one instance** of a class exists throughout the application's lifetime.
2. A **global access point** is provided to access that instance.

---

## Real World Example

Think of the **CEO of a company**.

```
Company

             CEO
              │
     ┌────────┼────────┐
     │        │        │
   HR Team  IT Team  Finance
```

There is only **one CEO**.

Everyone uses the same CEO.

Singleton works exactly the same way.

---

# Why do we need Singleton?

Imagine a logging service.

Without Singleton

```
Request 1
    │
    ▼
 Logger Instance 1

Request 2
    │
    ▼
 Logger Instance 2

Request 3
    │
    ▼
 Logger Instance 3
```

Three logger objects are created.

This wastes memory and may produce inconsistent logs.

With Singleton

```
Request 1
       │
       ▼
      Logger
      ▲   ▲
      │   │
Request2 Request3
```

Only one Logger object exists.

---

# Basic Singleton Implementation

```csharp
public class Logger
{
    private static Logger _instance;

    private Logger()
    {
    }

    public static Logger GetInstance()
    {
        if (_instance == null)
        {
            _instance = new Logger();
        }

        return _instance;
    }
}
```

Usage

```csharp
Logger logger1 = Logger.GetInstance();
Logger logger2 = Logger.GetInstance();

Console.WriteLine(logger1 == logger2);
```

Output

```
True
```

Both variables reference the same object.

---

# How does it work internally?

Step 1

```
_instance

↓

null
```

Step 2

```
GetInstance()

↓

_instance == null

↓

Create Logger
```

Memory

```
Logger

↓

Object Created
```

Second call

```
GetInstance()

↓

_instance != null

↓

Return Existing Object
```

No new object is created.

---

# Problem with Basic Singleton

Suppose two threads execute simultaneously.

```
Thread A

↓

_instance == null

---------------------

Thread B

↓

_instance == null
```

Both create objects.

Result

```
Logger1

Logger2
```

Singleton is broken.

---

# Thread-Safe Singleton

```csharp
public class Logger
{
    private static Logger _instance;

    private static readonly object _lock = new();

    private Logger()
    {
    }

    public static Logger GetInstance()
    {
        lock (_lock)
        {
            if (_instance == null)
            {
                _instance = new Logger();
            }

            return _instance;
        }
    }
}
```

Now

```
Thread A

↓

Lock

↓

Create Object

↓

Unlock

---------------------

Thread B

↓

Wait

↓

Return Existing Object
```

Only one object is created.

---

# Problem with lock

Every call

```
GetInstance()

↓

lock()

↓

Return Object
```

Even when object already exists.

This causes unnecessary locking.

---

# Double Checked Locking

```csharp
public class Logger
{
    private static Logger _instance;

    private static readonly object _lock = new();

    private Logger()
    {
    }

    public static Logger GetInstance()
    {
        if (_instance == null)
        {
            lock (_lock)
            {
                if (_instance == null)
                {
                    _instance = new Logger();
                }
            }
        }

        return _instance;
    }
}
```

Flow

```
Instance Exists?

↓

Yes

↓

Return

(No Lock)

---------------------

Instance Missing?

↓

Take Lock

↓

Create Object
```

This improves performance.

---

# Best Practice - Lazy<T>

.NET already provides a thread-safe implementation.

```csharp
public sealed class Logger
{
    private static readonly Lazy<Logger> _instance =
        new(() => new Logger());

    private Logger()
    {
    }

    public static Logger Instance => _instance.Value;
}
```

Usage

```csharp
Logger logger = Logger.Instance;
```

Advantages

- Thread-safe
- Lazy initialization
- Cleaner code
- No manual locking

---

# Eager Initialization

Object is created when application starts.

```csharp
public sealed class Logger
{
    private static readonly Logger _instance = new();

    private Logger()
    {
    }

    public static Logger Instance => _instance;
}
```

Memory

```
Application Starts

↓

Logger Created

↓

Never Destroyed
```

---

# Lazy vs Eager

| Lazy | Eager |
|-------|--------|
| Created when needed | Created at startup |
| Saves memory | Faster access later |
| Better for expensive objects | Better for lightweight objects |

---

# Why is the constructor private?

If constructor were public

```csharp
Logger l1 = new Logger();

Logger l2 = new Logger();
```

Two objects would exist.

Singleton would fail.

Private constructor prevents this.

---

# Why static Instance?

Because

```
Application

↓

No Object Yet

↓

Need Access

↓

Logger.Instance
```

Static members can be accessed without creating an object.

---

# Why sealed?

```csharp
public sealed class Logger
{
}
```

Prevents inheritance.

Otherwise

```csharp
class MyLogger : Logger
{
}
```

Multiple instances could exist through inheritance.

---

# Real Production Example

Configuration Manager

```csharp
public sealed class ConfigurationManager
{
    private static readonly Lazy<ConfigurationManager> _instance =
        new(() => new ConfigurationManager());

    private ConfigurationManager()
    {
    }

    public static ConfigurationManager Instance => _instance.Value;

    public string ConnectionString =>
        "Server=SQL01;Database=Orders;";
}
```

Usage

```csharp
Console.WriteLine(ConfigurationManager.Instance.ConnectionString);
```

---

# ASP.NET Core Singleton

Instead of implementing manually

Use Dependency Injection.

```csharp
builder.Services.AddSingleton<ILogger, Logger>();
```

Now

```
Application

↓

DI Container

↓

Logger

▲ ▲ ▲

Controllers

Services

Repositories
```

Same instance is injected everywhere.

---

# Where Singleton is used?

- Logging
- Configuration
- Cache Manager
- Feature Flags
- Connection Pool Manager
- Application Settings
- In-memory Metadata

---

# Where NOT to use Singleton?

Don't store user-specific information.

Bad Example

```csharp
public class CurrentUser
{
    public string Name { get; set; }
}
```

Registered as Singleton

```
User A

↓

Name = Amit

---------------------

User B

↓

Name = John
```

Now User A also sees "John".

Never store request-specific data inside Singleton.

---

# Singleton vs Static Class

| Singleton | Static Class |
|------------|--------------|
| One Object | No Object |
| Can implement interfaces | Cannot implement interfaces |
| Can use Dependency Injection | Cannot |
| Can implement inheritance | Static classes cannot inherit |
| Can maintain object state | Only static state |

Singleton

```csharp
ILogger logger = Logger.Instance;
```

Static

```csharp
Logger.Log();
```

---

# Advantages

- Only one object
- Saves memory
- Global access
- Easy to share configuration
- Thread-safe (if implemented correctly)

---

# Disadvantages

- Global state
- Harder to unit test if used directly
- Hidden dependencies
- Can become a bottleneck
- Violates Single Responsibility Principle if overused

---

# Common Interview Questions

---

## 1. What is Singleton?

### Answer

Singleton is a Creational Design Pattern that ensures only one instance of a class exists and provides a global access point to that instance.

---

## 2. Why is constructor private?

### Answer

To prevent external code from creating multiple instances using the `new` keyword.

---

## 3. Why is Instance static?

### Answer

Because the object must be accessible before any instance exists. Static members belong to the class, not an object.

---

## 4. Why is Singleton useful?

### Answer

It avoids unnecessary object creation and provides a shared instance for components like logging, configuration, and caching.

---

## 5. Is Singleton thread-safe?

### Answer

The basic implementation is **not thread-safe**.

Two threads may create two objects simultaneously.

Use

- `lock`
- Double Checked Locking
- `Lazy<T>`
- Dependency Injection

---

## 6. Which Singleton implementation is best?

### Answer

`Lazy<T>` is the preferred manual implementation because it is thread-safe, simple, and supports lazy initialization.

In ASP.NET Core, prefer:

```csharp
builder.Services.AddSingleton<TService, TImplementation>();
```

---

## 7. What is Lazy Initialization?

### Answer

Object is created only when first needed.

Example

```csharp
private static readonly Lazy<Logger> _instance =
    new(() => new Logger());
```

---

## 8. What is Eager Initialization?

### Answer

Object is created immediately when the application starts.

```csharp
private static readonly Logger _instance = new();
```

---

## 9. Difference between Lazy and Eager Initialization?

| Lazy | Eager |
|-------|--------|
| Created on demand | Created immediately |
| Saves memory | Faster first access |
| Good for expensive objects | Good for lightweight objects |

---

## 10. Why use sealed?

### Answer

To prevent inheritance and accidental creation of additional instances.

---

## 11. Can Singleton have multiple constructors?

### Answer

No public constructors.

Private constructors are allowed.

---

## 12. Difference between Singleton and Static Class?

| Singleton | Static |
|------------|---------|
| Object Exists | No Object |
| Supports Interfaces | No |
| Supports DI | No |
| Can be Mocked | Difficult but possible |
| Can Have State | Static State Only |

---

## 13. Why does ASP.NET Core recommend AddSingleton() instead of manual Singleton?

### Answer

The DI container manages

- Lifetime
- Thread safety
- Dependency injection
- Disposal of resources

This results in cleaner and more testable code.

---

## 14. What problems can Singleton cause?

### Answer

- Global mutable state
- Hidden dependencies
- Difficult unit testing
- Memory retained for entire application lifetime
- Thread-safety issues if implemented incorrectly

---

## 15. What are real-world examples of Singleton?

- Logger
- Configuration Manager
- Feature Flag Manager
- Cache Manager
- Metadata Provider
- Connection Pool Manager

---

## 16. Can Singleton cause memory leaks?

### Answer

Yes.

A Singleton lives for the application's lifetime.

If it stores large collections that are never cleared, memory usage can continuously grow.

Example

```csharp
public sealed class Cache
{
    public static Dictionary<int, Customer> Customers = new();
}
```

If entries are never removed, memory usage will keep increasing.

---

## 17. Is Singleton always a good idea?

### Answer

No.

Use it only when exactly one shared instance is required.

For request-specific data, use Scoped services.

For lightweight stateless services, Transient may be more appropriate.

---

# Senior Interview Answer (2 Minutes)

> "The Singleton pattern is a creational design pattern that ensures only one instance of a class exists and provides a global access point to it. It's commonly used for shared resources like logging, configuration, and caching. A basic Singleton isn't thread-safe because multiple threads can create multiple instances simultaneously. To make it thread-safe, we can use locking, double-checked locking, or, preferably, `Lazy<T>`, which provides built-in lazy initialization and thread safety. In modern ASP.NET Core applications, I generally don't implement Singleton manually. Instead, I register the service using `AddSingleton()` in the dependency injection container, which manages lifetime, thread safety, and disposal automatically."
