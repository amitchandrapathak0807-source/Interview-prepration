# Low Level Design (LLD) - Instagram (Part 1)

> **Goal:** Before writing a single class or interface, understand **why we are doing LLD**, **what problem it solves**, and **how to think like a Senior Software Engineer**.

---

# What is Low-Level Design (LLD)?

Imagine someone asks you:

> **"Build Instagram."**

There are two ways to answer.

### Wrong Answer

```text
Create User table

Create Post table

Create Like table

Done.
```

This is database design, **not** LLD.

---

### Correct Answer

First ask:

- Who are the actors?
- What are the objects?
- How do they interact?
- What responsibilities does each object have?
- Which object owns which data?
- Which object should perform which action?
- How do we make it extensible?
- How do we avoid tightly coupled code?

This is **Object-Oriented Thinking**.

That is what LLD is.

---

# What is the Goal of LLD?

LLD answers one question:

> **"If I have to start coding tomorrow, how should I organize my classes?"**

It focuses on

- Classes
- Objects
- Interfaces
- Relationships
- Design Patterns
- SOLID Principles
- Method Design

---

# Think Like Building a Real Instagram

Suppose tomorrow your manager says

> Build Instagram.

Would you start writing

```csharp
public class User
{

}
```

No.

First you understand the business.

---

# Step 1 - Understand the Business

Ask questions.

Example

Can users

- Upload photos?
- Upload videos?
- Delete posts?
- Follow users?
- Like posts?
- Comment?
- Send messages?
- Create reels?
- Upload stories?

These become

## Functional Requirements

---

# Example

Suppose the product owner says

Instagram should support

- Users
- Posts
- Comments
- Likes
- Followers

Nothing else.

Now your system becomes much simpler.

---

# Step 2 - Think in Terms of Real World Objects

Imagine you're observing Instagram in real life.

You notice

```text
Amit

uploads

a Photo

Rahul

likes

that Photo

Priya

comments

Nice Picture
```

Immediately your brain should identify

Objects

```text
User

Photo

Comment

Like
```

These become Classes.

---

# Rule #1 of LLD

> Every important noun usually becomes a Class.

Example

Sentence

```
User uploads a Photo.
```

Nouns

```
User

Photo
```

Classes

```text
User

Photo
```

Another sentence

```
User writes Comment.
```

Nouns

```
User

Comment
```

Classes

```
User

Comment
```

---

# Example

Real World

```text
John

uploads

Vacation.jpg
```

Objects

```text
User

Post

Media
```

Question

Should User store image bytes?

No.

Because

A User is **not responsible** for storing media.

A Media object is.

This is called

> **Responsibility Assignment**

---

# Responsibility Assignment

Suppose

Instagram has

```text
100 Million Users
```

Question

Should User class store comments?

Maybe.

Should User class send notifications?

No.

Why?

Because

Notification has its own responsibility.

---

# Bad Design

```csharp
class User
{
    public void UploadPhoto(){}

    public void SendNotification(){}

    public void LikePost(){}

    public void DeleteComment(){}

    public void CompressVideo(){}

    public void ProcessPayment(){}

    public void SearchUsers(){}
}
```

Everything inside User.

Huge class.

Impossible to maintain.

This is called

```
God Class
```

Very common interview mistake.

---

# Good Design

```text
User

↓

PostService

↓

NotificationService

↓

SearchService

↓

MediaService
```

Each service has one responsibility.

This follows

```
Single Responsibility Principle
```

---

# Step 3 - Identify Relationships

Now ask

```
Can one User have multiple Posts?
```

Yes.

Relationship

```text
User

1

|

|

*

Post
```

One User

↓

Many Posts

---

Question

Can one Post have multiple Comments?

Yes.

```text
Post

1

|

|

*

Comment
```

---

Question

Can one Post have multiple Likes?

Yes.

```text
Post

1

|

|

*

Like
```

---

Question

Can User follow many Users?

Yes.

Can User be followed by many Users?

Yes.

Relationship

```text
User

*

|

|

*

User
```

This is called

```
Many to Many
```

---

# Step 4 - Find Responsibilities

Don't immediately think

```
Database
```

Instead ask

Who should perform this action?

Example

```
Like Post
```

Who should do it?

User?

Post?

LikeService?

---

Bad Design

```csharp
class User
{
    public void Like(Post post)
    {

    }
}
```

Looks okay initially.

But later

Need

