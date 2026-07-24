# ASP.NET Core Middleware - Complete Guide (From Beginner to Production)

> **Interview Level:** Senior Software Engineer / Tech Lead / Architect (10+ Years)

---

# Table of Contents

1. Why Middleware Exists
2. Life Before Middleware
3. What is Middleware?
4. Why Pipeline?
5. How Request Travels
6. Building a Middleware Pipeline
7. Middleware Execution Flow
8. Built-in Middleware
9. Custom Middleware
10. Short Circuiting
11. Exception Middleware
12. Authentication Middleware
13. Authorization Middleware
14. Logging Middleware
15. Middleware Ordering
16. Real Production Pipeline
17. Interview Questions

---

# Chapter 1 - Why Was Middleware Introduced?

Before understanding Middleware,

let's understand the problem.

Suppose you are building

```
Instagram API
```

Your application has

```http
GET /posts

POST /posts

POST /login

GET /feed

POST /comment

POST /like
```

Every request comes into your application.

Question

Should every controller write code like this?

```csharp
public IActionResult GetPosts()
{
    LogRequest();

    AuthenticateUser();

    AuthorizeUser();

    HandleExceptions();

    AddHeaders();

    ExecuteBusinessLogic();

    LogResponse();
}
```

Looks okay?

Now imagine

100 APIs.

Every controller repeats

- Logging
- Authentication
- Authorization
- Exception Handling
- Headers
- Response Compression

Thousands of duplicate lines.

This violates

```
DRY

Don't Repeat Yourself
```

---

# Real World Example

Imagine you enter an airport.

Do you directly board the plane?

No.

You go through several checkpoints.

1. Security Check
2. Passport Verification
3. Immigration
4. Boarding Gate
5. Flight

Every passenger goes through the same process.

The airline doesn't write security logic separately for every passenger.

The same pipeline processes everyone.

Middleware works exactly like that.

---

# Chapter 2 - What is Middleware?

Middleware is simply

> **A software component that sits between the incoming HTTP request and your application logic.**

It can

- Read the request.
- Modify the request.
- Stop the request.
- Pass the request to the next middleware.
- Modify the response.
- Log information.

Think of it as a checkpoint.

---

# Without Middleware

Imagine

```
User

↓

Controller

↓

Database
```

Every controller handles

- Logging
- Authentication
- Exception Handling

This creates duplicate code.

---

# With Middleware

Instead

every request passes through

a common pipeline.

```text
Request

↓

Logging

↓

Authentication

↓

Authorization

↓

Controller

↓

Response
```

Each middleware performs one responsibility.

---

# Chapter 3 - Why is it Called a Pipeline?

Imagine water flowing through pipes.

Every pipe performs one operation.

The water flows

from one pipe

to another.

HTTP requests behave similarly.

A request enters the application

and passes through

multiple middleware components.

Each component decides

Should I

- Process it?
- Modify it?
- Reject it?
- Pass it to the next middleware?

---

# Chapter 4 - Understanding Request Flow

Suppose Amit calls

```http
GET

/api/posts
```

