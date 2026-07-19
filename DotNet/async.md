**What is a Thread?**
A Thread is the smallest unit of execution inside a process.
A process can have multiple threads, all sharing the same process memory.
Order Process:
├── Main Thread
├── Payment Thread
├── Email Thread
└── Invoice Thread

**Why do we need multiple threads?**
Multiple threads allow an application to perform multiple operations concurrently, improving responsiveness.

Without multiple threads:
Validate Order ↓ Process Payment ↓ Send Email
Each step waits for the previous one.

With multiple threads:
Main Thread ↓ Validate Order     ↙         ↘
Payment Thread   Email Thread
Payment and email can happen concurrently if they are independent.

**Why is creating a Thread expensive?**
Creating an OS thread involves:
Allocating stack memory (typically ~1 MB by default)
Registering the thread with the operating system
Scheduling by the OS
Context switching overhead
Because of this, creating thousands of threads is inefficient.
for (int i = 0; i < 10000; i++)
{
    new Thread(() => ProcessOrder()).Start();
}
This creates 10,000 OS threads.
Better:
Parallel.For(0, 10000, i =>
{
    ProcessOrder();
});
The ThreadPool manages a limited number of reusable threads.

**Why was the ThreadPool introduced?**
Creating and destroying threads repeatedly is costly.
The ThreadPool was introduced to:
Reuse threads
Reduce thread creation overhead
Improve scalability
Increase throughput
Example

Without ThreadPool:
Order
↓
Create Thread
↓
Execute
↓
Destroy Thread

With ThreadPool:
Order
↓
Available Thread
↓
Execute
↓
Return Thread to Pool


**What is a Task?**
A Task represents a unit of work. It is not a thread.
A Task describes what should be done, while a thread performs the work.
Task paymentTask = ProcessPaymentAsync();
The task represents the payment operation. An available ThreadPool thread executes it when appropriate.

**
Is Task a Thread?**
No.A Task is only an abstraction representing work. The ThreadPool thread executes the task.
Restaurant analogy: Chef = Thread; Food Order = Task
The food order doesn't cook itself. The chef cooks it.

**What happens internally when Task.Run() is called?**
Internally:
A Task object is created.
The Task is queued to the Task Scheduler.
The Task Scheduler places it in the ThreadPool queue.
An available worker thread executes it.
The Task is marked as completed.
**await Task.Run(() =>
{
    ProcessPayment();
});**
Execution flow:
Task.Run()
↓
Task Created
↓
Task Scheduler
↓
ThreadPool Queue
↓
Worker Thread
↓
ProcessPayment()
↓
Task Completed

Does Task.Run() always create a new thread?
No.Most of the time, it uses an existing ThreadPool thread.
A new thread is only created if the ThreadPool determines that additional threads are needed.
await Task.Run(() =>
{
    Console.WriteLine(Thread.CurrentThread.ManagedThreadId);
});
The thread ID is usually one of the existing ThreadPool worker threads.

**What is the Task Scheduler?**
The Task Scheduler decides where and how a Task should execute. The default scheduler (TaskScheduler.Default) uses the .NET ThreadPool.
Task
↓
Task Scheduler
↓
ThreadPool
↓
Worker Thread
↓
Execute Task
The scheduler doesn't execute the work itself; it assigns it to a suitable thread.

**What is the relationship between Task Scheduler and ThreadPool?**
The Task Scheduler is responsible for scheduling tasks. The ThreadPool provides the worker threads that execute those tasks.
**Think of it as:**
Task Scheduler
↓
Assign Work
↓
ThreadPool
↓
Worker Thread
↓
Execute

**When should you use Task instead of Thread?**
Use Task for:
Asynchronous programming
I/O-bound operations
Parallel workloads
ASP.NET Core applications
Tasks are lightweight, integrate with async/await, and leverage the ThreadPool efficiently.:
public async Task<Order> GetOrderAsync(int id)
{
    return await repository.GetOrderAsync(id);
}

**Can a Task run without creating a Thread?**
Yes.
For asynchronous I/O operations (such as database queries or HTTP requests), the Task represents the pending operation. While waiting for the external resource, no thread is blocked or actively executing the Task. A ThreadPool thread is used briefly to initiate the operation and later to process its completion.
await httpClient.GetAsync(url);
Execution:
Thread starts request
↓
OS handles network I/O
↓
Thread returns to pool
↓
Response arrives
↓
Another ThreadPool thread resumes the async method
This is why async I/O scales much better than blocking a thread for the entire wait.

**What is the difference between Thread and Task?**
| Thread                          | Task                                         |
| ------------------------------- | -------------------------------------------- |
| OS-level execution unit         | Managed abstraction representing work        |
| Expensive to create             | Lightweight                                  |
| Requires manual management      | Managed by .NET                              |
| Has its own stack               | Uses existing threads (typically ThreadPool) |
| Not integrated with async/await | Fully supports async/await                   |

Creating a Thread: new Thread(ProcessOrder).Start();
Creating a Task: await ProcessOrderAsync();

**Explain the complete flow from Task.Run() to execution.**
When Task.Run() is called:
A Task object is created.
The Task is queued to TaskScheduler.Default.
The scheduler enqueues it in the ThreadPool's global or local work queue.
An available ThreadPool worker thread dequeues the Task.
The worker thread executes the delegate.
The Task transitions to the RanToCompletion, Faulted, or Canceled state.
If the Task is awaited, the awaiting method resumes via a continuation.


**When should you use a Thread instead of a Task?**
Use Task in almost all modern .NET applications. Use Thread only when you need complete control over the thread's lifetime or behavior.

**Long-Running Dedicated Work**
Suppose you're building a stock trading application.
You need a thread that runs continuously for the entire lifetime of the application.
Application Starts
↓
Dedicated Thread Starts
↓
Listen for Market Data
↓
Never Stops Until Application Ends

Example:

Thread marketThread = new Thread(ListenForMarketData);
marketThread.Start();

A dedicated thread may be appropriate because the work is continuous rather than a short-lived task.

**Complete Lifetime Control**
With a Thread, you control:
When it starts
When it ends
Background vs foreground
Name
Priority

A Task is scheduled by the runtime, so you don't have this level of control.

**Set Thread Priority**

Example:

Thread thread = new Thread(Work);
thread.Priority = ThreadPriority.Highest;
thread.Start();

You can control thread priority.

Task doesn't expose this directly.

**Configure Thread Properties**

You can configure properties such as:

thread.Name = "WorkerThread";
thread.IsBackground = true;

Useful for diagnostics and application behavior.


| Feature                        | Thread | Task             |
| ------------------------------ | ------ | ---------------- |
| Manual creation                | ✅      | ❌                |
| Uses ThreadPool                | ❌      | Usually ✅        |
| `async`/`await` support        | ❌      | ✅                |
| Easy exception handling        | ❌      | ✅                |
| Set Priority                   | ✅      | ❌                |
| Set Apartment State (STA)      | ✅      | ❌                |
| Background/Foreground          | ✅      | ❌ (not directly) |
| Best for most application code | ❌      | ✅                |
