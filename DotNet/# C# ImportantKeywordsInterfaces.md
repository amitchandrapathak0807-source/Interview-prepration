# C# Important Keywords & Interfaces (Interview Guide)

This guide covers the most frequently asked C# interview topics for **10+ years experience**.

- const
- readonly
- static
- var
- dynamic
- object
- IEnumerable
- IQueryable
- ICollection
- IList
- List
- Array
- Dictionary
- HashSet
- Span<T>
- Memory<T>
- ref
- out
- in
- params
- yield
- async/await

---

# 1. const

## Definition

`const` is a compile-time constant.

- Value must be known at compile time.
- Implicitly static.
- Cannot be changed.

```csharp
public class Constants
{
    public const double PI = 3.14159;
}
```

Usage

```csharp
Console.WriteLine(Constants.PI);
```

Output

```
3.14159
```

---

## Invalid Example

```csharp
const DateTime Today = DateTime.Now;
```

Compilation Error

Because `DateTime.Now` is evaluated at runtime.

---

## Memory

```text
Compile Time

PI = 3.14159

↓

Compiler replaces every occurrence

No runtime lookup
```

---

# 2. readonly

## Definition

A `readonly` field can only be assigned:

- During declaration
- Inside constructor

```csharp
class Employee
{
    public readonly int Id;

    public Employee(int id)
    {
        Id = id;
    }
}
```

Usage

```csharp
Employee e = new Employee(100);
```

---

## Invalid

```csharp
e.Id = 200;
```

Compilation Error

---

## Memory

```text
Heap

Employee

Id = 100
```

Each object can have a different readonly value.

---

# const vs readonly

| const | readonly |
|---------|----------|
| Compile-time | Runtime |
| Implicitly static | Instance or static |
| Cannot change ever | Can change only in constructor |
| Stored in metadata | Stored in object memory |

Example

```csharp
public const int MaxAge = 60;

public readonly DateTime CreatedDate;
```

---

# 3. static

## Definition

`static` means the member belongs to the **type**, not an instance.

```csharp
class MathUtility
{
    public static int Add(int a, int b)
    {
        return a + b;
    }
}
```

Usage

```csharp
MathUtility.Add(10,20);
```

No object required.

---

## Static Variable

```csharp
class Counter
{
    public static int Count;
}
```

```csharp
Counter.Count++;

Counter.Count++;
```

Memory

```text
Application

Counter.Count

↓

Shared by all objects
```

---

# static Constructor

```csharp
class Database
{
    static Database()
    {
        Console.WriteLine("Initialized");
    }
}
```

Runs only once.

---

# 4. var

Compiler determines the type.

```csharp
var age = 20;
```

Compiler converts to

```csharp
int age = 20;
```

Not dynamic.

---

# 5. dynamic

Resolved at runtime.

```csharp
dynamic obj = "Hello";

Console.WriteLine(obj.Length);

obj = 10;

obj = DateTime.Now;
```

No compile-time checking.

---

# var vs dynamic

| var | dynamic |
|------|----------|
| Compile-time | Runtime |
| Type safe | Not type safe |
| Fast | Slower |
| IntelliSense | Limited runtime safety |

---

# 6. object

Base class of all .NET types.

```csharp
object value = 10;

value = "Hello";

value = DateTime.Now;
```

Requires boxing/unboxing for value types.

---

# Boxing

```csharp
int x = 10;

object o = x;
```

Memory

```text
Stack

x = 10

↓

Heap

Boxed Int32
```

---

# Unboxing

```csharp
int y = (int)o;
```

---

# 7. IEnumerable

## Definition

Provides forward-only iteration over a collection.

Namespace

```csharp
System.Collections.Generic
```

Example

```csharp
IEnumerable<int> numbers = new List<int>()
{
    1,2,3,4
};

foreach(var item in numbers)
{
    Console.WriteLine(item);
}
```

Output

```
1

2

3

4
```

---

## Characteristics

- Read-only enumeration
- Deferred execution (LINQ)
- No Add()
- No Remove()
- No Index access

---

# IEnumerable Flow

```text
Collection

↓

IEnumerator

↓

MoveNext()

↓

Current

↓

MoveNext()

↓

End
```

---

# 8. IQueryable

