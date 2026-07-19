# Delegates in C# (Complete Guide)

---

# Simple Analogy

| C# Concept | Real-World Analogy |
|------------|--------------------|
| Method | 👨‍💼 Employee |
| Delegate | 🪪 Employee ID Card |
| Action | Employee who returns nothing |
| Func | Employee who returns a result |
| Predicate | Employee who answers **Yes/No** |
| Event | 📢 Company Announcement System |

---

# What Exactly is a Delegate in C#?

A **delegate** is a **type-safe object** that stores references to one or more methods with the same signature.

It allows methods to be treated like data. Methods can be:

- Assigned to variables
- Passed as parameters
- Returned from methods
- Invoked later

Delegates are widely used for:

- Callbacks
- Events
- LINQ
- `Task.Run()`
- Asynchronous programming

---

# Part 1 – A Delegate is a Type-Safe Object

Suppose we declare a delegate.

```csharp
public delegate void Notification();
```

This means:

> "I can store only methods that:
>
> - Return `void`
> - Take no parameters"

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

Both methods match the delegate signature.

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

❌ **No**

### Why?

```text
Delegate
    │
    ▼
void()

Method
    │
    ▼
int()
```

The signatures don't match.

The compiler immediately reports an error.

This is why delegates are called **type-safe**.

---

# Part 2 – Delegate Stores References, Not Results

Consider this code.

```csharp
Notification notify = SendEmail;
```

Did we execute the method?

❌ No.

Notice there are **no parentheses**.

```csharp
SendEmail();
```

would execute the method.

Instead we wrote:

```csharp
notify = SendEmail;
```

The delegate stores the **address of the method**, not its result.

---

## Visual Representation

Instead of storing data:

```text
Age
 │
 ▼
30
```

The delegate stores:

```text
notify
 │
 ▼
Address of SendEmail()
```

It remembers:

> "When someone calls me, execute `SendEmail()`."

---

# Part 3 – A Delegate Can Store Multiple Methods

A delegate supports **multicasting**.

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

Calling:

```csharp
notify();
```

Produces:

```text
Email Sent
SMS Sent
```

One delegate.

Two methods.

---

# Part 4 – Methods Become Data

Normally variables store data.

```csharp
int age = 30;
```

Memory:

```text
age
 │
 ▼
30
```

Delegate variables store methods.

```csharp
Notification notify = SendEmail;
```

Memory:

```text
notify
 │
 ▼
SendEmail()
```

The method behaves just like a value.

You can change it.

```csharp
notify = SendSMS;
```

Just like:

```csharp
age = 50;
```

This is why people say:

> **Methods become first-class citizens.**

---

# Part 5 – Delegates Can Be Assigned to Variables

```csharp
Notification notify;

notify = SendEmail;

notify = SendSMS;
```

Exactly like:

```csharp
int number;

number = 10;

number = 20;
```

The variable stays the same.

Only what it points to changes.

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

The method expects another method.

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

Same function.

Different behavior.

---

# Part 7 – Delegates Can Be Returned from Methods

Methods can return delegates too.

```csharp
Notification GetNotifier()
{
    return SendEmail;
}
```

Usage:

```csharp
Notification notify = GetNotifier();

notify();
```

Output

```text
Email Sent
```

Here, a method returned another method.

---

# Part 8 – Delegates Can Be Invoked Later

Assigning a delegate does **not** execute it.

```csharp
Notification notify = SendEmail;
```

Nothing happens.

Only this executes the method:

```csharp
notify();
```

---

## Phone Number Analogy

```text
Store Phone Number
        │
        ▼
 Nothing Happens

Later...

Call Phone Number
        │
        ▼
 Person Answers
```

The delegate is the phone number.

Calling `notify()` is making the call.

---

# Part 9 – Delegates are Used for Callbacks

Suppose downloading a file takes time.

```csharp
DownloadFile(FileDownloaded callback);
```

When the download finishes:

```csharp
callback();
```

The downloader doesn't know what should happen.

The caller decides.

This is called a **callback**.

---

# Part 10 – Delegates are Used for Events

Example:

```csharp
button.Click += SaveOrder;
```

The button doesn't know anything about `SaveOrder()`.

When clicked, it simply invokes every subscribed delegate.

```text
Button Click
      │
      ▼
 Delegate List
      │
      ├── SaveOrder()
      ├── SendEmail()
      └── UpdateUI()
```

---

# Part 11 – Delegates are Used in LINQ

Example:

```csharp
orders.Where(order => order.Amount > 1000);
```

The lambda expression:

```csharp
order => order.Amount > 1000
```

is converted into a delegate.

Conceptually:

```csharp
Func<Order, bool> filter =
    order => order.Amount > 1000;
```

`Where()` simply calls that delegate for every order.

---

# Part 12 – Delegates are Used in Task.Run()

Example:

```csharp
Task.Run(ProcessPayment);
```

or

```csharp
Task.Run(() =>
{
    ProcessPayment();
});
```

`Task.Run()` doesn't know your business logic.

It simply says:

```text
Give me a method
        │
        ▼
I'll execute it.
```

That method is passed as a delegate.

---

# Complete Picture

Imagine a pizza shop.

```text
Customer Orders Pizza
          │
          ▼
Pizza Cooked
          │
          ▼
      Delegate
          │
 ┌────────┼─────────┐
 ▼        ▼         ▼
Email    SMS    WhatsApp
 │
 ▼
Invoice
 │
 ▼
Push Notification
```

The chef never changes.

Only the delegate changes.

---

# The One Sentence That Makes Delegates Click

A normal variable stores **data**.

```csharp
int age = 30;
```

A delegate stores **behavior** (a method).

```csharp
Notification notify = SendEmail;
```

Everything else—

- Callbacks
- Events
- LINQ
- `Task.Run()`
- `async/await`

—is built on this single idea:

> **Instead of passing data, you're passing the work (the method) that should be performed.