- Duplicate Like Validation
- Notification
- Analytics
- Cache Update
- Event Publishing

Now User becomes huge.

---

Better

```text
User

↓

LikeService

↓

Repository

↓

Database
```

Why?

Because LikeService owns the business logic.

---

# Example

Like Flow

```text
User clicks Like

↓

LikeService

↓

Check

Already Liked?

↓

No

↓

Save Like

↓

Increase Count

↓

Send Notification

↓

Publish Event
```

Notice

Everything related to Likes stays together.

---

# Step 5 - Find Entities vs Services

This is where many candidates fail.

Example

```
User
```

Is it Entity?

Yes.

Because it stores data.

---

Example

```
LikeService
```

Stores data?

No.

Performs action?

Yes.

So

```
Service
```

---

Rule

Entities

```text
User

Post

Comment

Like

Profile
```

Services

```text
UserService

FeedService

CommentService

LikeService

NotificationService
```

---

# Step 6 - Think About Future Changes

Suppose today

Instagram supports

```
Photo
```

Tomorrow

Need

```
Video

Reels

Stories
```

Question

Should you modify

```
Post
```

every time?

No.

Instead

Use

```text
Media

▲

|

|

Image

Video

Story

Reel
```

Now adding

```
LiveStream
```

doesn't affect existing code.

This follows the

```
Open/Closed Principle
```

---

# Why Services Instead of Putting Everything in User?

Imagine this method:

```csharp
user.UploadPost();
```

Seems fine.

Now requirements grow:

- Virus scanning
- Image resizing
- AI moderation
- Blob storage upload
- Metadata extraction
- Thumbnail generation
- Feed update
- Notification
- Analytics

Would you still keep all of that inside `User`?

No.

Instead:

```text
User

↓

PostService

↓

MediaService

↓

Blob Storage

↓

Repository

↓

NotificationService

↓

FeedService
```

The `User` object represents **state**, while services represent **behavior involving multiple systems**.

---

# Example: Uploading a Photo (Real Flow)

Suppose Amit uploads a vacation photo.

What actually happens?

```text
Amit Clicks Upload

        │

        ▼

API Receives Request

        │

        ▼

Authentication

        │

        ▼

PostService

        │

        ├────────► Upload File to Azure Blob Storage

        │

        ├────────► Save Metadata in Database

        │

        ├────────► Generate Thumbnail

        │

        ├────────► Publish Event

        │

        ├────────► Feed Service

        │

        └────────► Notification Service
```

One click triggers multiple systems.

This is why we don't put everything inside one class.

---

# How Should You Think During an Interview?

Never jump directly into coding.

Instead, say:

> "Before I start writing classes, I'd like to identify the domain entities, understand their responsibilities, define relationships, and separate business logic into services following SOLID principles. This will keep the design maintainable and extensible."

This immediately demonstrates senior-level design thinking.

---

# Coming Next (Part 2)

In the next part, we will cover:

1. Domain Model
2. Complete Class Diagram
3. Associations, Aggregation, and Composition
4. Interfaces
5. Service Layer
6. Repository Layer
7. Design Patterns
8. Sequence Diagrams
9. Database Mapping
10. API Design
11. Concurrency
12. Interview Questions

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. Why do we perform LLD before writing code?

### Answer

LLD helps translate business requirements into a maintainable object-oriented design. Instead of immediately writing classes, we first identify domain entities, assign responsibilities, define relationships, apply SOLID principles, and choose appropriate design patterns. This reduces coupling, improves readability, simplifies testing, and makes the system easier to extend as new requirements emerge.

---

## Q2. How do you identify classes during an interview?

### Answer

I begin by reading the requirements and identifying the **important nouns**, which often become domain entities (e.g., `User`, `Post`, `Comment`, `Like`). Then I identify the **verbs**, which usually become behaviors or service methods (e.g., `Follow()`, `LikePost()`, `AddComment()`). Finally, I determine which object should own each responsibility based on the Single Responsibility Principle.

---

## Q3. Why shouldn't a `User` class contain all business logic?

### Answer

A `User` entity should primarily represent the user's state and core behavior. Business workflows such as uploading media, sending notifications, generating feeds, or processing likes often involve multiple systems and external dependencies. Placing all of this logic inside `User` creates a **God Class**, violating the Single Responsibility Principle and making the code difficult to maintain, test, and extend. Instead, these workflows belong in dedicated service classes such as `PostService`, `FeedService`, and `NotificationService`.