Namespace

```csharp
System.Linq
```

Mainly used by

- Entity Framework
- LINQ to SQL

Example

```csharp
IQueryable<Employee> employees =
context.Employees;

var result =
employees.Where(x => x.Age > 30);
```

SQL Generated

```sql
SELECT *

FROM Employees

WHERE Age > 30
```

---

# IQueryable Flow

```text
LINQ

↓

Expression Tree

↓

Entity Framework

↓

SQL

↓

Database

↓

Result
```

---

# IEnumerable vs IQueryable

Suppose table has

```
10,00,000 rows
```

Using IEnumerable

```csharp
var employees =
context.Employees.ToList();

var result =
employees.Where(x=>x.Age>30);
```

SQL

```sql
SELECT *
FROM Employees
```

Entire table comes into memory.

Filtering happens in C#.

---

Using IQueryable

```csharp
var result =
context.Employees
.Where(x=>x.Age>30);
```

SQL

```sql
SELECT *

FROM Employees

WHERE Age > 30
```

Filtering happens in SQL Server.

Huge performance improvement.

---

# Comparison

| IEnumerable | IQueryable |
|--------------|------------|
| In-memory | Database |
| LINQ to Objects | LINQ to Entities |
| Uses delegates | Uses expression trees |
| Filtering after data retrieval | Filtering in SQL |
| Slower for large data | Faster for databases |

---

# 9. ICollection

Supports

- Add
- Remove
- Count

```csharp
ICollection<int> list =
new List<int>();

list.Add(10);
```

---

# 10. IList

Supports

- Add
- Remove
- Index

```csharp
IList<int> list =
new List<int>();

list[0] = 100;
```

---

# ICollection vs IList

| ICollection | IList |
|--------------|--------|
| Add | Add |
| Remove | Remove |
| Count | Count |
| No Index | Index Supported |

---

# 11. Dictionary

Stores

Key → Value

```csharp
Dictionary<int,string> students =
new();

students.Add(1,"Amit");

students.Add(2,"Rahul");
```

Lookup

```csharp
students[2];
```

Average Complexity

```
O(1)
```

---

# 12. HashSet

Stores unique values.

```csharp
HashSet<int> numbers =
new();

numbers.Add(10);

numbers.Add(10);
```

Output

```
10
```

Duplicates ignored.

---

# Dictionary vs HashSet

| Dictionary | HashSet |
|-------------|----------|
| Key Value | Value only |
| Fast lookup | Fast uniqueness |
| Duplicate Keys No | Duplicate Values No |

---

# 13. Span<T>

High-performance type for working with contiguous memory **without additional allocations**.

```csharp
Span<int> numbers = stackalloc int[3];

numbers[0] = 10;
numbers[1] = 20;
numbers[2] = 30;
```

Use Cases

- Parsing
- High-performance APIs
- Avoiding allocations

---

# 14. Memory<T>

Similar to `Span<T>` but can live on the heap and be used with async methods.

```csharp
Memory<int> memory = new int[5];

Span<int> span = memory.Span;
```

---

# Span vs Memory

| Span | Memory |
|------|--------|
| Stack only | Heap |
| Cannot use with async | Async compatible |
| Faster | Flexible |

---

# 15. ref

Pass by reference.

```csharp
void Increment(ref int x)
{
    x++;
}

int number = 10;

Increment(ref number);

Console.WriteLine(number);
```

Output

```
11
```

---

# 16. out

Used for returning multiple values.

```csharp
bool TryDivide(int a,int b,out int result)
{
    if(b==0)
    {
        result=0;
        return false;
    }

    result=a/b;

    return true;
}
```

---

# 17. in

Passes by reference but read-only.

```csharp
void Print(in Person p)
{
    Console.WriteLine(p.Name);
}
```

Avoids copying large structs.

---

# ref vs out vs in

| Keyword | Read | Write | Initialize Before Call |
|----------|------|-------|-------------------------|
| ref | Yes | Yes | Yes |
| out | No | Yes | No |
| in | Yes | No | Yes |

---

# 18. params

Allows variable number of parameters.

```csharp
void Sum(params int[] numbers)
{
    Console.WriteLine(numbers.Sum());
}

Sum(1,2,3,4);
```

