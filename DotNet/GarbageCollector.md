# Garbage Collector (GC) in C# / .NET

## What is Garbage Collector?

The **Garbage Collector (GC)** is an automatic memory management component of the **Common Language Runtime (CLR)**.

Its job is to:

- Allocate memory for new objects.
- Track object references.
- Identify objects that are no longer used.
- Free the memory occupied by those objects.
- Compact the heap to reduce memory fragmentation.

> **Interview Definition (One-Liner):**
>
> "Garbage Collector is a CLR component that automatically manages memory by reclaiming memory from unreachable objects, eliminating the need for manual memory management."

---

# Why Do We Need Garbage Collector?

Without GC (like in C/C++):

- Developers manually allocate memory.
- Developers manually free memory.
- Forgetting to free memory causes **Memory Leak**.
- Freeing memory twice causes **Crash**.
- Accessing freed memory causes **Dangling Pointer**.

With GC:

- Automatic memory management
- Prevents most memory leaks
- Prevents dangling pointers
- Improves application stability

---

# Memory Layout

```text
                    CLR Memory

+-------------------------------+
|            Stack              |
|-------------------------------|
| Person p ----------------+    |
| int age = 25             |    |
+-------------------------- |----+
                            |
                            |
                            V
+--------------------------------------------+
|             Managed Heap                   |
|--------------------------------------------|
| Person Object                              |
| Name = "Amit"                              |
| Age = 25                                   |
+--------------------------------------------+
```

### Stack

Contains

- Local variables
- Method calls
- References

### Heap

Contains

- Objects
- Arrays
- Strings
- Collections

GC cleans the Heap only.

---

# Example 1 – Object Creation

```csharp
class Person
{
    public string Name { get; set; }
}

class Program
{
    static void Main()
    {
        Person p = new Person();
        p.Name = "Amit";
    }
}
```

Memory

```text
Stack

p ------------+

              |

              V

Heap

+-------------------+
| Person            |
| Name = Amit       |
+-------------------+
```

Object is alive because **p** references it.

---

# Example 2 – Object Becomes Unreachable

```csharp
Person p = new Person();

p = null;
```

Memory

```text
Stack

p = null


Heap

+----------------+
| Person Object  |
+----------------+
```

No references exist.

The object becomes **eligible for Garbage Collection**.

> Eligible does **NOT** mean it is deleted immediately.

---

# Example 3 – Multiple References

```csharp
Person p1 = new Person();

Person p2 = p1;

p1 = null;
```

Memory

```text
Stack

p1 = null

p2 ------------+

               |

               V

Heap

Person Object
```

GC **cannot** collect it because `p2` still references it.

---

# Example 4 – Eligible for Collection

```csharp
Person p1 = new Person();

Person p2 = p1;

p1 = null;
p2 = null;
```

Memory

```text
Stack

No References


Heap

Person Object
```

Object becomes eligible for collection.

---

# When Does GC Run?

GC is **non-deterministic**.

CLR decides when to execute it based on:

- Available memory
- Allocation rate
- Heap size
- Memory pressure
- Generation thresholds

Example

```csharp
for(int i = 0; i < 1000000; i++)
{
    new Person();
}
```

Large allocations create memory pressure, causing CLR to trigger GC.

---

# Generational Garbage Collection

.NET divides objects into three generations.

```text
        New Object

             |

          Generation 0

             |

      Survives Collection

             |

          Generation 1

             |

      Survives Collection

             |

          Generation 2
```

Reason:

> Most objects die young.

Scanning only Gen0 most of the time is much faster than scanning the entire heap.

---

# Generation 0 (Gen0)

All newly created objects go here.

Example

```csharp
Person p = new Person();
```

Examples

- DTO
- Local List
- Request Object
- Temporary String

Collected very frequently.

---

# Generation 1 (Gen1)

Objects surviving Gen0 move here.

```text
Gen0

↓

Gen1
```

Acts as a buffer between short-lived and long-lived objects.

---

# Generation 2 (Gen2)

Objects surviving Gen1 move here.

Examples

- Singleton
- Cache
- Static Dictionary
- Configuration

Collected less frequently.

---

# Large Object Heap (LOH)

Objects larger than **85 KB** go directly into the LOH.

Example

```csharp
byte[] buffer = new byte[100000];
```

Memory

```text
Large Object Heap

+----------------------+
| byte[100000]         |
+----------------------+
```

Examples

- Images
- PDF
- Video Buffer
- Large JSON
- Large Arrays

LOH collection is expensive.

---

# Reachable vs Unreachable Objects

## Reachable

```csharp
Person p = new Person();
```

```text
Stack

p ------------>

Heap

Person Object
```

GC cannot collect.

---

## Unreachable

```csharp
p = null;
```

```text
Heap

Person Object

(No references)
```

GC can reclaim memory.

---

# Mark and Sweep Algorithm

GC internally follows the **Mark and Sweep** approach.

## Step 1 - Mark

GC starts from **Root Objects**:

- Stack
- Static variables
- CPU Registers
- GC Handles

Marks every reachable object.

Example

```text
Root

 |

Person

 |

Address

 |

City
```

These objects are marked as **Alive**.

---

## Step 2 - Sweep

Objects not marked are removed.

```text
Heap

Object A ✔

Object B ✔

Object C ✘

Object D ✘
```

Objects C and D are reclaimed.

---

## Step 3 - Compact

GC moves live objects together.

Before

```text
A

Empty

B

Empty

C
```

