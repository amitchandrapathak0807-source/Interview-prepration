# Azure Function (Azure Functions) - Complete Guide (From Beginner to Production)

> **Interview Level:** Senior Software Engineer / Tech Lead / Architect (10+ Years)

---

# Table of Contents

1. Why Azure Functions?
2. What Problem Does It Solve?
3. Traditional Application vs Azure Function
4. What is Serverless?
5. How Azure Function Works
6. Internal Architecture
7. Function Lifecycle
8. Hosting Plans
9. Triggers
10. Bindings
11. Dependency Injection
12. Scaling
13. Cold Start
14. Durable Functions
15. Real-world Example
16. Production Best Practices
17. Interview Questions

---

# Chapter 1 - Why Azure Functions?

Before understanding Azure Functions,

let's understand **why Microsoft created it**.

Imagine your company has built an e-commerce website.

Whenever a customer places an order, you need to perform several tasks.

```
Order Received

↓

Generate Invoice

↓

Send Email

↓

Update Inventory

↓

Notify Warehouse

↓

Generate PDF

↓

Send SMS
```

Question:

Should the customer wait until all these operations finish?

Suppose each operation takes

```
Email            : 2 sec

SMS              : 1 sec

Invoice          : 3 sec

Warehouse        : 2 sec

Inventory        : 1 sec
```

Total

```
9 Seconds
```

Customer clicks

```
Place Order
```

Browser keeps loading for

```
9 Seconds
```

Bad user experience.

---

# Traditional Solution

Everything happens inside the API.

```text
User

↓

Order API

↓

Save Order

↓

Generate Invoice

↓

Send Email

↓

Update Inventory

↓

Send SMS

↓

Return Success
```

Problem

The API becomes slow because it performs everything synchronously.

---

# Better Solution

Return the response immediately.

Move background work somewhere else.

```text
User

↓

Order API

↓

Save Order

↓

Return Success (200 ms)

↓

Background Processing

↓

Invoice

↓

Email

↓

SMS
```

Question

Who performs the background processing?

One excellent solution is

```
Azure Function
```

---

# Chapter 2 - What is Azure Function?

Azure Function is a **serverless compute service**.

Microsoft manages:

- Servers
- Operating System
- Scaling
- Runtime
- Availability
- Infrastructure

You only write

```
Business Logic
```

Think of Azure Function as

> **A piece of code that runs only when an event occurs.**

---

# Real Life Example

Imagine your home doorbell.

Does electricity continuously ring the bell?

No.

The bell only rings

when someone presses it.

Azure Function works exactly the same way.

It stays idle until an event occurs.

Events can be:

- HTTP Request
- Queue Message
- Blob Upload
- Timer
- Event Hub Message
- Service Bus Message

---

# Chapter 3 - Traditional Web API vs Azure Function

## Traditional API

Suppose we deploy

```
ASP.NET Core API
```

Even if

```
0 Users
```

The server is still running.

Memory

```
Allocated
```

CPU

```
Reserved
```

You're paying for the VM.

---

## Azure Function

Suppose nobody calls the function.

```
No CPU

No Memory

No Running Server
```

Cost

Almost

```
₹0
```

Only when an event occurs

does Azure start executing your code.

---

# Chapter 4 - What Does Serverless Mean?

Many people misunderstand Serverless.

Question

Does Azure Function run without servers?

No.

Servers absolutely exist.

Microsoft owns and manages them.

You don't.

Think of it like Uber.

You use a car.

You don't own the car.

Similarly,

Azure Functions use servers,

but Microsoft manages them.

---

# Chapter 5 - Internal Working of Azure Function

Let's understand exactly what happens.

Suppose Amit uploads an image.

The application stores it in Azure Blob Storage.

Immediately after upload,

we want to

- Generate Thumbnail
- Resize Image
- Scan Virus
- Extract Metadata

Instead of writing this inside the API,

Azure Blob generates an event.

That event triggers the Azure Function.

The function starts,

does its work,

and stops.

No server keeps running continuously.

---

