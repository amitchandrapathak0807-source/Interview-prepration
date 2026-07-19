# RabbitMQ Message Reliability - Banking Money Transfer Example (System Design Interview Guide)

## Introduction

One of the most common questions asked in Senior .NET, Microservices, and System Design interviews is:

> **"How do you ensure messages are not lost when using RabbitMQ?"**

Many candidates immediately answer:

* Durable Queue
* Persistent Messages
* Manual ACK

While these are correct, they are **not sufficient**.

A senior engineer thinks differently.

Instead of memorizing RabbitMQ features, they analyze **every possible failure point** in the complete message lifecycle and explain how the system handles each failure.

This guide walks through a real-world banking example and explains every scenario in detail.

---

# Business Scenario

A customer wants to transfer **₹10,000** from **Account A** to **Account B**.

Instead of performing the transfer synchronously, the API publishes a message to RabbitMQ, and a background consumer processes it asynchronously.

Technology Stack:

* ASP.NET Core API
* RabbitMQ
* SQL Server
* Background Worker Service

---

# System Architecture

```text
                    Customer
                        │
                        ▼
                Transfer API (.NET)
                        │
                        ▼
                 RabbitMQ Exchange
                        │
                        ▼
                 Durable Queue
                        │
                        ▼
            Transfer Consumer (.NET)
                        │
                        ▼
                  SQL Server
```

---

# End-to-End Flow

1. Customer clicks **Transfer Money**.
2. API validates the request.
3. API stores business data.
4. API publishes a message to RabbitMQ.
5. RabbitMQ stores the message.
6. Consumer receives the message.
7. Consumer updates the database.
8. Consumer sends ACK.
9. RabbitMQ removes the message.

This appears simple, but many things can go wrong.

Let's analyze each failure.

---

# Step 1 - Customer Sends Request

The customer initiates a transfer.

```http
POST /transfer

{
    "TransferId":"T1001",
    "FromAccount":"A",
    "ToAccount":"B",
    "Amount":10000
}
```

API creates an event.

```json
{
    "MessageId":"MSG-1001",
    "TransferId":"T1001",
    "Amount":10000
}
```

Now the API needs to publish it.

---

# Failure Scenario 1 - API Crashes Before Publishing

Timeline

```text
Customer
    │
Transfer API
    │
Generate Message
    │
    X Application Crash
```

The message never reaches RabbitMQ.

The customer believes the transfer has been initiated.

The system has lost the event.

---

# Why Does This Happen?

Most beginners write code like this:

```text
Save Transfer

↓

Publish RabbitMQ
```

If the application crashes after saving but before publishing:

* Database contains the transfer.
* RabbitMQ has no message.
* Downstream services never process the transfer.

The system becomes inconsistent.

---

# Solution - Transactional Outbox Pattern

Instead of publishing immediately:

```text
BEGIN TRANSACTION

Save Transfer

Save Outbox Event

COMMIT
```

Both operations succeed together.

Database

### Transfer Table

| TransferId | Amount |
| ---------- | ------ |
| T1001      | 10000  |

### Outbox Table

| EventId | TransferId | Status  |
| ------- | ---------- | ------- |
| 1       | T1001      | Pending |

If the application crashes after commit,

the Outbox record still exists.

Nothing is lost.

---

# Background Publisher

A background service continuously checks:

```sql
SELECT *
FROM Outbox
WHERE Status='Pending'
```

Every pending event is published later.

Even if the API crashes,

messages are eventually published.

---

# Failure Scenario 2 - Network Failure During Publish

Background worker publishes.

```text
Background Worker

↓

RabbitMQ

↓

Network Failure
```

Question:

Did RabbitMQ receive the message?

Nobody knows.

The worker cannot assume success.

---

# Incorrect Approach

```text
Publish()

↓

Mark Outbox = Sent
```

If RabbitMQ never receives the message,

the Outbox incorrectly shows it as sent.

Message lost forever.

---

# Solution - Publisher Confirms

RabbitMQ supports Publisher Confirms.

Flow:

```text
Publish

↓

RabbitMQ Stores Message

↓

RabbitMQ Sends ACK

↓

Worker Marks Outbox = Sent
```

Only after receiving confirmation:

```sql
UPDATE Outbox
SET Status='Sent'
```

If ACK never arrives,

leave the status as Pending.

Retry later.

---

# Failure Scenario 3 - RabbitMQ Server Crash

Suppose RabbitMQ receives the message.

Immediately afterward,

the server loses power.

```text
Publish

↓

RabbitMQ

↓

Power Failure
```

If queues exist only in memory,

the message disappears.

---

# Solution

Use:

* Durable Queue
* Persistent Messages

Durable Queue

```text
Queue survives restart.
```

Persistent Message

```text
Message survives restart.
```

After RabbitMQ restarts,

the queue still contains the message.

---

# Failure Scenario 4 - Consumer Crashes

Consumer receives the message.

```text
RabbitMQ

↓

Consumer

↓

Start Processing

↓

Application Crash
```

What happens?

It depends on acknowledgements.

---

# Incorrect Configuration - Auto ACK

```text
Receive Message

↓

RabbitMQ Removes Message

↓

Consumer Crashes
```

The transfer never happens.

Message is permanently lost.

---

# Correct Configuration - Manual ACK

Flow:

```text
Receive Message

↓

Business Logic

↓

Update SQL Server

↓

ACK
```

RabbitMQ removes the message **only after** receiving ACK.

If the consumer crashes before ACK,

RabbitMQ automatically requeues the message.

Another consumer processes it.

No message is lost.

---

# Failure Scenario 5 - ACK Lost

This is one of the most important interview questions.

Timeline

