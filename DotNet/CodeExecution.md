# How C# Code Executes Internally (F5 → Machine Code)

This is one of the **most frequently asked interview questions** for **Senior .NET Developers (10+ Years)**.

When you press **F5** or **Run**, a lot happens behind the scenes.

Let's understand the complete lifecycle.

---

# High-Level Flow

```text
          Write C# Code
                 │
                 ▼
        Roslyn C# Compiler
                 │
                 ▼
        IL (Intermediate Language)
                 │
                 ▼
      Assembly (.exe / .dll)
                 │
                 ▼
     CLR Loads the Assembly
                 │
                 ▼
      Class Loader Loads Types
                 │
                 ▼
       Verification & Security
                 │
                 ▼
      JIT Compiler Compiles IL
                 │
                 ▼
        Native Machine Code
                 │
                 ▼
         CPU Executes Code
```

---

# Step 1 - Write C# Code

Example

```csharp
using System;

class Program
{
    static void Main()
    {
        Console.WriteLine("Hello World");
    }
}
```

This is human-readable C# source code.

File

```
Program.cs
```

---

# Step 2 - Roslyn Compiler

When you press

```
F5
```

Visual Studio invokes the **Roslyn C# Compiler (`csc.exe`)**.

Roslyn performs:

- Syntax Analysis
- Semantic Analysis
- Type Checking
- Nullable Analysis
- Error Detection
- Optimization
- IL Generation

It **does not generate machine code**.

Instead it generates

```
Intermediate Language (IL)
```

---

# Step 3 - Intermediate Language (IL)

IL is also called

- MSIL
- CIL
- Intermediate Language

All are essentially the same thing.

Example

C#

```csharp
Console.WriteLine("Hello");
```

Generated IL

```il
IL_0000: ldstr "Hello"

IL_0005: call void [System.Console]System.Console::WriteLine(string)

IL_000A: ret
```

Notice

This is **NOT machine code**.

It is CPU independent.

---

# Why IL?

Suppose Microsoft generated machine code directly.

You'd need

```
Windows x64 Compiler

Linux Compiler

ARM Compiler

Mac Compiler
```

Instead

Microsoft compiles once

↓

IL

↓

JIT generates machine code depending upon OS and CPU.

Same DLL works on

- Windows
- Linux
- Mac

---

# Step 4 - Assembly Creation

Compiler creates

```
MyApp.exe

or

MyLibrary.dll
```

Inside DLL

```text
+---------------------------+

Manifest

Metadata

IL Code

Resources

Version Info

Security Info

+---------------------------+
```

An assembly contains much more than just executable code.

---

# Step 5 - CLR Starts

Now

```
dotnet MyApp.dll
```

or pressing

```
F5
```

starts

```
CLR
(Common Language Runtime)
```

Think of CLR as

> JVM for Java

CLR is the execution engine of .NET.

---

# CLR Responsibilities

CLR is responsible for

- Memory Management
- Garbage Collection
- JIT Compilation
- Exception Handling
- Thread Management
- Security
- Assembly Loading
- Type Safety
- Code Verification
- Interoperability (COM / Native)

Think of CLR as the **Operating System for Managed Code**.

---

# CLR Architecture

```text
                 CLR

+-------------------------------------------+

Class Loader

JIT Compiler

Garbage Collector

Security

Exception Manager

Thread Manager

Memory Manager

Interop

+-------------------------------------------+
```

---

# Step 6 - Assembly Loader

CLR loads

```
MyApp.dll
```

It reads

- Metadata
- Manifest
- Referenced Assemblies

Then loads dependencies

Example

```
System.Console.dll

System.Runtime.dll

System.Private.CoreLib.dll
```

---

# Step 7 - Metadata Reading

Every .NET assembly contains metadata.

Metadata contains

```text
Class Names

Method Names

Properties

Interfaces

References

Generics

Attributes
```

Unlike C++, .NET doesn't need header files because metadata provides complete type information.