# Chapter 6 - Function Lifecycle

Imagine your function has not been called for

```
30 Minutes
```

Azure may unload it from memory.

Later,

someone uploads a file.

Azure performs:

1. Allocate compute.
2. Load .NET Runtime.
3. Load your DLL.
4. Initialize dependencies.
5. Execute the function.
6. Return result.
7. Wait for next trigger.

This startup time is called

```
Cold Start
```

We'll discuss it later.

---

# Chapter 7 - Function Triggers

A trigger answers one question:

> **When should my function execute?**

Without a trigger,

Azure doesn't know when to run your code.

---

## HTTP Trigger

Runs when an HTTP request arrives.

Example

```http
POST /api/send-email
```

Example

```csharp
[Function("SendEmail")]
public async Task<HttpResponseData> Run(
    [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequestData req)
{
    // Send Email
}
```

Used for

- APIs
- Webhooks
- REST Endpoints

---

## Timer Trigger

Runs automatically at a scheduled time.

Example

Every night at

```
12:00 AM
```

Run

```
Generate Daily Report
```

No user interaction required.

---

## Blob Trigger

Runs when a file is uploaded.

Example

Customer uploads

```
Invoice.pdf
```

Blob Trigger automatically starts.

Possible tasks

- OCR
- Thumbnail Generation
- Virus Scan
- AI Processing

---

## Queue Trigger

Runs whenever a message arrives in Azure Storage Queue.

Example

```
Order Placed

↓

Message Added

↓

Azure Function Executes
```

Used for

- Background Processing
- Retry
- Decoupling

---

## Service Bus Trigger

Used for enterprise messaging.

Example

```
Payment Completed

↓

Service Bus

↓

Azure Function

↓

Send Invoice
```

---

## Event Hub Trigger

Used for high-volume streaming.

Examples

- IoT Devices
- Sensors
- Telemetry
- Logs

---

## Cosmos DB Trigger

Runs whenever data changes inside Cosmos DB.

---

# Chapter 8 - Bindings

Bindings reduce boilerplate code.

Suppose you want to read a blob.

Without Binding

```csharp
var client = new BlobServiceClient(...);

var container = client.GetBlobContainerClient(...);

var blob = container.GetBlobClient(...);
```

With Binding

```csharp
public void Run(
[BlobTrigger("images/{name}")]
Stream stream)
{

}
```

Azure automatically gives you the file.

Much simpler.

---

# Types of Bindings

## Input Binding

Reads data.

Example

Read Blob.

Read Cosmos DB.

Read Queue.

---

## Output Binding

Writes data.

Example

Write Queue.

Write Blob.

Write Service Bus.

---

# Chapter 9 - Hosting Plans

Azure Functions support multiple plans.

---

## Consumption Plan

Most popular.

Characteristics

- Pay per execution
- Auto Scale
- Serverless
- Cold Start possible

Best for

Event-driven workloads.

---

## Premium Plan

Always warm.

No cold start.

Supports VNET.

Higher cost.

---

## Dedicated Plan

Runs on App Service Plan.

Servers always running.

Good if you already own App Service infrastructure.

---

# Chapter 10 - Scaling

One of Azure Function's biggest strengths.

Imagine

```
10 Users
```

Only one instance runs.

Suddenly

```
10,000 Users
```

Azure automatically creates multiple function instances.

Example

```
Instance 1

Instance 2

Instance 3

Instance 4

Instance 5
```

Traffic is distributed automatically.

No manual scaling required.

---

# Chapter 11 - Cold Start

Suppose your function hasn't run for one hour.

Azure unloads it.

The next request must:

- Start container
- Load .NET Runtime
- Load assemblies
- Initialize dependencies

This delay is called

```
Cold Start
```

Typical duration

```
500 ms

to

5 Seconds
```

depending on:

- Runtime
- Package size
- Hosting Plan

Premium Plan avoids this problem.

---

# Chapter 12 - Durable Functions

Normal Functions are short-lived.

What if your workflow lasts

```
3 Hours?
```