```text
Consumer

↓

Update Database ✔

↓

Network Failure

↓

ACK Lost
```

RabbitMQ never receives the ACK.

It assumes processing failed.

The message is delivered again.

---

# Problem

Database already contains:

```text
Transfer Completed
```

Message is delivered again.

Without protection:

```text
Account A

↓

Deduct ₹10,000

↓

Deduct ₹10,000 Again
```

Customer loses ₹20,000.

---

# Solution - Idempotent Consumer

Every message contains a unique identifier.

```text
MessageId = MSG-1001
```

Database

### ProcessedMessages

| MessageId |
| --------- |
| MSG-1001  |

Consumer Flow

```text
Receive Message

↓

Check ProcessedMessages

↓

Already Exists?

↓

Yes

↓

ACK Immediately
```

Otherwise:

```text
Begin Transaction

↓

Transfer Money

↓

Insert MessageId

↓

Commit

↓

ACK
```

No matter how many times RabbitMQ redelivers the message,

the transfer executes only once.

---

# Failure Scenario 6 - Database Down

Consumer receives the message.

SQL Server becomes unavailable.

```text
Receive

↓

Update Database

↓

SQL Exception
```

Consumer throws an exception.

No ACK is sent.

RabbitMQ waits.

Later it redelivers the message.

After SQL Server becomes available,

processing succeeds.

Nothing is lost.

---

# Failure Scenario 7 - Poison Message

Message

```json
{
    "Amount":-100
}
```

Every attempt fails.

RabbitMQ retries forever.

This blocks the queue.

---

# Solution - Dead Letter Queue (DLQ)

Configure retry policy.

```text
Retry Count = 5
```

Flow

```text
Main Queue

↓

Consumer

↓

Failure

↓

Retry

↓

Retry

↓

Retry

↓

Dead Letter Queue
```

Operations team investigates the invalid message separately.

Other valid messages continue processing.

---

# Why ACK Should Be Sent Last

Many interviewers ask:

> Why not acknowledge immediately?

Because:

```text
Receive

↓

ACK

↓

Application Crash
```

RabbitMQ believes processing succeeded.

Database never updated.

Message disappears forever.

Correct flow:

```text
Receive

↓

Business Logic

↓

Database Commit

↓

ACK
```

---

# Why RabbitMQ Delivers Duplicates

RabbitMQ guarantees **At-Least-Once Delivery**.

It does **not** guarantee Exactly Once.

Whenever RabbitMQ is unsure whether processing succeeded,

it sends the message again.

Examples:

* Consumer crash
* Network failure
* ACK lost
* Timeout

Duplicates are expected.

Therefore,

Consumers must be idempotent.

---

# Exactly Once vs At Least Once

### At Most Once

```text
Message may be lost.

No duplicates.
```

### At Least Once

```text
No message loss.

Duplicates possible.
```

### Exactly Once

```text
No loss.

No duplicates.
```

RabbitMQ provides **At-Least-Once Delivery**.

Exactly Once must be implemented by the application using idempotency and transactional patterns.

---

# Complete Production Flow

```text
                    Customer
                        │
                        ▼
                 Transfer API
                        │
        Save Transfer + Outbox
              (One Transaction)
                        │
                        ▼
              Background Publisher
                        │
            Publisher Confirms
                        │
                        ▼
            RabbitMQ Exchange
                        │
                        ▼
              Durable Queue
                        │
         Persistent Messages
                        │
                        ▼
                 Consumer
                        │
          Check MessageId
          (Idempotency)
                        │
                        ▼
               SQL Transaction
                        │
         Save Business Data
         Save ProcessedMessage
                        │
                        ▼
                    ACK
                        │
                        ▼
          RabbitMQ Removes Message
```

---

# Interview Questions

## Q1. Why do we need Publisher Confirms?

Because the producer should not assume RabbitMQ successfully stored the message.

Publisher Confirms provide confirmation from RabbitMQ that the message has been accepted.

---

## Q2. Why Durable Queue?

Durable queues survive broker restarts.

Without them,

queue definitions disappear after RabbitMQ crashes.

---

## Q3. Why Persistent Messages?

Persistent messages are stored on disk.

Without persistence,

messages may disappear if RabbitMQ crashes.

---

## Q4. Why Manual ACK?

Manual acknowledgements ensure RabbitMQ removes a message only after successful business processing.

---

## Q5. Why Idempotency?

RabbitMQ may redeliver messages.

Idempotency guarantees processing the same message multiple times produces the same business result.

---

## Q6. Why Dead Letter Queue?

Some messages will never succeed.

Instead of retrying forever,

failed messages are moved to a Dead Letter Queue for investigation.

---

## Q7. Why Transactional Outbox?

It guarantees that database changes and message publishing remain consistent.

Without it,

the database may commit successfully while the event is never published.

---

# Best Practices

* Always use Durable Queues.
* Publish Persistent Messages.
* Enable Publisher Confirms.
* Use Manual ACK.
* Never ACK before processing.
* Make consumers idempotent.
* Use Transactional Outbox Pattern.
* Configure Dead Letter Queues.
* Implement retry with exponential backoff.
* Monitor queue depth, consumer lag, and DLQ size.

---
High-Level Flow of RabbitMQ
                Producer (.NET API)
                       │
        Create Business Event Message
                       │
                       ▼
                  Exchange
                       │
         Routing Key decides destination
                       │
                       ▼
                    Queue
                       │
      Message waits until a consumer is available
                       │
                       ▼
               Consumer (.NET Worker)
                       │
              Process Business Logic
                       │
                       ▼
                  Database
                       │
                 Manual ACK
                       │
                       ▼
        RabbitMQ removes the message
