# SOLID Principles - Easy Interview Guide (C# Example)

## What is SOLID?

SOLID is a set of **5 object-oriented design principles** that help us write code that is:

* Easy to understand
* Easy to maintain
* Easy to test
* Easy to extend
* Less tightly coupled

Think of SOLID as **rules for writing clean code**.

---

# Easy Way to Remember

```text
S → Single Responsibility Principle

O → Open/Closed Principle

L → Liskov Substitution Principle

I → Interface Segregation Principle

D → Dependency Inversion Principle
```

---

# Example We'll Use

Imagine we're building an **Order Management System**.

An order goes through these steps:

```text
Create Order

↓

Calculate Total

↓

Save to Database

↓

Send Email
```

We'll use this example to understand each principle.

---

# 1. S - Single Responsibility Principle (SRP)

## Definition

> A class should have only **one reason to change**.

### ❌ Bad Example

One class does everything.

```csharp
public class OrderService
{
    public void CalculateTotal() { }

    public void SaveOrder() { }

    public void SendEmail() { }
}
```

Problems:

* Business logic
* Database logic
* Email logic

All in one class.

If email changes, this class changes.

If database changes, this class changes.

Too many responsibilities.

---

### ✅ Good Example

Split responsibilities.

```csharp
public class OrderService
{
    public void CalculateTotal() { }
}

public class OrderRepository
{
    public void SaveOrder() { }
}

public class EmailService
{
    public void SendEmail() { }
}
```

Now:

* OrderService → Business Logic
* OrderRepository → Database
* EmailService → Email

Each class has **one responsibility**.

---

### Easy Interview Line

> One class should do one job and have only one reason to change.

---

# 2. O - Open Closed Principle (OCP)

## Definition

> Open for extension, closed for modification.

Suppose today we send emails.

Tomorrow we also want SMS.

### ❌ Bad

```csharp
if(type=="Email")
{
}

else if(type=="SMS")
{
}

else if(type=="WhatsApp")
{
}
```

Every new notification requires changing existing code.

---

### ✅ Good

Create an interface.

```csharp
public interface INotification
{
    void Send();
}
```

Email

```csharp
public class EmailNotification : INotification
{
    public void Send()
    {
    }
}
```

SMS

```csharp
public class SmsNotification : INotification
{
    public void Send()
    {
    }
}
```

Now adding WhatsApp means:

```text
Create WhatsAppNotification

Implement INotification

Done
```

No existing code changes.

---

### Easy Interview Line

> We extend behavior by adding new classes instead of modifying existing ones.

---

# 3. L - Liskov Substitution Principle (LSP)

## Definition

> A child class should be replaceable with its parent without breaking the program.

Example

```csharp
public interface IPayment
{
    void Pay();
}
```

Implementations

```csharp
public class CreditCardPayment : IPayment
{
    public void Pay(){}
}

public class UPIPayment : IPayment
{
    public void Pay(){}
}
```

Now

```csharp
IPayment payment = new CreditCardPayment();

payment.Pay();
```

Replace with

```csharp
payment = new UPIPayment();

payment.Pay();
```

Everything still works.

This follows LSP.

---

### Easy Interview Line

> Any child object should work wherever the parent object is expected.

---

# 4. I - Interface Segregation Principle (ISP)

## Definition

> Don't force a class to implement methods it doesn't need.

### ❌ Bad

```csharp
public interface IMachine
{
    void Print();

    void Scan();

    void Fax();
}
```

A basic printer only prints.

Why implement Scan and Fax?

---

### ✅ Good

Split interfaces.

```csharp
public interface IPrinter
{
    void Print();
}

public interface IScanner
{
    void Scan();
}
```

Printer

```csharp
public class Printer : IPrinter
{
    public void Print(){}
}
```

Scanner

```csharp
public class Scanner : IScanner
{
    public void Scan(){}
}
```

---

### Easy Interview Line

> Small focused interfaces are better than one large interface.

---

# 5. D - Dependency Inversion Principle (DIP)

## Definition

> Depend on abstractions, not concrete classes.

### ❌ Bad

```csharp
public class OrderService
{
    private EmailService email = new EmailService();
}
```

Problem

OrderService is tightly coupled to EmailService.

---

### ✅ Good

Use Dependency Injection.

```csharp
public interface INotification
{
    void Send();
}
```

Implementation

```csharp
public class EmailNotification : INotification
{
    public void Send(){}
}
```

Consumer

```csharp
public class OrderService
{
    private readonly INotification notification;

    public OrderService(INotification notification)
    {
        this.notification = notification;
    }
}
```

Tomorrow

Replace

```text
Email

↓

SMS

↓

WhatsApp
```

No code changes in OrderService.

---

### Easy Interview Line

> High-level classes should depend on interfaces, not concrete implementations.

---

# Complete Picture

```text
Create Order
      │
      ▼
OrderService
      │
      ├────────► OrderRepository
      │
      └────────► INotification
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
      Email         SMS       WhatsApp
```

Notice

OrderService never knows

whether Email,

SMS,

or WhatsApp is being used.

---

# Easy Memory Trick

| Principle | Easy Meaning                        |
| --------- | ----------------------------------- |
| **S**     | One Class → One Job                 |
| **O**     | Add New Code, Don't Change Old Code |
| **L**     | Child Can Replace Parent            |
| **I**     | Small Interfaces                    |
| **D**     | Depend on Interfaces                |

---

# Interview Answer (2 Minutes)

> "SOLID is a set of five object-oriented design principles that help create maintainable, extensible, and loosely coupled applications. **Single Responsibility Principle** means a class should have only one responsibility. **Open/Closed Principle** means we should extend behavior by adding new classes instead of modifying existing ones. **Liskov Substitution Principle** ensures derived classes can replace base classes without affecting correctness. **Interface Segregation Principle** recommends using small, focused interfaces rather than large ones. **Dependency Inversion Principle** states that high-level modules should depend on abstractions instead of concrete implementations, which is commonly achieved using dependency injection. Following these principles results in code that is easier to test, maintain, and extend."