Output

```
10
```

---

# 19. yield

Generates values lazily.

```csharp
IEnumerable<int> GetNumbers()
{
    yield return 1;
    yield return 2;
    yield return 3;
}
```

Nothing is created until iteration begins.

---

# 20. async / await

```csharp
public async Task<string> GetData()
{
    await Task.Delay(1000);

    return "Done";
}
```

Thread is not blocked while waiting.

---

# Quick Interview Cheat Sheet

| Keyword | Purpose |
|----------|----------|
| const | Compile-time constant |
| readonly | Runtime immutable field |
| static | Shared across all instances |
| var | Compile-time type inference |
| dynamic | Runtime binding |
| object | Base type of all .NET types |
| IEnumerable | Read-only iteration |
| IQueryable | Database query translation |
| ICollection | Basic collection operations |
| IList | Indexed collection |
| Dictionary | Key-value lookup |
| HashSet | Unique values |
| Span<T> | High-performance memory access |
| Memory<T> | Async-friendly memory wrapper |
| ref | Pass by reference |
| out | Return multiple values |
| in | Read-only reference |
| params | Variable arguments |
| yield | Lazy iteration |
| async/await | Asynchronous programming |

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. Explain the difference between `const`, `readonly`, and `static readonly`.

### Answer

| Feature | const | readonly | static readonly |
|---------|-------|----------|-----------------|
| Initialization | Compile time | Constructor | Static constructor or declaration |
| Memory | Metadata | Per instance | Single shared instance |
| Implicitly Static | Yes | No | Yes |
| Can use runtime values | No | Yes | Yes |

Example:

```csharp
public class Config
{
    public const string AppName = "MyApp";
    public readonly Guid RequestId = Guid.NewGuid();
    public static readonly DateTime StartedAt = DateTime.UtcNow;
}
```

Use `const` only for values that never change (e.g., mathematical constants). Use `readonly` for instance-specific immutable values and `static readonly` for shared runtime-initialized values.

---

## Q2. Explain the difference between `IEnumerable` and `IQueryable`.

### Answer

`IEnumerable` works with in-memory collections and uses delegates for filtering. All data is typically loaded into memory before filtering.

`IQueryable` works with remote data sources (e.g., Entity Framework). It builds an expression tree that the provider translates into SQL, allowing filtering, sorting, and projection to happen in the database.

**Example:**

```csharp
// Loads all rows into memory
var employees = context.Employees.ToList();
var result = employees.Where(e => e.Age > 30);

// Generates SQL with WHERE clause
var result = context.Employees.Where(e => e.Age > 30);
```

For large datasets, `IQueryable` is significantly more efficient because it minimizes data transfer.

---

## Q3. When would you use `Span<T>`?

### Answer

# Span<T> in C# (Complete Guide)

`Span<T>` is one of the most frequently asked interview topics for **Senior .NET Developers (8-15 years)**, especially in companies like Microsoft, Amazon, Point72, Bloomberg, and Google.

---

# What is Span<T>?

`Span<T>` is a **high-performance, memory-safe type** that provides a **view (window)** over a contiguous block of memory **without creating a new copy**.

Think of it as a **pointer with safety**.

> **Interview Definition:**
>
> "`Span<T>` is a stack-only type introduced in C# 7.2/.NET Core that represents a contiguous region of memory, allowing efficient slicing and manipulation of arrays, strings, and buffers without additional memory allocation."

---

# Why was Span<T> introduced?

Normally, when we slice arrays or strings, **new memory is allocated**.

Example:

```csharp
int[] numbers = {1,2,3,4,5};

int[] firstThree = numbers.Take(3).ToArray();
```

Memory

```text
Original Array

1 2 3 4 5

↓

New Array Allocated

1 2 3
```

Problems:

- Extra memory allocation
- More work for GC
- Slower performance

`Span<T>` solves this by creating a **view**, not a copy.

---

# Example Without Span<T>

```csharp
int[] numbers = {1,2,3,4,5};

int[] firstThree = numbers[0..3];
```

Memory

```text
Heap

Original Array

1 2 3 4 5

↓

Copies

1 2 3
```

Two arrays exist.

---

# Example With Span<T>