---

# Step 8 - Verification

CLR verifies

- Type Safety
- Valid IL
- Stack correctness
- Method signatures

Example

Invalid IL

```il
Add string

to int
```

CLR rejects such code.

---

# Step 9 - JIT Compiler

This is where **IL becomes native machine code**.

```text
IL

↓

JIT Compiler

↓

Machine Code
```

Only methods that are actually called are compiled.

---

# Example

```csharp
static void Main()
{
    Add();
}

static void Add()
{
}

static void Multiply()
{
}
```

Execution

```text
Main()

↓

JIT

↓

Machine Code

↓

Main calls Add()

↓

JIT Add()

↓

Machine Code

Multiply()

Never Called

↓

Never Compiled
```

This is known as **Just-In-Time (JIT)** compilation.

---

# Why "Just In Time"?

Because compilation happens **just before** a method executes.

Not before.

---

# JIT Example

Suppose

```csharp
Add();

Subtract();

Multiply();
```

Initially

```text
IL

↓

Add

Subtract

Multiply
```

Execution

```
Main()

↓

Compile Main

↓

Call Add()

↓

Compile Add()

↓

Call Subtract()

↓

Compile Subtract()

↓

Multiply

Never Used
```

Multiply remains IL.

---

# Native Machine Code

Example

Machine code

```text
MOV

ADD

SUB

JMP

PUSH

POP
```

CPU understands only these instructions.

---

# JIT Cache

Once a method is JIT compiled

It stays in memory.

Second call

```csharp
Add();

Add();

Add();
```

Only first call performs JIT.

Second and third calls execute native code directly.

---

# Memory Flow

```text
Program.cs

↓

Roslyn

↓

IL

↓

DLL

↓

CLR

↓

JIT

↓

Machine Code

↓

CPU
```

---

# Garbage Collector

During execution

Objects are created

```csharp
Person p = new Person();
```

Memory

```text
Stack

p

↓

Heap

Person
```

GC periodically cleans unreachable objects.

---

# Exception Handling

CLR also manages exceptions.

Example

```csharp
try
{
}
catch
{
}
```

CLR

- Creates exception object
- Unwinds stack
- Finds matching catch block
- Executes finally block

---

# Thread Management

```csharp
Task.Run(() =>
{

});
```

CLR

- Creates thread pool threads
- Schedules work
- Reuses threads
- Optimizes execution

---

# End-to-End Flow

```text
Developer

↓

Writes C#

↓

Roslyn Compiler

↓

IL

↓

Assembly (.dll)

↓

CLR Starts

↓

Assembly Loader

↓

Metadata Reader

↓

Verification

↓

JIT Compiler

↓

Machine Code

↓

CPU Executes

↓

GC Cleans Memory

↓

Application Ends
```

---

# What Happens When You Press F5?

```text
Press F5

      │

      ▼

Build Starts

      │

      ▼

Roslyn Compiles C#

      │

      ▼

Produces IL

      │

      ▼

Creates DLL/EXE

      │

      ▼

Visual Studio Launches dotnet

      │

      ▼

CLR Starts

      │

      ▼

Assembly Loaded

      │

      ▼

Metadata Read

      │

      ▼

Verification

      │

      ▼

JIT Compiles Main()

      │

      ▼

Machine Code Generated

      │

      ▼

CPU Executes Main()

      │

      ▼

Each Called Method is JIT Compiled

      │

      ▼

Garbage Collector Cleans Memory

      │

      ▼

Application Exits
```

---

# Key Components Summary