Example

Loan Processing

```
Submit Loan

↓

Wait for Manager Approval

↓

Wait for Credit Check

↓

Wait for Customer Documents

↓

Approve
```

A normal Azure Function cannot remain active for hours.

Durable Functions solve this.

They preserve state between executions.

Patterns include:

- Function Chaining
- Fan-Out/Fan-In
- Async HTTP APIs
- Human Interaction

---

# Chapter 13 - Real Production Example

Suppose you're building an e-commerce platform.

Customer places an order.

Instead of making the Order API perform everything,

the flow becomes:

```text
Customer places order

↓

Order API validates request

↓

Order saved to SQL

↓

Message published to Azure Service Bus

↓

Azure Function triggered

↓

Generate PDF Invoice

↓

Send Email

↓

Update Inventory

↓

Notify Warehouse

↓

Write Audit Logs

↓

Function completes
```

Benefits:

- Fast API response.
- Independent scaling.
- Automatic retries.
- Better fault isolation.

---

# Chapter 14 - Dependency Injection

Azure Functions support Dependency Injection.

Example

```csharp
builder.Services.AddScoped<IEmailService, EmailService>();

builder.Services.AddSingleton<IStorageService, StorageService>();
```

Just like ASP.NET Core.

---

# Chapter 15 - Best Practices

- Keep Functions small.
- One Function = One Responsibility.
- Avoid long-running work in a single execution.
- Use queues for retries.
- Store secrets in Azure Key Vault.
- Enable Application Insights.
- Prefer Managed Identity over connection strings.
- Make functions idempotent.

---

# Azure Function vs Web API

| Web API | Azure Function |
|----------|----------------|
| Always Running | Event Driven |
| Manual Scaling | Auto Scaling |
| Best for CRUD APIs | Best for Background Tasks |
| Pay for VM/App Service | Pay per Execution (Consumption) |
| Better for Long-running APIs | Better for Short Event Processing |

---

# When Should You Use Azure Functions?

Use Azure Functions for:

- Image Processing
- Email Notifications
- File Upload Processing
- Queue Processing
- Scheduled Jobs
- Event Processing
- Webhooks
- IoT Events
- Background Workers

Avoid using Azure Functions for:

- Large monolithic REST APIs.
- Long-running synchronous user requests.
- Stateful applications.

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. What is the difference between Azure Function and ASP.NET Core Web API?

### Answer

An ASP.NET Core Web API is typically a continuously running application designed for request-response scenarios. Azure Functions are event-driven and execute only when triggered. Functions automatically scale based on incoming events and are ideal for background processing, integrations, and serverless workloads.

---

## Q2. What causes a Cold Start in Azure Functions?

### Answer

A Cold Start occurs when Azure has unloaded an idle function instance to save resources. The next invocation requires Azure to allocate compute resources, start the runtime, load the application assemblies, initialize dependencies, and then execute the function. Premium and Dedicated plans mitigate or eliminate Cold Starts by keeping instances warm.

---

## Q3. When would you choose Azure Functions over Azure Web Apps?

### Answer

I choose Azure Functions when the workload is event-driven, intermittent, or background-oriented—for example, processing queue messages, handling blob uploads, scheduled tasks, or sending notifications. I choose Azure Web Apps (App Service) for always-on REST APIs, MVC applications, or services requiring predictable latency and continuous execution.

---

## Q4. How does Azure Function scaling work?

### Answer

Azure continuously monitors trigger sources such as HTTP requests, queue length, Service Bus messages, or Event Hub events. As demand increases, Azure automatically creates additional function instances to process work in parallel. When demand decreases, excess instances are removed, allowing the application to scale dynamically without manual intervention.

---

## Q5. What are Durable Functions, and when would you use them?

### Answer

Durable Functions extend Azure Functions by allowing stateful workflows. They are suitable for long-running business processes such as approval workflows, order fulfillment, loan processing, human interactions, and orchestrating multiple activities. They provide reliable execution by checkpointing state and resuming workflows without keeping compute resources continuously active.
