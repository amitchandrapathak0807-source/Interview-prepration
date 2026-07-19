# Dependency Injection (DI) vs Dependency Inversion Principle (DIP)

One of the most common interview questions is:

> **What is the difference between Dependency Injection and Dependency Inversion Principle?**

Many developers confuse them, but they are **not the same**.

---

# Short Answer

| Dependency Inversion (DIP)      | Dependency Injection (DI)               |
| ------------------------------- | --------------------------------------- |
| A **design principle**          | A **design pattern / technique**        |
| Says **depend on abstractions** | Injects those abstractions into a class |
| Part of SOLID                   | One way to implement DIP                |

**Easy way to remember:**

```text
DIP = WHAT to do

↓

DI = HOW to do it
```

---

# Real-Life Example

Imagine you're buying a phone charger.

## ❌ Without DIP

The phone only works with one specific charger.

```text
Phone
   │
   ▼
Samsung Charger
```

If you want to use another charger, you must modify the phone.

The phone is tightly coupled.

---

## ✅ With DIP

The phone depends on a USB-C port, not on a specific charger.

```text
Phone
   │
   ▼
USB-C Port (Interface)
   │
   ├── Samsung Charger
   ├── Apple Charger
   └── Laptop USB Port
```

The phone doesn't care which charger is used.

This is **Dependency Inversion Principle**.

---

# Software Example

Suppose we have an Order Service.

When an order is placed, we send an email.

---

## ❌ Without DIP

```csharp
public class EmailService
{
    public void Send()
    {
        Console.WriteLine("Email Sent");
    }
}

public class OrderService
{
    private EmailService emailService = new EmailService();

    public void PlaceOrder()
    {
        Console.WriteLine("Order Placed");

        emailService.Send();
    }
}
```

### Problem

```text
OrderService

↓

EmailService
```

OrderService directly depends on EmailService.

Tomorrow if we want SMS instead of Email:

```text
OrderService

↓

SmsService
```

We must modify OrderService.

This violates the **Open/Closed Principle** and the **Dependency Inversion Principle**.

---

# Step 1 - Apply Dependency Inversion Principle (DIP)

Create an abstraction.

```csharp
public interface INotification
{
    void Send();
}
```

Email implementation

```csharp
public class EmailService : INotification
{
    public void Send()
    {
        Console.WriteLine("Email Sent");
    }
}
```

SMS implementation

```csharp
public class SmsService : INotification
{
    public void Send()
    {
        Console.WriteLine("SMS Sent");
    }
}
```

Now OrderService depends on an **interface**, not a concrete class.

```text
OrderService

↓

INotification

↓

Email
SMS
WhatsApp
```

This is **Dependency Inversion Principle**.

Notice that we still haven't created the object.

---

# Step 2 - Apply Dependency Injection (DI)

Now inject the dependency from outside.

```csharp
public class OrderService
{
    private readonly INotification notification;

    public OrderService(INotification notification)
    {
        this.notification = notification;
    }

    public void PlaceOrder()
    {
        Console.WriteLine("Order Placed");

        notification.Send();
    }
}
```

Now create the objects.

```csharp
INotification notification = new EmailService();

OrderService service = new OrderService(notification);

service.PlaceOrder();
```

Output

```text
Order Placed

Email Sent
```

Switch to SMS.

```csharp
INotification notification = new SmsService();

OrderService service = new OrderService(notification);

service.PlaceOrder();
```

Output

```text
Order Placed

SMS Sent
```

Notice:

We changed only the injected object.

OrderService never changed.

This is **Dependency Injection**.

---

# Visual Difference

## Without DI

```text
OrderService

↓

Creates

↓

EmailService
```

The class creates its own dependency.

Tightly coupled.

---

## With DI

```text
Application

↓

Creates EmailService

↓

Injects

↓

OrderService
```

The dependency comes from outside.

Loosely coupled.

---

# How ASP.NET Core Does It

Program.cs

```csharp
builder.Services.AddScoped<INotification, EmailService>();
```

Controller

```csharp
public class OrderController
{
    private readonly INotification notification;

    public OrderController(INotification notification)
    {
        this.notification = notification;
    }
}
```

The framework automatically injects the dependency.

This is **Dependency Injection**.

---

# Easy Memory Trick

```text
Dependency Inversion

↓

Depend on Interface

-------------------------

Dependency Injection

↓

Pass the Interface Object
```

---

# Interview Difference

| Dependency Inversion Principle | Dependency Injection               |
| ------------------------------ | ---------------------------------- |
| SOLID principle                | Design pattern                     |
| Depends on abstraction         | Provides the abstraction           |
| Reduces coupling               | Supplies dependency                |
| Defines the architecture       | Implements the architecture        |
| "Use interfaces"               | "Inject interface implementations" |

---

# Interview Answer (1 Minute)

> **Dependency Inversion Principle (DIP)** is a SOLID design principle that states high-level modules should depend on abstractions (interfaces), not concrete implementations. This reduces coupling and makes the system easier to extend. **Dependency Injection (DI)** is the technique used to provide those dependencies from outside the class, usually through constructor injection. In short, **DIP tells us to depend on interfaces, while DI is the mechanism that injects the implementation of those interfaces.** In ASP.NET Core, the built-in DI container is commonly used to implement DIP.
