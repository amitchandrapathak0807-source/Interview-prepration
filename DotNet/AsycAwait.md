# Async/Await State Machine in C# (Interview Guide)

## What is async/await?

`async` and `await` allow a method to perform **non-blocking asynchronous operations**.

Instead of blocking the current thread while waiting for an operation (like a database call or HTTP request), the thread is released back to the thread pool and can execute other work.

---

# Simple Example

```csharp
public async Task<string> GetOrderAsync()
{
    Console.WriteLine("1. Before API Call");

    string result = await CallApiAsync();

    Console.WriteLine("2. After API Call");

    return result;
}
```

Question:

> What happens when `await` is reached?

---

# Without async/await

```text
Main Thread

↓

Call API

↓

Wait...

↓

Wait...

↓

Wait...

↓

Response

↓

Continue
```

The thread is blocked while waiting.

---

# With async/await

```text
Main Thread

↓

Call API

↓

await

↓

Thread Returns to Thread Pool

↓

API Runs Asynchronously

↓

API Completes

↓

Thread Resumes Execution

↓

Continue After await
```

The thread is **not blocked**.

---

# What is a State Machine?

When the compiler sees an `async` method, it automatically converts it into a **State Machine**.

You never write the state machine yourself.

The C# compiler generates it behind the scenes.

---

# Original Code

```csharp
public async Task<string> GetOrderAsync()
{
    Console.WriteLine("Start");

    string order = await CallApiAsync();

    Console.WriteLine("Order Received");

    return order;
}
```

---

# Compiler Converts It Into Something Like

```text
State 0

↓

Print "Start"

↓

Call CallApiAsync()

↓

Pause

↓

Return Control

------------------------

API Completes

↓

State 1

↓

Continue

↓

Print "Order Received"

↓

Return Result
```

Think of it like a bookmark in a book.

When `await` is reached, the compiler places a bookmark so it knows exactly where to continue later.

---

# Visual Flow

```text
Start Method
      │
      ▼
Execute Code Before await
      │
      ▼
Call Async Operation
      │
      ▼
Is Task Completed?
      │
   ┌──┴───┐
   │      │
 Yes      No
   │      │
   ▼      ▼
Continue  Save Current State
           │
           ▼
     Return Thread
           │
           ▼
 Task Completes Later
           │
           ▼
 Restore Saved State
           │
           ▼
 Continue After await
```

---

# Example with Delay

```csharp
public async Task Demo()
{
    Console.WriteLine("A");

    await Task.Delay(3000);

    Console.WriteLine("B");
}
```

Execution:

```text
Time = 0 sec

Print A

↓

Task.Delay(3000)

↓

Method Pauses

↓

Thread Returned

↓

3 Seconds Later

↓

Resume

↓

Print B
```

Output

```text
A

(wait 3 seconds)

B
```

---

# What Does the State Machine Store?

Before pausing, it stores:

* Current execution state
* Local variables
* Method parameters
* Exception handling information
* Where to resume execution

Example

```csharp
public async Task<int> CalculateAsync()
{
    int x = 10;

    await Task.Delay(1000);

    return x + 5;
}
```

When execution pauses, the generated state machine stores:

```text
State = Waiting

x = 10

Resume From = After await
```

After one second:

```text
Restore x = 10

Continue

Return 15
```

---

# Why Does C# Use a State Machine?

Without a state machine, the compiler wouldn't know:

* Where execution stopped
* Which local variables existed
* Where to continue after the asynchronous operation completed

The state machine keeps track of all of this automatically.

---

# Benefits

* Non-blocking execution
* Better scalability
* Efficient thread usage
* Simpler asynchronous code
* No manual callback management

---

# Common Interview Questions

## Q1. Does `await` create a new thread?

**Answer:** No.

`await` does **not** create a new thread. It simply waits for the asynchronous operation to complete. During the wait, the current thread is released to do other work.

---

## Q2. Who creates the state machine?

**Answer:** The C# compiler.

Every `async` method is transformed into a compiler-generated state machine.

---

## Q3. What happens when `await` is encountered?

1. Execution pauses.
2. Current state is saved.
3. Control returns to the caller.
4. When the awaited task completes, the state is restored.
5. Execution resumes after the `await`.

---

## Q4. Why is async/await scalable?

Because threads are **not blocked** while waiting for I/O operations such as:

* Database calls
* HTTP requests
* File operations

The released thread can process other requests.

---

# Easy Memory Trick

```text
Method Starts

↓

await

↓

Save State

↓

Return Thread

↓

Task Completes

↓

Restore State

↓

Continue Execution
```

Remember:

**"await pauses the method, not the thread."**

---

# Interview Answer (2 Minutes)

> "When the C# compiler encounters an `async` method, it automatically converts it into a state machine. When execution reaches an `await`, the current execution state, local variables, and the point where execution should continue are stored. If the awaited task hasn't completed, the method returns immediately without blocking the thread. Once the asynchronous operation completes, the state machine restores the saved state and resumes execution from the statement immediately after the `await`. This is why async/await enables scalable, non-blocking applications while allowing developers to write asynchronous code in a synchronous style."
