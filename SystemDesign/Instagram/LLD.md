# Low-Level Design (LLD) - Instagram (Deep Dive)

> **Interview Level:** Senior Software Engineer / Tech Lead / Staff Engineer (10+ Years)

This explanation focuses on **how to think**, **why we make each design decision**, and **how the object model maps to the database**.

> **Note:** In interviews, don't start by drawing classes. Start by understanding the business domain and modelling the real world.

---

# 1. Why Do We Need LLD?

Imagine your manager says:

> "We need to build Instagram."

Your first instinct might be to create a `User` class and a `Post` class.

That is **too early**.

A senior engineer first asks:

- What problem are we solving?
- Who uses the system?
- What actions do they perform?
- Which objects exist in the domain?
- Which object owns which responsibility?
- How will the design evolve when requirements change?

LLD is the bridge between **business requirements** and **production-ready code**.

---

# 2. Think Like a Real Business

Forget code for a moment.

Imagine you're watching people use Instagram.

### Amit opens Instagram

```text
Amit logs in.
```

### Amit uploads a photo

```text
Photo = "Goa Vacation"
Caption = "Amazing Sunset"
```

### Rahul follows Amit

```text
Rahul → Follow → Amit
```

### Priya likes the photo

```text
Priya → Like → Post
```

### Neha comments

```text
Beautiful ❤️
```

Without writing a single line of code, you have already discovered the main business objects.

---

# 3. Finding Domain Entities

A useful interview technique:

> **Highlight the nouns in the requirement.**

Example:

```text
User uploads a photo.

Another user likes the photo.

Someone comments on the photo.
```

Nouns:

- User
- Photo
- Comment
- Like

These become entities.

---

# Why Are These Entities?

Because each has:

- Identity
- Data
- Lifecycle
- Relationships

Example:

A comment has:

```text
CommentId
Text
CreatedDate
UserId
PostId
```

It has its own identity.

Therefore it deserves its own entity.

---

# 4. Finding Relationships

Let's examine each relationship carefully.

## User → Post

Question:

Can one user create multiple posts?

Yes.

Can one post belong to multiple users?

No.

Relationship:

```text
User
 1
 |
 |
 *
Post
```

This is called:

**One-to-Many**

---

## Why Not Store Posts Inside User Table?

Bad design:

```text
User

Posts =
[
Post1,
Post2,
Post3
]
```

Problems:

- Cannot query efficiently.
- Difficult to paginate.
- Large user records.
- Difficult to index.

Instead:

```text
User

↓

Post

UserId
```

The database naturally models the relationship.

---

## User → Follow

Question:

Can Amit follow Rahul?

Yes.

Can Rahul follow Amit?

Yes.

Can Rahul follow Neha?

Yes.

Relationship:

```text
User

*

|

|

*

User
```

Many-to-Many.

This requires a junction table.

---

## Why Not Store Followers in User Table?

Wrong:

```text
User

Followers

101

205

400

900
```

Problems:

- Unlimited growth.
- Difficult indexing.
- Difficult joins.
- Poor normalization.

Correct:

```text
Follow Table

FollowerId

FollowingId
```

---

# 5. What Belongs Inside User?

Many developers make this mistake.

```csharp
class User
{
    UploadPhoto()

    LikePost()

    DeleteComment()

    GenerateFeed()

    SendNotification()

    Search()
}
```

This is terrible.

Why?

Because User now knows everything.

It violates:

- Single Responsibility Principle.
- Open/Closed Principle.
- Separation of Concerns.

---

# What Should User Really Represent?

Think of User as a real person.

A person has:

```text
Id

Username

Email

DOB

Profile
```

That's it.

Business operations belong elsewhere.

---

# Good Design

```text
User

↓

UserService

↓

PostService

↓

LikeService

↓

NotificationService
```

Each service owns one business capability.

---

# 6. Why Do We Need Services?

Let's examine uploading a photo.

User clicks:

```text
Upload
```

What happens?

### Step 1

Authenticate.

### Step 2

Validate image.

### Step 3

Resize image.

### Step 4

Generate thumbnail.

### Step 5

Upload to Blob Storage.

### Step 6

Save metadata.

### Step 7

Generate feed.

### Step 8

Notify followers.

Should all this live inside:

```csharp
User.UploadPhoto()
```

No.

That's why we create:

```text
PostService
```

---

# 7. Responsibilities

## User

Responsible for

- Identity
- Profile

NOT

- Notifications
- Feed
- Search
- Blob upload

---

## Post

Responsible for

- Caption
- Media
- Creation date

NOT

- Sending push notifications.

---

## Like

Responsible for

- Who liked.
- Which post.

Nothing else.

---

## Comment

Responsible for

- Text.
- Owner.
- Timestamp.

---

# 8. Database Schema

Now that we understand the domain, the database becomes much easier.

---

# USER

```sql
CREATE TABLE Users
(
    UserId UNIQUEIDENTIFIER PRIMARY KEY,

    UserName NVARCHAR(100) UNIQUE,

    Email NVARCHAR(200),

    PasswordHash NVARCHAR(MAX),

    ProfilePictureUrl NVARCHAR(MAX),

    Bio NVARCHAR(500),

    CreatedAt DATETIME2
)
```

---

## Why these columns?

| Column | Reason |
|----------|--------|
| UserId | Primary Key |
| UserName | Login/Search |
| Email | Authentication |
| PasswordHash | Security |
| Bio | Profile |
| ProfilePictureUrl | Display |

---

# POST

