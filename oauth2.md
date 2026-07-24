# How OAuth 2.0 Actually Works (Step-by-Step Internal Working)

> **Interview Level:** Senior Software Engineer / Tech Lead / Architect (10+ Years)

This guide explains **exactly** what happens internally when OAuth2 works.

Most tutorials explain OAuth like this:

```text
User

↓

Authorization Server

↓

Access Token

↓

API
```

This is **too abstract**.

Let's understand every HTTP request, every component, and why each step exists.

---

# Chapter 1 - The Problem OAuth Solves

Let's build a real scenario.

Suppose you created an application called

```
PhotoPrint.com
```

Your application prints users' Google Photos.

Now Amit visits your website.

He clicks

```
Import Google Photos
```

Question:

How can your application read Amit's Google Photos?

---

## Solution 1 (Wrong)

Ask Amit for

```
Google Email

Google Password
```

Your application logs into Google.

Would you trust this application?

Absolutely not.

Problems:

- Your application knows Amit's password.
- It can access Gmail.
- It can delete Google Drive files.
- It can change security settings.
- Amit cannot revoke access without changing his password.

This is exactly why OAuth was invented.

---

# OAuth's Main Idea

Instead of giving your password,

Google gives the application a **temporary permission slip**.

Think of it like this:

Imagine you own a house.

A plumber needs access to fix your sink.

Would you give him:

```
Your House Key?
```

No.

Instead you give him

```
A Temporary Access Card

Valid

Today

9AM - 11AM

Kitchen Only
```

That is exactly what an OAuth Access Token is.

---

# The Four People Involved

Let's first understand the actors.

Without understanding them,

OAuth becomes confusing.

---

## 1. Resource Owner

Who owns the data?

```
Amit
```

He owns

- Google Photos
- Gmail
- Drive

---

## 2. Client

Who wants access?

```
PhotoPrint.com
```

---

## 3. Authorization Server

Who decides whether permission should be granted?

```
accounts.google.com
```

Responsibilities:

- Login
- Password verification
- User consent
- Generate tokens

---

## 4. Resource Server

Where is the actual data?

```
photos.googleapis.com
```

Notice

Authorization Server

and

Resource Server

are different.

---

# Complete Scenario

We will now follow

every request

step by step.

---

# Step 1 - User Clicks Login

Amit opens

```
PhotoPrint.com
```

He clicks

```
Continue with Google
```

At this moment

our application

does NOT know

who Amit is.

---

# Step 2 - Redirect to Google

Our application redirects Amit's browser.

Example

```http
GET

https://accounts.google.com/o/oauth2/v2/auth

?client_id=abc123

&redirect_uri=https://photoprint.com/callback

&scope=photos.read

&response_type=code

&state=xyz789
```

Let's understand every parameter.

---

## client_id

Every application registered with Google gets a unique ID.

Example

```
PhotoPrint

↓

Google

↓

Client ID

abc123
```

Google immediately knows

which application

is requesting access.

---

## redirect_uri

Suppose login succeeds.

Where should Google send Amit back?

Example

```
https://photoprint.com/callback
```

Google remembers this.

---

## scope

Question

What exactly does our application want?

Options

```
Read Photos

Read Email

Read Contacts

Read Calendar
```

Suppose we request

```
photos.read
```

Google now knows

Our application only wants

Photos.

---

## response_type

We ask Google

```
Please return

Authorization Code
```

Not Access Token.

This is important.

---

## state

Random value.

Purpose

Prevent

CSRF attacks.

Google returns

exactly the same value later.

---

# Step 3 - Browser Goes To Google

Notice something important.

The browser leaves

PhotoPrint.com

and opens

Google.

At this point

Our application disappears.

Only

Google

and

Amit

are communicating.

---

# Step 4 - Login Screen

Google asks

```
Email

Password
```

Question

Does

PhotoPrint.com

see

Amit's password?

NO.

Only Google sees it.

This is the biggest advantage of OAuth.

---

# Step 5 - Google Authenticates User

Google checks

