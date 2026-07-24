# Instagram Database Schema (Complete Explanation)

> **Interview Level:** 10+ Years Experience

In interviews, **don't start by writing SQL**.

Start by explaining **why each table exists**.

A database table exists because it represents a **real-world business entity**.

---

# Step 1 - What data does Instagram need?

Let's think like a Product Owner.

A user can

- Register
- Upload Posts
- Follow Users
- Like Posts
- Comment
- Save Posts
- Receive Notifications

Immediately we identify the entities.

```text
User

Post

Comment

Like

Follow

SavedPost

Notification

Media
```

Each entity becomes a table.

---

# Complete Database Schema

```text
                   USERS
                     |
          1          |
                     |
                     *
                   POSTS
               /      |      \
              /       |       \
             *        *        *
      COMMENTS      LIKES   SAVEDPOSTS
             
USERS
  *
  |
  |
  *
FOLLOWS

USERS
  |
  |
  *
NOTIFICATIONS
```

---

# 1. Users Table

## Why do we need Users?

Everything in Instagram revolves around a User.

Without users there are

- No posts
- No likes
- No comments
- No followers

Hence User becomes the parent entity.

---

## Schema

```sql
CREATE TABLE Users
(
    UserId UNIQUEIDENTIFIER PRIMARY KEY,

    UserName NVARCHAR(100) NOT NULL UNIQUE,

    Email NVARCHAR(200) NOT NULL UNIQUE,

    PasswordHash NVARCHAR(500) NOT NULL,

    FullName NVARCHAR(200),

    Bio NVARCHAR(500),

    ProfilePictureUrl NVARCHAR(500),

    IsPrivate BIT DEFAULT 0,

    IsVerified BIT DEFAULT 0,

    CreatedAt DATETIME2 NOT NULL,

    UpdatedAt DATETIME2 NOT NULL
);
```

---

## Column Explanation

| Column | Why? |
|----------|------|
| UserId | Unique identifier for every user |
| UserName | Used in profile URLs and search |
| Email | Login |
| PasswordHash | Never store plain passwords |
| FullName | Display |
| Bio | Profile description |
| ProfilePictureUrl | Image location |
| IsPrivate | Private account support |
| IsVerified | Blue tick |
| CreatedAt | Audit |
| UpdatedAt | Audit |

---

## Why UserId instead of Username?

Imagine

```
amit123
```

changes username to

```
amit_pathak
```

All foreign keys break.

Primary Keys should never change.

Therefore

```
UserId
```

is used everywhere.

---

# 2. Posts Table

## Why separate table?

Question

Should posts be stored inside Users?

No.

Imagine

```
Cristiano Ronaldo

5000 Posts
```

Every profile fetch would load thousands of posts.

Very expensive.

Hence

Posts get their own table.

---

## Schema

```sql
CREATE TABLE Posts
(
    PostId UNIQUEIDENTIFIER PRIMARY KEY,

    UserId UNIQUEIDENTIFIER NOT NULL,

    Caption NVARCHAR(MAX),

    MediaUrl NVARCHAR(1000) NOT NULL,

    MediaType TINYINT NOT NULL,

    Location NVARCHAR(200),

    LikeCount INT DEFAULT 0,

    CommentCount INT DEFAULT 0,

    CreatedAt DATETIME2 NOT NULL,

    UpdatedAt DATETIME2 NOT NULL,

    CONSTRAINT FK_Post_User
        FOREIGN KEY(UserId)
        REFERENCES Users(UserId)
);
```

---

## Why LikeCount?

Instead of

```sql
SELECT COUNT(*)

FROM Likes
```

every time,

Instagram stores the count.

Much faster.

This is called

```
Denormalization
```

---

## Why MediaUrl?

Images are stored in

- Azure Blob Storage
- Amazon S3

Database stores only

```
URL
```

---

# 3. Comments Table

## Why separate table?

Suppose

One post has

```
100,000 Comments
```

Should those comments be stored inside Post?

No.

Reasons

- Huge row
- Slow update
- Difficult pagination
- Lock contention

---

## Schema

