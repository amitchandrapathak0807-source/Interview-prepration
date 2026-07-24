# JSON Web Token (JWT) - Complete Guide (From Beginner to Production)

> **Interview Level:** Senior Software Engineer / Tech Lead / Architect (10+ Years)

---

# Table of Contents

1. Why JWT was introduced
2. Traditional Authentication
3. Problems with Session-Based Authentication
4. What is JWT?
5. How JWT Works
6. JWT Structure
7. Header
8. Payload
9. Signature
10. Login Flow
11. API Flow
12. JWT Validation
13. JWT Expiration
14. Refresh Token
15. JWT Security
16. JWT vs Session
17. JWT vs OAuth
18. JWT Best Practices
19. Interview Questions

---

# Chapter 1 - Why Was JWT Introduced?

Before understanding JWT,

let's understand the problem it solves.

Imagine you are building

```
Instagram
```

A user logs in using

```
Username

Password
```

Server verifies the credentials.

Now the user starts using Instagram.

They perform

- View Feed
- Like Post
- Upload Photo
- Comment
- Follow Users

Question:

**Should the user send username and password with every request?**

Example

```http
GET /feed

Username : amit

Password : password123
```

Again

```http
POST /like

Username : amit

Password : password123
```

Again

```http
POST /comment

Username : amit

Password : password123
```

Would this be secure?

Absolutely not.

---

# Why Not?

Imagine someone intercepts the request.

They now have

```
Username

Password
```

They can log in forever.

Passwords should never travel repeatedly over the network.

---

# Traditional Solution (Session-Based Authentication)

Before JWT existed,

web applications used **Sessions**.

Flow

```
User logs in

↓

Server validates password

↓

Server creates Session

↓

Stores Session in Memory

↓

Returns Session ID

↓

Browser stores Session ID in Cookie
```

Example

```
SessionId

ABC123XYZ
```

Every request sends

```
Cookie

SessionId=ABC123XYZ
```

Server checks

```
Memory

↓

Session Found?

↓

Yes

↓

User Authenticated
```

---

# Problem with Sessions

Imagine Instagram has

```
100 Servers
```

User logs into

```
Server 1
```

Session exists only in

```
Server 1 Memory
```

Next request goes to

```
Server 57
```

Server 57 says

```
Session not found.
```

User appears logged out.

---

# Possible Solutions

Store sessions in

- SQL
- Redis

Now every server can access sessions.

Works.

But now

every request requires

database/cache lookup.

As traffic grows,

this becomes expensive.

---

# JWT Solves This Problem

Instead of storing user information

on the server,

JWT stores the information

inside the token itself.

Think of JWT as a **digitally signed identity card**.

---

# Real Life Example

Imagine you enter an office.

Security verifies your identity.

Instead of asking for your Aadhaar card every time,

they give you an employee badge.

The badge contains:

```
Employee ID

Name

Department

Expiry Date
```

Whenever you enter another floor,

security simply checks your badge.

They don't call HR every time.

JWT works exactly like that.

---

# What is JWT?

JWT stands for

```
JSON

Web

Token
```

It is a compact,

digitally signed token

used to securely transfer information

between two parties.

Most commonly,

it contains

```
User Id

Roles

Permissions

Expiry
```

---

# Chapter 2 - JWT Login Flow

Let's understand the complete flow.

Suppose Amit logs into Instagram.

### Step 1

User enters

```
Username

Password
```

Request

```http
POST /login
```

---

### Step 2

Backend validates credentials.

Checks

```
Username exists?

Password correct?
```

If invalid

```
401 Unauthorized
```

If valid

Backend creates JWT.

---

### Step 3

Server Generates JWT

Example Payload

```json
{
    "sub":"123",

    "name":"Amit",

    "role":"Admin",

    "exp":1750000000
}
```

Server signs the token.

Returns

```json
{
    "access_token":"eyJhbGciOiJIUzI1Ni..."
}
```

---

### Step 4

Client Stores Token

The client stores the JWT.

Examples

- Secure HttpOnly Cookie (recommended for browsers)
- Secure mobile storage
- In-memory storage (depending on architecture)

---

### Step 5

Client Calls APIs

Suppose Amit requests

```
GET /feed
```

Request

```http
Authorization

Bearer eyJhbGc...
```

Notice

Username

Password

are never sent again.

---

### Step 6

Server Validates JWT

The server checks

- Signature
- Expiration
- Issuer
- Audience

If valid

Request proceeds.

---

# Complete Flow

```text
User logs in

↓

Server validates password

↓

Server creates JWT

↓

JWT sent to Client

↓

Client stores JWT

↓

Every API sends JWT

↓

Server validates JWT

↓

API executes
```

---

# Chapter 3 - JWT Structure

A JWT has

three parts.

```
Header

Payload

Signature
```

Format

```
xxxxx.yyyyy.zzzzz
```

Each part is Base64Url encoded.

---

# Example JWT

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9

.

eyJzdWIiOiIxMjMiLCJuYW1lIjoiQW1pdCJ9

.

f3Dkjsdf98sd89sd...
```

Three parts

separated by

```
.
```

---

# Part 1 - Header

Example

```json
{
  "alg":"HS256",

  "typ":"JWT"
}
```

Meaning

```
Algorithm

HS256

Token Type

JWT
```

---

# Part 2 - Payload

Payload contains

Claims.

Example

```json
{
    "sub":"123",

    "name":"Amit",

    "role":"Admin",

    "department":"IT",

    "exp":1750000000
}
```

Notice

Payload is

NOT encrypted.

Anyone can decode it.

Therefore

Never store

```
Password

Credit Card

PAN

