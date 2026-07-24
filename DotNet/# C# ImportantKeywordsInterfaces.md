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

Use `Span<T>` in high-performance scenarios where you need to work with slices of arrays, buffers, or strings without allocating additional memory.

Common use cases:

- Parsing large files.
- Network protocol processing.
- Serialization/deserialization.
- High-frequency APIs.

`Span<T>` avoids allocations and copies, but it is stack-only and cannot cross `await` boundaries.

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