```sql
CREATE TABLE Comments
(
    CommentId UNIQUEIDENTIFIER PRIMARY KEY,

    PostId UNIQUEIDENTIFIER NOT NULL,

    UserId UNIQUEIDENTIFIER NOT NULL,

    ParentCommentId UNIQUEIDENTIFIER NULL,

    CommentText NVARCHAR(1000) NOT NULL,

    CreatedAt DATETIME2 NOT NULL,

    UpdatedAt DATETIME2 NOT NULL,

    FOREIGN KEY(PostId)
        REFERENCES Posts(PostId),

    FOREIGN KEY(UserId)
        REFERENCES Users(UserId),

    FOREIGN KEY(ParentCommentId)
        REFERENCES Comments(CommentId)
);
```

---

## ParentCommentId

Supports

```text
Reply

↓

Reply

↓

Reply
```

Nested comments.

---

# 4. Likes Table

## Business Rule

One user

can like

One post

Only once.

---

## Schema

```sql
CREATE TABLE Likes
(
    UserId UNIQUEIDENTIFIER NOT NULL,

    PostId UNIQUEIDENTIFIER NOT NULL,

    CreatedAt DATETIME2 NOT NULL,

    PRIMARY KEY(UserId,PostId),

    FOREIGN KEY(UserId)
        REFERENCES Users(UserId),

    FOREIGN KEY(PostId)
        REFERENCES Posts(PostId)
);
```

---

## Why Composite Primary Key?

Question

Why not

```
LikeId
```

Answer

Business Rule

```
One User

↓

One Post

↓

One Like
```

Composite Key naturally enforces this.

No duplicates.

---

# 5. Follow Table

## Relationship

Question

Can

Rahul

follow

1000 people?

Yes.

Can

1000 people

follow Rahul?

Yes.

Relationship

```
Many

↓

Many
```

---

## Schema

```sql
CREATE TABLE Follows
(
    FollowerId UNIQUEIDENTIFIER NOT NULL,

    FollowingId UNIQUEIDENTIFIER NOT NULL,

    CreatedAt DATETIME2 NOT NULL,

    PRIMARY KEY
    (
        FollowerId,

        FollowingId
    ),

    FOREIGN KEY(FollowerId)
        REFERENCES Users(UserId),

    FOREIGN KEY(FollowingId)
        REFERENCES Users(UserId)
);
```

---

## Why No FollowId?

This relationship itself is unique.

```
FollowerId

+

FollowingId
```

already identifies the row.

---

# 6. Saved Posts

## Business

Users can save posts.

---

## Schema

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
    ),

    FOREIGN KEY(UserId)
        REFERENCES Users(UserId),

    FOREIGN KEY(PostId)
        REFERENCES Posts(PostId)
);
```

---

# 7. Notifications

```sql
CREATE TABLE Notifications
(
    NotificationId UNIQUEIDENTIFIER PRIMARY KEY,

    UserId UNIQUEIDENTIFIER NOT NULL,

    TriggeredByUserId UNIQUEIDENTIFIER,

    PostId UNIQUEIDENTIFIER NULL,

    NotificationType TINYINT NOT NULL,

    IsRead BIT DEFAULT 0,

    CreatedAt DATETIME2 NOT NULL,

    FOREIGN KEY(UserId)
        REFERENCES Users(UserId),

    FOREIGN KEY(TriggeredByUserId)
        REFERENCES Users(UserId),

    FOREIGN KEY(PostId)
        REFERENCES Posts(PostId)
);
```

---

# Why TriggeredByUserId?

Example

```
Rahul

liked

Amit's Post
```

Need

```
Rahul

performed action
```

Hence

```
TriggeredByUserId
```

---

# Why PostId Nullable?

Some notifications

don't involve posts.

Example

```
Rahul followed Amit
```

No Post.

---

# Complete ER Diagram

```text
+------------------+
|      USERS       |
+------------------+
| PK UserId        |
| UserName         |
| Email            |
| PasswordHash     |
| Bio              |
| ProfilePicture   |
+---------+--------+
          |
          | 1
          |
          | *
+---------v--------+
|      POSTS       |
+------------------+
| PK PostId        |
| FK UserId        |
| Caption          |
| MediaUrl         |
| LikeCount        |
| CommentCount     |
+---+----------+---+
    |          |
    |          |
    |          |
    |          |
    *          *