After

```text
A

B

C

Free Space
```

This reduces fragmentation.

---

# Finalizer

```csharp
class Person
{
    ~Person()
    {
        Console.WriteLine("Finalizer");
    }
}
```

Runs before memory is reclaimed.

Important

- Non-deterministic.
- Runs on Finalizer Thread.
- Avoid unless required.

---

# IDisposable

GC only manages **managed memory**.

It cannot release

- Database Connections
- Socket
- File Handle
- COM Objects
- Native Memory

Example

```csharp
using(FileStream fs = new FileStream("Demo.txt", FileMode.Open))
{

}
```

Dispose executes immediately.

GC executes later.

---

# Manual Collection

```csharp
GC.Collect();
```

Possible but discouraged.

Reasons

- Stops all managed threads.
- Expensive.
- CLR already knows the optimal collection time.

---

# Useful APIs

```csharp
GC.Collect();

GC.WaitForPendingFinalizers();

GC.SuppressFinalize(this);

GC.GetTotalMemory(false);
```

Example

```csharp
Console.WriteLine(GC.GetTotalMemory(false));
```

Displays managed memory usage.

---

# Complete Example

```csharp
using System;

class Person
{
    public string Name;

    ~Person()
    {
        Console.WriteLine("Finalizer Executed");
    }
}

class Program
{
    static void Main()
    {
        Person p = new Person();

        p.Name = "Amit";

        p = null;

        GC.Collect();

        GC.WaitForPendingFinalizers();

        Console.WriteLine("Program End");
    }
}
```

Possible Output

```text
Finalizer Executed

Program End
```

---

# Complete GC Lifecycle

```text
Object Created

      │

      ▼

Allocated on Heap

      │

      ▼

Referenced by Variable

      │

      ▼

Reference Lost

      │

      ▼

Object Becomes Unreachable

      │

      ▼

GC Marks Reachable Objects

      │

      ▼

GC Sweeps Unreachable Objects

      │

      ▼

Heap Compaction

      │

      ▼

Memory Available Again
```

---

# Advantages

- Automatic memory management
- Eliminates most memory leaks
- Prevents dangling pointers
- Heap compaction
- Optimized performance
- Simplifies development

---

# Disadvantages

- GC pauses (Stop-the-World)
- Non-deterministic execution
- Cannot clean unmanaged resources
- Frequent allocations can impact performance
- LOH collections are expensive

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. Explain the .NET Garbage Collector.

### Answer

The Garbage Collector (GC) is an automatic memory manager provided by the CLR. It allocates memory for managed objects on the managed heap, tracks object references, identifies unreachable objects using a mark-and-sweep algorithm, reclaims their memory, and compacts the heap to reduce fragmentation. It uses a **generational model (Gen0, Gen1, Gen2)** to optimize performance because most objects are short-lived.

---

## Q2. Why does .NET use Generational GC?

### Answer

The generational approach is based on the observation that **most objects die young**.

- **Gen0** contains newly created objects and is collected frequently.
- Objects that survive are promoted to **Gen1**.
- Long-lived objects move to **Gen2**, which is collected less often.

This minimizes the amount of memory scanned during most collections, reducing pause times and improving throughput.

---

## Q3. What are GC Roots?

### Answer

GC starts its traversal from **GC Roots**, which are guaranteed entry points into the object graph.

Examples include:

- Local variables on the stack
- Static fields
- CPU registers
- GC handles
- Active thread references

Any object reachable from these roots is considered alive and is not collected.

---

## Q4. What is the difference between Managed and Unmanaged Memory?

### Answer

| Managed Memory | Unmanaged Memory |
|---------------|------------------|
| Managed by CLR | Managed by OS/Native Code |
| Automatically cleaned by GC | Must be released manually |
| Objects, Strings, Arrays | File Handles, Sockets, COM Objects, Native Buffers |

---

## Q5. What is the Large Object Heap (LOH)?

### Answer

Objects larger than **85 KB** are allocated directly on the **Large Object Heap**.

Examples:

- Large byte arrays
- Images
- PDFs
- Large JSON payloads

LOH collections are more expensive because moving large objects is costly. Excessive LOH allocations can lead to performance issues and fragmentation.

---

## Q6. Why shouldn't we call `GC.Collect()` frequently?

### Answer

`GC.Collect()` forces an immediate garbage collection, causing application pauses (Stop-the-World), increased CPU usage, and potential performance degradation. The CLR uses optimized heuristics to determine the best time to collect memory, so manual collection is rarely beneficial and should be reserved for specific diagnostic or benchmarking scenarios.

---

## Q7. What is the difference between `Dispose()` and Garbage Collection?

### Answer

| Garbage Collection | Dispose() |
|--------------------|-----------|
| Frees managed memory | Frees unmanaged resources |
| Automatic | Explicit |
| Non-deterministic | Deterministic |
| Controlled by CLR | Implemented via `IDisposable` |

**Best Practice:** Use `using` or `await using` to ensure unmanaged resources are released immediately, while allowing the GC to reclaim managed memory later.

---

## Q8. What are common causes of memory leaks in .NET?

### Answer

Although GC handles memory automatically, leaks still occur when objects remain reachable unintentionally.

Common causes include:

- Static collections retaining objects.
- Event handlers not unsubscribed.
- Singleton services holding references.
- Long-lived caches without eviction.
- Timers or background tasks preventing object cleanup.

Since these objects are still reachable, the GC cannot reclaim them.