```
Email exists?

Password correct?

Account locked?

MFA enabled?
```

If everything succeeds

Google knows

```
This is Amit.
```

Still

PhotoPrint.com

knows nothing.

---

# Step 6 - Consent Screen

Now Google asks

```
PhotoPrint wants permission to

✔ Read Photos

Allow?

Deny?
```

Notice

Google shows

only

the requested permissions.

Not everything.

This is called

```
Scope
```

---

# Step 7 - User Clicks Allow

Now Google creates

an

Authorization Code.

Example

```
AZBYCX12345
```

Think of this code as

a claim ticket.

Like

when you submit luggage

at an airport.

The ticket

is useless

unless exchanged.

---

# Why Not Return Access Token?

Excellent interview question.

Suppose Google returned

Access Token

directly.

Browser receives it.

JavaScript can read it.

Extensions can steal it.

Browser history may expose it.

Security risk.

Instead

Google returns

only

Authorization Code.

---

# Step 8 - Redirect Back

Google redirects browser

to

```text
https://photoprint.com/callback

?code=AZBYCX12345

&state=xyz789
```

Now

PhotoPrint

receives

only

Authorization Code.

Still

No Access Token.

---

# Step 9 - Backend Talks To Google

This is the most important step.

Browser is no longer involved.

PhotoPrint Backend

makes

Server-to-Server request.

```http
POST

https://oauth2.googleapis.com/token
```

Body

```text
client_id

client_secret

authorization_code

redirect_uri

grant_type=authorization_code
```

Question

Why backend?

Because

Client Secret

must never be exposed

to browsers.

---

# Step 10 - Google Validates Everything

Google checks

Is Client ID valid?

↓

Does Client Secret match?

↓

Is Authorization Code valid?

↓

Has it expired?

↓

Was Redirect URI correct?

↓

Has code already been used?

If every answer

is Yes

Google issues tokens.

---

# Step 11 - Google Returns Tokens

```json
{
    "access_token":"eyJhbGc...",

    "refresh_token":"xyz987",

    "expires_in":3600,

    "scope":"photos.read"
}
```

Let's understand these.

---

# Access Token

Think of

Movie Ticket.

The ticket lets you

enter the cinema.

It doesn't prove

who you are.

It simply grants permission.

Characteristics

```
Short Life

Usually

1 Hour
```

---

# Refresh Token

Imagine

your movie ticket expires.

Instead of buying

another ticket

you show

a Membership Card.

Membership Card

gives

new tickets.

Refresh Token

works exactly like this.

---

# Step 12 - Access Google Photos

Now

PhotoPrint Backend

calls

```http
GET

/photos
```

Header

```http
Authorization

Bearer eyJhbGc...
```

Google checks

```
Signature

↓

Expiry

↓

Scope

↓

Audience
```

If valid

Photos returned.

---

# Internal Validation

Suppose

Access Token

contains

```json
{
    "sub":"12345",

    "scope":"photos.read",

    "exp":1730000000
}
```

Google checks

```
Has it expired?

↓

Does it allow photos.read?

↓

Was token signed by Google?

↓

Is audience correct?
```

Only then

returns photos.

---

# What Happens After One Hour?

Access Token expires.

Question

Should Amit login again?

No.

Backend sends

Refresh Token.

```http
POST

/token

grant_type=refresh_token
```

Google returns

```
New Access Token
```

User doesn't even notice.

---

# Why Access Token Is Short-Lived

Imagine hacker steals it.

Worst case

```
Valid

1 Hour
```

Damage limited.

---

# Why Refresh Token Is Never Sent To APIs

Suppose hacker intercepts

Refresh Token.

They can generate

new Access Tokens forever.

Therefore

Refresh Token

must remain

securely stored

on backend

or secure mobile storage.

---

# Complete OAuth Flow (End-to-End)

Let's put everything together.

### 1. User starts login

Amit clicks:

```
Continue with Google
```

### 2. Application redirects browser

Browser goes to Google's Authorization Server with:

- Client ID
- Redirect URI
- Scope
- State