Secrets
```

inside JWT.

---

# Common Claims

| Claim | Meaning |
|--------|----------|
| sub | Subject (User ID) |
| iss | Issuer |
| aud | Audience |
| exp | Expiration |
| iat | Issued At |
| nbf | Not Before |
| jti | JWT ID |

---

# Part 3 - Signature

This is the most important part.

Server computes

```
Header

+

Payload

+

Secret Key
```

using

```
HMAC SHA256

or

RSA
```

Produces

```
Signature
```

---

# Why Signature?

Suppose someone changes

```
Role

User

↓

Admin
```

Payload changes.

Signature no longer matches.

Server immediately rejects the token.

This prevents tampering.

---

# How JWT Validation Works

Suppose client sends

```http
Authorization

Bearer eyJhbGc...
```

Server performs

### Step 1

Decode Header.

---

### Step 2

Read Algorithm.

Example

```
HS256
```

---

### Step 3

Using the same Secret Key,

server generates a new signature.

---

### Step 4

Compare

```
Incoming Signature

==

Generated Signature?
```

If yes

Token is genuine.

If no

Reject.

---

### Step 5

Check Expiry

Example

```
Current Time

>

Expiry
```

Reject.

---

### Step 6

Check Audience

Is this token meant for

our API?

---

### Step 7

Check Issuer

Was token generated

by our Authentication Server?

---

### Step 8

Create User Identity

Claims become

```
HttpContext.User
```

ASP.NET automatically builds

a `ClaimsPrincipal`.

---

# ASP.NET Core Example

```csharp
builder.Services
.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
.AddJwtBearer(options =>
{
    options.TokenValidationParameters =
        new TokenValidationParameters
        {
            ValidateIssuer = true,

            ValidateAudience = true,

            ValidateLifetime = true,

            ValidateIssuerSigningKey = true,

            ValidIssuer = "MyCompany",

            ValidAudience = "MyAPI",

            IssuerSigningKey =
                new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(secret))
        };
});
```

---

# Why JWT is Stateless

Question

Where is the user session stored?

Answer

Nowhere.

Everything required

is inside JWT.

Server doesn't store anything.

This makes scaling easy.

---

# JWT Expiration

Suppose

JWT expires after

```
1 Hour
```

After expiry

Server returns

```
401 Unauthorized
```

Client uses

Refresh Token

to obtain

new JWT.

---

# JWT vs Session

| JWT | Session |
|------|----------|
| Stateless | Stateful |
| Server stores nothing | Server stores session |
| Better for microservices | Simpler for monoliths |
| Easy horizontal scaling | Requires shared session store when scaled |
| Token sent with each request | Session ID sent with each request |

---

# JWT vs OAuth

This is one of the most common interview questions.

JWT

```
Token Format
```

OAuth

```
Authorization Framework
```

OAuth may issue

JWT

or

Opaque Tokens.

JWT can also be used

without OAuth.

---

# JWT Security Best Practices

- Always use HTTPS.
- Keep Access Tokens short-lived.
- Don't store sensitive information in the payload.
- Validate issuer, audience, signature, and expiration.
- Rotate signing keys.
- Prefer asymmetric signing (RS256) in distributed systems.
- Store tokens securely.
- Use Refresh Tokens for long-lived sessions.

---

# Complete JWT Flow

```text
User enters username and password

↓

Authentication Server validates credentials

↓

JWT is created and digitally signed

↓

JWT returned to client

↓

Client stores JWT

↓

Every API request includes:

Authorization: Bearer <JWT>

↓

API validates:

- Signature
- Expiry
- Issuer
- Audience

↓

If valid

↓

Request is processed
```

---

# JWT vs OAuth vs OpenID Connect

| Feature | JWT | OAuth2 | OpenID Connect |
|----------|------|---------|----------------|
| Purpose | Token Format | Authorization | Authentication + Authorization |
| User Identity | Optional | No | Yes |
| Access Control | Through claims | Through scopes | Through scopes + ID Token |
| Can Use JWT? | N/A | Yes | Yes |

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. Why is JWT called a stateless authentication mechanism?

### Answer

JWT is stateless because the server does not store session information. All the information required to identify and authorize the user—such as user ID, roles, permissions, issuer, audience, and expiration—is embedded inside the token. Each request is self-contained, allowing any server instance to validate the token without consulting a shared session store.

---

## Q2. Why shouldn't sensitive data be stored in the JWT payload?

### Answer

The JWT payload is **Base64Url encoded, not encrypted**. Anyone who possesses the token can decode the payload and view its contents. While the signature prevents tampering, it does not provide confidentiality. Therefore, passwords, personal identifiers, payment information, or other sensitive data should never be included in the payload.

---

## Q3. How does the server know a JWT has not been modified?

### Answer

The server recalculates the token's signature using the original header, payload, and signing key. It then compares the newly generated signature with the signature included in the JWT. If they match, the token has not been modified. If they differ, the token has been tampered with and is rejected.

---

## Q4. What are the disadvantages of JWT?

### Answer

While JWT scales well, it has some trade-offs:

- Revoking issued tokens is difficult unless additional infrastructure (such as token blacklists) is used.
- Tokens are larger than simple session IDs because they contain claims.
- Sensitive information must never be placed in the payload.
- If a long-lived JWT is stolen, it remains valid until expiration unless explicit revocation mechanisms exist.

---

## Q5. When would you choose Session-based authentication instead of JWT?

### Answer

I would prefer session-based authentication for traditional server-rendered web applications where the server already maintains state and immediate session revocation is important. For distributed APIs, microservices, mobile applications, and SPAs, JWT is generally preferred because it is stateless and scales more effectively across multiple servers.