```csharp
int[] numbers = {1,2,3,4,5};

Span<int> span = numbers.AsSpan(0,3);
```

Memory

```text
Heap

Original Array

1 2 3 4 5

       ▲

       │

Span

(View Only)
```

No new array.

No copy.

---

# Basic Example

```csharp
int[] numbers = {10,20,30,40,50};

Span<int> span = numbers.AsSpan();

foreach(var item in span)
{
    Console.WriteLine(item);
}
```

Output

```
10
20
30
40
50
```

---

# Modifying Data

```csharp
int[] numbers = {10,20,30};

Span<int> span = numbers.AsSpan();

span[0] = 100;
```

Output

```text
Original Array

100

20

30
```

Because Span is only a **view**.

It modifies the original memory.

---

# Slicing

```csharp
int[] numbers =
{
    10,
    20,
    30,
    40,
    50
};

Span<int> slice =
numbers.AsSpan(1,3);
```

Memory

```text
Original

10

20

30

40

50

     ▲

     │

Slice

20

30

40
```

Again

No allocation.

---

# String Example

Normally

```csharp
string name = "Amit Pathak";

string first = name.Substring(0,4);
```

Creates

```
New String
```

Instead

```csharp
ReadOnlySpan<char> span =
name.AsSpan(0,4);
```

Memory

```text
Original String

Amit Pathak

▲

│

ReadOnlySpan

Amit
```

No new string object is created.

---

# stackalloc

One of the biggest advantages.

```csharp
Span<int> numbers =
stackalloc int[5];

numbers[0] = 10;
numbers[1] = 20;
```

Memory

```text
Stack

10

20

0

0

0
```

No Heap allocation.

No Garbage Collection.

Very fast.

---

# Why is Span<T> Fast?

Without Span

```text
Original Array

↓

Allocate New Array

↓

Copy Elements

↓

GC Later
```

With Span

```text
Original Array

↓

Create View

↓

Done
```

No allocation.

No copy.

No GC.

---

# Where Can Span<T> Point?

It can point to

- Array
- Stack Memory
- Native Memory
- String (`ReadOnlySpan<char>`)
- Memory<T>.Span

---

# Example

```csharp
byte[] buffer =
new byte[100];

Span<byte> span =
buffer.AsSpan();
```

No copy.

---

# Why is Span<T> Stack Only?

Definition

```csharp
public readonly ref struct Span<T>
```

Notice

```
ref struct
```

That means

- Lives only on Stack
- Cannot move to Heap

Reason

GC moves heap objects.

Span stores direct references to memory.

If Span lived on Heap

GC movement could make it unsafe.

---

# Restrictions

Cannot do

```csharp
class Test
{
    Span<int> span;
}
```

Compilation Error.

Cannot

```csharp
await Something();

Span<int> span;
```

Because async state machines live on Heap.

Cannot

```csharp
Task.Run(() =>
{
    Span<int> span;
});
```

Cannot capture Span inside lambdas or iterators for the same reason.

---

# ReadOnlySpan<T>

Used when data should not change.

```csharp
ReadOnlySpan<char> name =
"Amit".AsSpan();
```

Cannot modify.

```csharp
name[0]='B';
```

Compilation Error.

---

# Span vs Memory

| Span<T> | Memory<T> |
|-----------|-----------|
| Stack Only | Heap |
| Cannot use with async | Async compatible |
| Faster | Slightly slower |
| Temporary operations | Long-lived operations |

Example

```csharp
Memory<byte> memory =
new byte[100];

await Process(memory);
```

Inside

```csharp
Span<byte> span =
memory.Span;
```

---

# Real World Example

Suppose you're parsing a CSV file.

Without Span

```csharp
foreach(var line in lines)
{
    var columns =
    line.Split(',');
}
```

Every call to `Split()` allocates:

- String array
- Multiple string objects

For

```
10 Million Rows
```

Huge allocations.

---

Using Span

```csharp
ReadOnlySpan<char> line =
input.AsSpan();
```

Process slices instead of creating new strings.

Benefits

- No allocations
- Lower GC pressure
- Much faster parsing

This is how high-performance libraries like **Kestrel**, **System.Text.Json**, and **Pipelines** achieve excellent performance.

---

# Performance Comparison