### 3. Google authenticates user

Amit enters:

- Email
- Password
- MFA (if enabled)

PhotoPrint never sees these credentials.

### 4. Google asks for consent

Google displays:

```
PhotoPrint wants permission to:

✔ Read Google Photos
```

Amit clicks **Allow**.

### 5. Google issues Authorization Code

Google redirects browser back to:

```
https://photoprint.com/callback?code=ABC123
```

### 6. Backend exchanges the code

PhotoPrint backend sends:

- Client ID
- Client Secret
- Authorization Code

to Google's Token Endpoint.

### 7. Google issues tokens

Google returns:

- Access Token
- Refresh Token

### 8. Backend calls Google Photos

Each API request includes:

```http
Authorization: Bearer <AccessToken>
```

### 9. Resource Server validates token

Google Photos validates:

- Signature
- Expiry
- Audience
- Scope

If valid, it returns Amit's photos.

### 10. Access Token expires

Backend silently exchanges the Refresh Token for a new Access Token.

Amit continues using the application without logging in again.

---

# Visual Summary

```text
Amit opens PhotoPrint.com

↓

Clicks "Continue with Google"

↓

Browser is redirected to Google

↓

Google authenticates Amit

↓

Google asks for consent

↓

Google returns Authorization Code

↓

PhotoPrint backend exchanges code for tokens

↓

Google returns Access Token + Refresh Token

↓

PhotoPrint backend calls Google Photos API

↓

Google validates Access Token

↓

Google returns photos

↓

When Access Token expires

↓

Backend uses Refresh Token

↓

Google returns a new Access Token

↓

Application continues without user interaction
```

---

# Why OAuth2 Is Secure

| Security Feature | Purpose |
|------------------|---------|
| User enters password only on Google | Third-party apps never see credentials |
| Authorization Code | Temporary code, not directly usable for APIs |
| Client Secret | Proves the backend's identity |
| Access Token | Short-lived permission |
| Refresh Token | Securely obtains new Access Tokens |
| Scopes | Least-privilege access |
| State Parameter | Prevents CSRF attacks |
| HTTPS | Protects all communication |

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. Why doesn't Google return the Access Token directly to the browser in the Authorization Code Flow?

### Answer

Returning the Access Token directly to the browser increases the risk of token theft through browser extensions, JavaScript vulnerabilities, logs, or history. Instead, Google returns a short-lived Authorization Code, which is exchanged securely by the backend using the Client Secret. This ensures the Access Token is issued only to a trusted backend application.

---

## Q2. Why do we need an Authorization Code at all? Why not exchange credentials directly?

### Answer

The Authorization Code separates user authentication from token issuance. The user authenticates only with the Authorization Server, while the client backend securely exchanges the Authorization Code for tokens. This prevents third-party applications from handling user credentials and allows the Authorization Server to enforce validation, consent, and security checks before issuing tokens.

---

## Q3. Why does the Resource Server trust the Access Token?

### Answer

The Access Token is digitally signed by the Authorization Server. When the Resource Server receives the token, it verifies:

- The signature (ensuring it was issued by a trusted authority).
- The expiration time.
- The intended audience.
- The requested scopes.

Only after successful validation does it allow access to protected resources.

---

## Q4. Why can't an Access Token be reused forever?

### Answer

If an Access Token is stolen, an attacker could use it to access protected resources. Keeping Access Tokens short-lived limits the impact of token compromise. Long-term access is handled through Refresh Tokens, which are stored more securely and exchanged only with the Authorization Server, not with Resource Servers.

---

## Q5. Where should Access Tokens and Refresh Tokens be stored?

### Answer

For server-side web applications:

- **Access Token:** Typically stored server-side (or in a secure session).
- **Refresh Token:** Stored securely on the server, encrypted if persisted.

For mobile applications:

- Store Refresh Tokens in secure platform storage (e.g., iOS Keychain, Android Keystore).

Avoid storing sensitive tokens in insecure browser storage such as localStorage when dealing with confidential applications.