+-------+   +-------+
|LIKES  |   |COMMENTS|
+-------+   +--------+
|PK User|   |PK CommentId|
|PK Post|   |FK UserId   |
|        |   |FK PostId   |
+--------+   +------------+

+------------------------+
|       FOLLOWS          |
+------------------------+
| PK FollowerId          |
| PK FollowingId         |
+------------------------+

+------------------------+
|     SAVED POSTS        |
+------------------------+
| PK UserId              |
| PK PostId              |
+------------------------+

+------------------------+
|   NOTIFICATIONS        |
+------------------------+
| PK NotificationId      |
| FK UserId              |
| FK TriggeredByUserId   |
| FK PostId              |
+------------------------+
```

---

# Recommended Indexes

## Users

```sql
CREATE UNIQUE INDEX IX_User_UserName
ON Users(UserName);

CREATE UNIQUE INDEX IX_User_Email
ON Users(Email);
```

---

## Posts

```sql
CREATE INDEX IX_Post_UserId_CreatedAt
ON Posts(UserId,CreatedAt DESC);
```

Supports

```sql
SELECT *

FROM Posts

WHERE UserId=@UserId

ORDER BY CreatedAt DESC;
```

---

## Comments

```sql
CREATE INDEX IX_Comment_PostId
ON Comments(PostId,CreatedAt);
```

---

## Likes

```sql
CREATE INDEX IX_Like_PostId
ON Likes(PostId);
```

Useful for

```
Like Count
```

---

## Follows

```sql
CREATE INDEX IX_Follower
ON Follows(FollowerId);

CREATE INDEX IX_Following
ON Follows(FollowingId);
```

---

## Notifications

```sql
CREATE INDEX IX_Notification_User
ON Notifications(UserId,CreatedAt DESC);
```

---

# Common Queries

## Fetch User Posts

```sql
SELECT *

FROM Posts

WHERE UserId=@UserId

ORDER BY CreatedAt DESC;
```

---

## Fetch Feed

```sql
SELECT P.*

FROM Posts P

JOIN Follows F

ON P.UserId=F.FollowingId

WHERE F.FollowerId=@CurrentUser

ORDER BY P.CreatedAt DESC;
```

---

## Like Count

```sql
SELECT COUNT(*)

FROM Likes

WHERE PostId=@PostId;
```

(In production, prefer the cached `LikeCount` column.)

---

## Fetch Comments

```sql
SELECT *

FROM Comments

WHERE PostId=@PostId

ORDER BY CreatedAt;
```

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. Why do we use surrogate keys (`UserId`, `PostId`) instead of business keys like `UserName`?

### Answer

Business attributes such as usernames and email addresses can change over time, while primary keys should remain immutable. Using surrogate keys (`UNIQUEIDENTIFIER` or `BIGINT`) ensures stable relationships, simplifies foreign keys, and avoids cascading updates across multiple tables.

---

## Q2. Why does the `Likes` table use a composite primary key?

### Answer

The business rule states that a user can like a post only once. A composite primary key `(UserId, PostId)` enforces this uniqueness at the database level without requiring an additional `LikeId`. It also improves lookup performance for common operations such as checking whether a user has already liked a post.

---

## Q3. Why store `LikeCount` and `CommentCount` in the `Posts` table when that duplicates data?

### Answer

This is an intentional **denormalization** for performance. Calculating counts using `COUNT(*)` on every request would be expensive for highly active posts. Maintaining cached counters allows the application to display counts with a simple row lookup while updating the counters transactionally or asynchronously when likes and comments are added or removed.

---

## Q4. Which indexes are most critical for Instagram?

### Answer

The highest-value indexes correspond to the most common queries:

- `Users(UserName)` for profile lookup.
- `Users(Email)` for login.
- `Posts(UserId, CreatedAt)` for user profile pages.
- `Comments(PostId)` for loading comments.
- `Likes(PostId)` for engagement metrics.
- `Follows(FollowerId)` for feed generation.
- `Notifications(UserId, CreatedAt)` for notification retrieval.

Indexes should always be designed around **query patterns**, not just table structure.