| Operation | Array Copy | Span<T> |
|------------|------------|----------|
| Allocation | Yes | No |
| Copy Data | Yes | No |
| GC Required | Yes | No |
| Speed | Slower | Faster |
| Memory Usage | Higher | Lower |

---

# When Should You Use Span<T>?

Use `Span<T>` when:

- Processing large arrays.
- Parsing strings, CSV, JSON, or binary protocols.
- Reading network packets.
- Working with file buffers.
- Building high-performance APIs.
- Avoiding unnecessary allocations.
- Reducing GC pressure in performance-critical code.

Do **not** use `Span<T>` for normal business applications where readability is more important than micro-optimizations.

---

# When NOT to Use Span<T>

Avoid it when:

- Data must live beyond the current method.
- Working with async/await.
- Storing data in class fields.
- Passing data across threads.
- Performance is not a concern.

Use `Memory<T>` instead if the data needs a longer lifetime.

---

# Memory Diagram

```text
Without Span

Heap

Array

↓

Copy

↓

Another Array

↓

GC


With Span

Heap

Array

▲

│

Span

(View)

No Copy

No GC
```

---

# Summary

| Feature | Span<T> |
|----------|----------|
| Allocation | None |
| Copy | No |
| GC Pressure | Very Low |
| Lifetime | Stack Only |
| Async Support | No |
| Performance | Excellent |
| Primary Purpose | High-performance memory access |

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. What is `Span<T>`?

### Answer

`Span<T>` is a stack-only (`ref struct`) type that represents a contiguous region of memory. It provides a **view** over existing memory rather than creating a copy, enabling high-performance operations with minimal allocations and reduced garbage collection pressure.

---

## Q2. Why is `Span<T>` faster than arrays or `Substring()`?

### Answer

`Span<T>` avoids allocating new memory. Operations like `Substring()` or array slicing often create new objects, which increases memory usage and GC activity.

`Span<T>` simply references the original memory, so:

- No additional allocation.
- No element copying.
- Lower GC pressure.
- Better throughput.

---

## Q3. Why can't `Span<T>` be used in async methods?

### Answer

`Span<T>` is a `ref struct`, meaning it is restricted to the stack. During an `await`, local variables are moved into an async state machine that lives on the heap.

Allowing a `Span<T>` to survive across an `await` could leave it pointing to invalid memory, so the compiler prohibits this.

---

## Q4. What is the difference between `Span<T>` and `Memory<T>`?

### Answer

| Span<T> | Memory<T> |
|----------|-----------|
| Stack-only (`ref struct`) | Heap-allocated struct |
| Cannot cross `await` | Can be used with async/await |
| Cannot be stored in fields | Can be stored in fields |
| Fastest for temporary operations | Suitable for long-lived buffers |

Use `Span<T>` for short-lived, synchronous processing and `Memory<T>` when the buffer must outlive the current stack frame or be used asynchronously.

---

## Q5. Where is `Span<T>` used in the .NET Framework?

### Answer

Many high-performance .NET libraries rely on `Span<T>`, including:

- **Kestrel** (ASP.NET Core web server)
- **System.Text.Json**
- **System.IO.Pipelines**
- **UTF-8 and text parsers**
- **Cryptography APIs**
- **Networking and protocol parsers**

These libraries use `Span<T>` to reduce allocations and improve throughput in performance-critical paths.

---

## Q4. What is the difference between `Dictionary<TKey,TValue>` and `HashSet<T>`?

### Answer

A `Dictionary<TKey,TValue>` stores key-value pairs and provides O(1) average lookup by key.

A `HashSet<T>` stores only unique values and is optimized for membership checks and duplicate elimination.

Choose `Dictionary` when associated values are needed, and `HashSet` when uniqueness is the primary concern.

---

## Q5. Explain `ref`, `out`, and `in` with use cases.

### Answer

- `ref`: Passes a variable by reference for both reading and writing. The variable must be initialized before the call.
- `out`: Passes a variable by reference for output only. The method must assign a value before returning.
- `in`: Passes a variable by reference as read-only, avoiding copies for large structs while preventing modification.

Use `ref` when updating an existing value, `out` for multiple return values or Try-pattern methods, and `in` to improve performance with immutable large structs.