The request enters Kestrel (ASP.NET Core's web server).

Now the middleware pipeline begins.

Let's imagine the application has:

- Logging Middleware
- Authentication Middleware
- Authorization Middleware
- Exception Middleware

The request flows through them one by one.

---

## Step 1 - Logging Middleware

Logging Middleware receives the request first.

It records:

```text
Time

URL

HTTP Method

IP Address
```

Example log

```
10:30:15

GET

/api/posts
```

It then says

> "I have finished my work. Let the next middleware continue."

---

## Step 2 - Authentication Middleware

Now Authentication Middleware receives the request.

It checks

```
Authorization Header

Bearer Token
```

Example

```http
Authorization

Bearer eyJhbGc...
```

Question

Is token present?

If no

User remains anonymous.

If yes

Validate JWT.

If valid

Create

```
HttpContext.User
```

Now every remaining middleware knows

who the user is.

---

## Step 3 - Authorization Middleware

Authentication only answers

```
Who are you?
```

Authorization answers

```
Can you access this resource?
```

Example

Endpoint

```http
DELETE /users
```

Requires

```
Admin
```

Role.

If Amit

is not

Admin

Authorization Middleware immediately returns

```
403 Forbidden
```

The request never reaches the controller.

---

## Step 4 - Controller Executes

Only after all middleware succeeds

does the controller execute.

Example

```csharp
public IActionResult GetPosts()
{
    return Ok(posts);
}
```

---

## Step 5 - Response Travels Back

Many beginners think

Middleware only processes requests.

Wrong.

Middleware also processes responses.

Response travels

back through

the same middleware

in reverse order.

Example

```
Controller

↓

Authorization

↓

Authentication

↓

Logging

↓

Client
```

Logging Middleware now records

```
Status Code

200

Execution Time

150 ms
```

---

# Chapter 5 - Middleware is Like an Onion

This is the easiest way to understand it.

Imagine an onion.

```
Logging

Authentication

Authorization

Controller
```

Request enters

outside

and moves inward.

Response exits

inside

and moves outward.

Each middleware wraps the next one.

---

# Chapter 6 - Writing a Custom Middleware

Suppose you want to log every request.

```csharp
public class LoggingMiddleware
{
    private readonly RequestDelegate _next;

    public LoggingMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task Invoke(HttpContext context)
    {
        Console.WriteLine($"Incoming: {context.Request.Path}");

        await _next(context);

        Console.WriteLine($"Outgoing: {context.Response.StatusCode}");
    }
}
```

Let's understand every line.

---

## RequestDelegate

Question

What is

```
RequestDelegate
```

It represents

the next middleware

in the pipeline.

When you call

```csharp
await _next(context);
```

you're saying

```
Continue processing.
```

---

## Invoke Method

Every middleware must have

```
Invoke

or

InvokeAsync
```

ASP.NET Core calls it automatically.

---

# Chapter 7 - Registering Middleware

```csharp
app.UseMiddleware<LoggingMiddleware>();
```

This inserts

Logging Middleware

into the pipeline.

Order matters.

We'll discuss why shortly.

---

# Chapter 8 - Short Circuiting

Question

Must every middleware call

```csharp
_next()
```

No.

Suppose

Authentication fails.

Middleware can stop immediately.

Example

```csharp
public async Task Invoke(HttpContext context)
{
    if(!context.Request.Headers.ContainsKey("Authorization"))
    {
        context.Response.StatusCode = 401;

        await context.Response.WriteAsync("Unauthorized");

        return;
    }

    await _next(context);
}
```

Notice

```
return
```

No controller executes.

Pipeline stops.

This is called

```
Short Circuiting
```

---

# Chapter 9 - Built-in Middleware

ASP.NET Core provides many middleware components.

Examples

```csharp
app.UseExceptionHandler();

app.UseHttpsRedirection();

app.UseRouting();

app.UseAuthentication();

app.UseAuthorization();

app.UseStaticFiles();

app.UseCors();

app.UseResponseCompression();
```

Each solves one problem.

---

# Chapter 10 - Exception Middleware

Suppose

Controller throws

```csharp
throw new Exception();
```

Without middleware

Client receives

```
500

No useful response.
```

Exception Middleware catches

every unhandled exception.

Returns

```json
{
    "message":"Something went wrong."
}
```

Centralized error handling.

---

# Chapter 11 - Middleware Order

One of the most common interview questions.

Suppose

You write

```csharp
app.UseAuthorization();

app.UseAuthentication();
```

Question

Will it work?

No.

Authorization needs

an authenticated user.

Authentication must execute first.

Correct

```csharp
app.UseAuthentication();

app.UseAuthorization();
```

---

# Another Example

Wrong

```csharp
UseEndpoints();

UseRouting();
```

Routing must happen first.

Correct

```csharp
UseRouting();

UseEndpoints();
```

Middleware order defines

application behavior.

---

# Chapter 12 - Real Production Pipeline

A typical ASP.NET Core production pipeline looks like this:

```csharp
app.UseExceptionHandler();

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.UseCors();

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();
```

Let's understand why this order is important.

### Exception Handler

Placed first so it can catch exceptions from all downstream middleware.

### HTTPS Redirection

Ensures insecure HTTP requests are redirected before doing any additional work.

### Static Files

Serves CSS, JavaScript, and images directly without reaching controllers.

### Routing

Determines which endpoint matches the incoming request.

### CORS

Applies cross-origin policies before authentication and controller execution.

### Authentication

Builds the user identity.

### Authorization

Checks whether the authenticated user is allowed to access the endpoint.

### Controllers

Business logic executes only after all previous checks succeed.

---

# Chapter 13 - Complete Request Lifecycle

Imagine Amit calls:

```http
GET /api/posts
Authorization: Bearer <JWT>
```

The request is processed in this order:

1. Kestrel receives the HTTP request.
2. Exception Middleware starts monitoring for errors.
3. HTTPS Middleware verifies the request uses HTTPS.
4. Routing Middleware finds the matching endpoint.
5. CORS Middleware validates the origin.
6. Authentication Middleware validates the JWT and creates `HttpContext.User`.
7. Authorization Middleware checks endpoint permissions.
8. Controller executes business logic.
9. Response travels back through the middleware in reverse order.
10. Logging and other middleware can inspect or modify the outgoing response.

---

# Common Middleware

| Middleware | Responsibility |
|------------|----------------|
| Exception Handler | Global exception handling |
| HTTPS Redirection | Redirect HTTP → HTTPS |
| Static Files | Serve CSS, JS, Images |
| Routing | Match URL to endpoint |
| CORS | Cross-origin request handling |
| Authentication | Validate identity |
| Authorization | Validate permissions |
| Response Compression | Compress responses |
| Response Caching | Cache responses |
| Custom Middleware | Organization-specific logic |

---

# When Should You Create Custom Middleware?

Use custom middleware when the functionality should apply to **every** or **many** requests.

Examples:

- Request/response logging.
- Correlation IDs.
- Custom headers.
- Multi-tenancy resolution.
- API version validation.
- Request timing.
- Audit logging.
- Global request validation.

Avoid middleware for business logic specific to one controller or endpoint.

---

# Middleware vs Filters

| Middleware | Filters |
|------------|----------|
| Runs for the entire application | Runs only for MVC/API actions |
| Executes before endpoint selection (depending on order) | Executes after routing |
| Can short-circuit the entire pipeline | Can short-circuit controller execution |
| Used for infrastructure concerns | Used for MVC-specific concerns |

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. Why does ASP.NET Core use a middleware pipeline?

### Answer

The middleware pipeline allows cross-cutting concerns such as authentication, logging, exception handling, HTTPS redirection, and CORS to be implemented once and reused across all requests. This keeps controllers focused on business logic, improves maintainability, and follows the Single Responsibility Principle.

---

## Q2. Why is middleware executed in both directions?

### Answer

Middleware forms a nested pipeline. During the inbound phase, each middleware processes the request before calling the next component. After the endpoint generates a response, control returns through the same middleware stack in reverse order. This allows middleware to perform post-processing such as response logging, header modification, or compression.

---

## Q3. What happens if a middleware does not call `await _next(context)`?

### Answer

The pipeline stops at that middleware. No downstream middleware or controller executes. This behavior is called **short-circuiting** and is commonly used for authentication failures, maintenance mode, static file serving, or request validation.

---

## Q4. Why must `UseAuthentication()` come before `UseAuthorization()`?

### Answer

`UseAuthentication()` validates the user's credentials and populates `HttpContext.User`. `UseAuthorization()` relies on this identity to evaluate policies and roles. If authorization executes first, no authenticated user exists, causing authorization to fail regardless of the supplied credentials.

---

## Q5. How would you explain middleware to a junior developer?

### Answer

I describe middleware as a series of security and processing checkpoints that every HTTP request passes through before reaching the application's business logic. Each checkpoint has one responsibility—such as logging, authentication, or exception handling—and can inspect, modify, reject, or forward the request. After the controller finishes, the response passes back through the same checkpoints, allowing additional processing before it is returned to the client.
