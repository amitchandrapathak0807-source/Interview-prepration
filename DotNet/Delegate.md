# Delegates in C# (Complete Guide)

---

# Simple Analogy

| C# Concept | Real-World Analogy |
|------------|--------------------|
| Method | 👨‍💼 Employee |
| Delegate | 🪪 Employee ID Card |
| Action | Employee who performs work but returns nothing |
| Func | Employee who performs work and returns a result |
| Predicate | Employee who answers **Yes/No** |
| Event | 📢 Company Announcement System |

---

# What Exactly is a Delegate?

A **delegate** is a **type-safe reference type** that stores references to one or more methods with the same signature.

It allows methods to be treated like data.

Methods can be:

- Assigned to variables
- Passed as parameters
- Returned from methods
- Invoked later

Delegates are the foundation of many .NET features:

- Events
- Callbacks
- LINQ
- Task Parallel Library (TPL)
- `async/await`
- Threading APIs

---

# Part 1 – A Delegate is Type-Safe

Suppose we declare a delegate.

```csharp
public delegate void Notification();
```

This delegate says:

> I can only store methods that:
>
> - Return `void`
> - Accept **no parameters**

---

## Valid Methods

```csharp
static void SendEmail()
{
    Console.WriteLine("Email Sent");
}

static void SendSMS()
{
    Console.WriteLine("SMS Sent");
}
```

Both methods satisfy the delegate signature.

Therefore both are valid.

---

## Invalid Method

```csharp
static int CalculatePrice()
{
    return 100;
}
```

Can we assign it?

```csharp
Notification notify = CalculatePrice;
```

**❌ No**

### Why?

```text
Delegate Signature

void()

      │
      ▼

Method Signature

int()
```

The return types don't match.

The compiler immediately throws an error.

This compile-time validation makes delegates **type-safe**.

---

# Part 2 – Delegates Store Method References

Consider this code.

```csharp
Notification notify = SendEmail;
```

Did we execute the method?

**❌ No**

Notice there are **no parentheses**.

```csharp
SendEmail();
```

would execute the method.

Instead,

```csharp
notify = SendEmail;
```

stores the **reference (address)** of the method.

---

## Think of Variables

A normal variable stores data.

```text
Age
 │
 ▼
30
```

A delegate stores a method reference.

```text
notify
 │
 ▼
Address of SendEmail()
```

The delegate remembers:

> "Whenever someone calls me, execute `SendEmail()`."

---

# Part 3 – A Delegate Can Store Multiple Methods

A delegate can reference **multiple methods**.

This is called a **Multicast Delegate**.

```csharp
Notification notify = SendEmail;

notify += SendSMS;
```

Internally:

```text
notify
 │
 ├──► SendEmail()
 │
 └──► SendSMS()
```

Calling

```csharp
notify();
```

Produces

```text
Email Sent
SMS Sent
```

One delegate.

Multiple methods.

---

## Multicast Flow

```text
notify()

      │

 ┌────┴────┐

 ▼         ▼

SendEmail()   SendSMS()

 ▼             ▼

Email Sent   SMS Sent
```

---

# Part 4 – Methods Become Data

Normally variables store values.

```csharp
int age = 30;
```

Memory

```text
age
 │
 ▼
30
```

Delegates store methods.

```csharp
Notification notify = SendEmail;
```

Memory

```text
notify
 │
 ▼
SendEmail()
```

Now methods behave like ordinary values.

You can change them.

```csharp
notify = SendSMS;
```

Just like

```csharp
age = 40;
```

You're simply changing what the variable points to.

---

## Methods Become First-Class Citizens

Methods can now be:

- Stored
- Copied
- Passed
- Returned
- Executed later

Exactly like ordinary data.

---

# Part 5 – Delegates Can Be Assigned

```csharp
Notification notify;

notify = SendEmail;

notify = SendSMS;
```

Exactly like

```csharp
int number;

number = 10;

number = 20;
```

The variable remains the same.

Only the value changes.

---

# Part 6 – Delegates Can Be Passed as Parameters

This is where delegates become extremely powerful.

```csharp
void PizzaReady(Notification notify)
{
    Console.WriteLine("Pizza Ready");

    notify();
}
```

Notice something important.

`PizzaReady()` doesn't care **how** customers are notified.

It only expects a method that matches the `Notification` delegate.

---

## Example 1

```csharp
PizzaReady(SendEmail);
```

Output

```text
Pizza Ready
Email Sent
```

---

## Example 2

```csharp
PizzaReady(SendSMS);
```

Output

```text
Pizza Ready
SMS Sent
```

The same method.

Different behavior.

This is called **Loose Coupling**.

---

# Why is This Powerful?

Without delegates:

```text
PizzaReady()

↓

SendEmail()
```

Changing the notification method requires changing the code.

---

With delegates:

```text
PizzaReady()

      │

      ▼

Notification Delegate

      │

 ┌────┴────┐

 ▼         ▼

Email     SMS
```

The caller decides what should happen.

The `PizzaReady()` method never changes.

---

# Real-World Example

Imagine an e-commerce application.

After placing an order, different customers want different notifications.

Customer A

```text
Order Placed

↓

Send Email
```

Customer B

```text
Order Placed

↓

Send SMS
```

Customer C

```text
Order Placed

↓

Send WhatsApp
```

Instead of modifying `PlaceOrder()` every time, simply pass a different delegate.

```csharp
PlaceOrder(SendEmail);

PlaceOrder(SendSMS);

PlaceOrder(SendWhatsApp);
```

This keeps the code:

- Reusable
- Flexible
- Extensible
- Easy to maintain

---

# Summary

A delegate is simply an object that stores one or more methods.

Think of it this way:

```text
Normal Variable

↓

Stores Data

Example

int age = 30;
```

```text
Delegate Variable

↓

Stores Methods

Example

Notification notify = SendEmail;
```

The biggest idea to remember is:

> **Instead of passing data, delegates allow you to pass behavior (methods).**