| Component | Responsibility |
|------------|----------------|
| **Roslyn Compiler** | Converts C# to IL |
| **IL (Intermediate Language)** | Platform-independent instructions |
| **Assembly (.dll/.exe)** | Contains IL, metadata, manifest, resources |
| **CLR (Common Language Runtime)** | Executes managed code and provides runtime services |
| **Assembly Loader** | Loads assemblies and dependencies |
| **Metadata** | Describes all types, methods, properties, attributes, and references |
| **Verifier** | Ensures IL is type-safe and valid |
| **JIT Compiler** | Converts IL to native machine code on first use |
| **Machine Code** | CPU-specific instructions executed by the processor |
| **Garbage Collector (GC)** | Reclaims memory of unreachable managed objects |

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. What happens internally when you press F5 in Visual Studio?

### Answer

When you press **F5**, Visual Studio first builds the project using the Roslyn compiler. The compiler converts C# source code into **Intermediate Language (IL)** and packages it into an assembly (`.dll` or `.exe`) containing metadata and a manifest.

The `dotnet` host starts the **CLR**, which loads the assembly, verifies the IL, resolves dependencies, and invokes the **JIT compiler**. The JIT compiles the `Main()` method into native machine code just before execution. As additional methods are called, they are JIT-compiled on demand. During execution, the CLR also provides services such as garbage collection, exception handling, thread management, and security.

---

## Q2. What is the difference between CLR, CTS, CLS, and BCL?

### Answer

| Component | Purpose |
|-----------|---------|
| **CLR (Common Language Runtime)** | Executes managed code and provides runtime services such as GC, JIT, threading, exceptions, and security. |
| **CTS (Common Type System)** | Defines how types are declared and used so that all .NET languages share the same type system. |
| **CLS (Common Language Specification)** | A subset of CTS that defines language interoperability rules. |
| **BCL (Base Class Library)** | Provides reusable APIs such as `System.String`, `System.Collections`, `System.IO`, and `System.Net`. |

---

## Q3. Why doesn't the C# compiler generate machine code directly?

### Answer

The C# compiler generates **IL** instead of machine code to achieve platform independence. The same assembly can run on Windows, Linux, or macOS because the **JIT compiler** converts IL into CPU-specific machine code at runtime. This also enables runtime optimizations based on the target environment.

---

## Q4. What is JIT Compilation?

### Answer

**Just-In-Time (JIT)** compilation converts IL into native machine code **only when a method is called for the first time**. The generated native code is cached in memory for subsequent calls, avoiding repeated compilation and improving performance.

---

## Q5. What types of JIT compilation exist in .NET?

### Answer

1. **Normal JIT (Default)** – Compiles methods on first execution.
2. **Tiered Compilation** – Initially generates quick, minimally optimized code and later recompiles hot methods with higher optimizations.
3. **ReadyToRun (R2R)** – Uses ahead-of-time compiled native code embedded in assemblies to reduce startup time while still allowing JIT when needed.
4. **Native AOT** – Compiles the entire application to native code during publishing, eliminating runtime JIT and improving startup performance.

---

## Q6. What is the difference between IL and Machine Code?

### Answer

| IL (Intermediate Language) | Machine Code |
|----------------------------|--------------|
| Platform-independent | Platform-specific |
| Generated by Roslyn compiler | Generated by JIT or AOT compiler |
| Executed by CLR | Executed directly by CPU |
| Same assembly works across OSes | Different for x64, ARM64, etc. |

---

## Q7. What is metadata in a .NET assembly?

### Answer

Metadata is information embedded in every .NET assembly that describes:

- Types (classes, structs, interfaces)
- Methods and properties
- Fields and events
- Generic parameters
- Custom attributes
- Assembly references
- Version information

The CLR uses metadata for reflection, dependency loading, verification, serialization, and runtime type discovery.

---

## Q8. What additional responsibilities does the CLR have besides running code?

### Answer

The CLR provides many runtime services, including:

- Garbage Collection (GC)
- Exception Handling
- Thread Pool and Thread Management
- Security Verification
- Assembly Loading
- Type Safety Verification
- Memory Management
- Reflection Support
- Interoperability with native code (P/Invoke and COM)
- Debugging and Profiling support

These services allow developers to focus on application logic rather than low-level runtime management.