```sql
CREATE TABLE Posts
(
    PostId UNIQUEIDENTIFIER PRIMARY KEY,

    UserId UNIQUEIDENTIFIER,

    Caption NVARCHAR(MAX),

    MediaUrl NVARCHAR(MAX),

    MediaType INT,

    CreatedAt DATETIME2,

    FOREIGN KEY(UserId)

    REFERENCES Users(UserId)
)
```

Relationship

```text
User

1

↓

Many Posts
```

---

# COMMENT

```sql
CREATE TABLE Comments
(
    CommentId UNIQUEIDENTIFIER PRIMARY KEY,

    UserId UNIQUEIDENTIFIER,

    PostId UNIQUEIDENTIFIER,

    Text NVARCHAR(MAX),

    CreatedAt DATETIME2
)
```

Relationship

```text
User

↓

Comment

↓

Post
```

---

# LIKE

```sql
CREATE TABLE Likes
(
    UserId UNIQUEIDENTIFIER,

    PostId UNIQUEIDENTIFIER,

    CreatedAt DATETIME2,

    PRIMARY KEY(UserId,PostId)
)
```

Why Composite Key?

Because

One user

Cannot like

Same post twice.

---

# FOLLOW

```sql
CREATE TABLE Follows
(
    FollowerId UNIQUEIDENTIFIER,

    FollowingId UNIQUEIDENTIFIER,

    CreatedAt DATETIME2,

    PRIMARY KEY
    (
        FollowerId,

        FollowingId
    )
)
```

Relationship

```text
Rahul

↓

Follows

↓

Amit
```

This table stores only relationships.

---

# NOTIFICATION

```sql
CREATE TABLE Notifications
(
    NotificationId UNIQUEIDENTIFIER PRIMARY KEY,

    UserId UNIQUEIDENTIFIER,

    Type INT,

    Message NVARCHAR(MAX),

    IsRead BIT,

    CreatedAt DATETIME2
)
```

---

# SAVED POSTS

```sql
CREATE TABLE SavedPosts
(
    UserId UNIQUEIDENTIFIER,

    PostId UNIQUEIDENTIFIER,

    SavedAt DATETIME2,

    PRIMARY KEY
    (
        UserId,

        PostId
    )
)
```

---

# Complete Database ER Diagram

```text
                 USERS
+-----------------------------------+
| PK UserId                         |
| UserName                          |
| Email                             |
| PasswordHash                      |
| Bio                               |
| ProfilePictureUrl                 |
| CreatedAt                         |
+----------------+------------------+
                 |
                 | 1
                 |
                 | *
          +------v------------------+
          |        POSTS            |
          +-------------------------+
          | PK PostId               |
          | FK UserId               |
          | Caption                 |
          | MediaUrl                |
          | MediaType               |
          | CreatedAt               |
          +------+------------------+
                 |
        +--------+---------+
        |                  |
      1 |                  | 1
        |                  |
        | *                | *
+-------v---------+   +----v-----------+
|   COMMENTS      |   |    LIKES       |
+-----------------+   +----------------+
| PK CommentId    |   | PK UserId      |
| FK PostId       |   | PK PostId      |
| FK UserId       |   | CreatedAt      |
| Text            |   +----------------+
| CreatedAt       |
+-----------------+

USERS
   *
   |
   |
   *
FOLLOWS
+---------------------------+
| PK FollowerId             |
| PK FollowingId            |
| CreatedAt                 |
+---------------------------+

USERS
   *
   |
   |
   *
SAVED POSTS
+---------------------------+
| PK UserId                 |
| PK PostId                 |
| SavedAt                   |
+---------------------------+

USERS
   1
   |
   |
   *
NOTIFICATIONS
+---------------------------+
| PK NotificationId         |
| FK UserId                 |
| Type                      |
| Message                   |
| IsRead                    |
| CreatedAt                 |
+---------------------------+
```

---

# Why Normalize the Database?

Suppose we stored comments inside the `Posts` table:

```text
Post

Comment1

Comment2

Comment3

Comment4

Comment5
```

Problems:

- Variable-sized rows.
- Difficult querying.
- Impossible to index comments efficiently.
- Updating a single comment rewrites the entire row.

Normalization solves these issues by storing comments separately.

---

# Indexing Strategy

A production system should create indexes based on query patterns.

```sql
CREATE INDEX IX_Post_UserId
ON Posts(UserId);
```

Used for:

```sql
SELECT *
FROM Posts
WHERE UserId = @UserId;
```

---

```sql
CREATE INDEX IX_Comments_PostId
ON Comments(PostId);
```

Used for:

```sql
SELECT *
FROM Comments
WHERE PostId = @PostId;
```

---

```sql
CREATE INDEX IX_Follows_FollowerId
ON Follows(FollowerId);
```

Used for:

```sql
SELECT FollowingId
FROM Follows
WHERE FollowerId = @UserId;
```

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. Why do we separate entities and services?

### Answer

Entities model the **business state** (e.g., `User`, `Post`, `Comment`) and should contain only behavior directly related to that state. Services orchestrate workflows that involve multiple entities or external systems (e.g., uploading media, sending notifications, generating feeds). Separating them improves maintainability, testability, and adherence to the Single Responsibility Principle.

---

## Q2. Why is the `Follows` table implemented as a junction table?

### Answer

Following is a **many-to-many** relationship: one user can follow many users, and one user can be followed by many users. A junction table (`FollowerId`, `FollowingId`) models this efficiently, supports indexing, avoids data duplication, and allows additional metadata (e.g., `CreatedAt`) to be stored.

---

## Q3. Why use a composite primary key for the `Likes` table?

### Answer

The business rule is that **a user can like a specific post only once**. A composite primary key `(UserId, PostId)` enforces this rule at the database level, preventing duplicate likes even under concurrent requests. It also avoids the need for a separate surrogate key for this relationship.
