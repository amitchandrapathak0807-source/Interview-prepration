# Stack vs Heap in C#

One of the most frequently asked interview questions is:

> **"What is the difference between Stack and Heap?"**

Understanding this is fundamental to how .NET manages memory.

---

# What is Stack?

The **Stack** is a memory region used for **method execution**.

It stores:

- Local variables
- Method parameters
- Value types (unless boxed or contained in a reference type)
- References (addresses) to objects

### Characteristics

- Very fast
- Automatically allocated and deallocated
- Thread-specific (every thread has its own stack)
- Small in size (typically a few MB)

---

# What is Heap?

The **Heap** is a memory region used to store **objects**.

It stores:

- Objects
- Arrays
- Strings
- Collections
- Class instances

The **Garbage Collector (GC)** manages memory in the Heap.

---

# Stack vs Heap

| Feature | Stack | Heap |
|----------|-------|------|
| Stores | Local variables, method calls, references | Objects, arrays, strings |
| Allocation Speed | Very Fast | Slower than Stack |
| Deallocation | Automatic when method exits | Garbage Collector |
| Size | Small | Large |
| Thread Safety | Thread-specific | Shared among threads |
| Lifetime | Method scope | Until GC collects it |
| Managed By | CLR Stack Manager | Garbage Collector |

---

# Memory Diagram

```text
+------------------------------------------+
|                 Stack                    |
|------------------------------------------|
| int age = 30                             |
| Person p -------------------------+      |
| string nameRef -------------------|----+ |
+-----------------------------------|----|-+
                                    |    |
                                    V    V
+-----------------------------------------------+
|                  Heap                         |
|-----------------------------------------------|
| Person Object                                 |
| Name = "Amit"                                 |
| Age = 30                                      |
|                                               |
| String Object                                 |
| "Hello"                                       |
+-----------------------------------------------+
```

---

# Example 1 - Value Type

```csharp
int age = 25;
```

Memory

```text
Stack

+----------------+
| age = 25       |
+----------------+
```

No heap allocation.

---

# Example 2 - Reference Type

```csharp
Person p = new Person();
```

Memory

```text
Stack

+---------------------------+
| p --------------------+   |
+-----------------------|---+
                        |
                        V

Heap

+----------------------+
| Person Object        |
+----------------------+
```

The object lives in the Heap.

The reference lives in the Stack.

---

# Example 3 - Class with Properties

```csharp
class Person
{
    public string Name;
    public int Age;
}

Person p = new Person();

p.Name = "Amit";
p.Age = 30;
```

Memory

```text
Stack

+------------------------------+
| p -----------------------+   |
+--------------------------|---+
                           |
                           V

Heap

+-------------------------------+
| Person                        |
|-------------------------------|
| Name ----------+              |
| Age = 30       |              |
+----------------|--------------+
                 |
                 V

+----------------------+
| String "Amit"        |
+----------------------+
```

---

# Example 4 - Method Call

```csharp
void Print()
{
    int x = 10;

    Person p = new Person();
}
```

Memory while executing

```text
Stack Frame

+----------------------+
| x = 10               |
| p ----------------+  |
+-------------------|--+
                    |
                    V

Heap

+----------------+
| Person Object  |
+----------------+
```

After method returns

```text
Stack Frame Removed

Heap

Person Object

(No Reference)
```

Now the object becomes eligible for GC.

---

# Example 5 - Multiple References

```csharp
Person p1 = new Person();

Person p2 = p1;
```

Memory

```text
Stack

p1 --------+

            |

p2 ---------|----+

             |   |

             V   |

Heap         |   |

+------------|---+
| Person     |
+------------+
```

Even if

```csharp
p1 = null;
```

Object is still alive because

```text
p2 ---> Person
```

---

# Example 6 - Value Type Copy

```csharp
int a = 10;

int b = a;

b = 50;
```

Memory

```text
Stack

a = 10

b = 50
```

Output

```text
a = 10

b = 50
```

Each variable has its own copy.

---

# Example 7 - Reference Type Copy

```csharp
Person p1 = new Person();

p1.Name = "Amit";

Person p2 = p1;

p2.Name = "Rahul";
```

Memory

```text
Stack

p1 ----------+

              |

p2 ----------|----+

              |   |

              V   |

Heap          |   |

+---------------------------+
| Person                    |
| Name = Rahul              |
+---------------------------+
```

Output

```text
Rahul

Rahul
```

Both variables point to the same object.

---

# Example 8 - String

```csharp
string name = "Hello";
```

Memory

```text
Stack

name ----------+

                |

                V

Heap

"Hello"
```

The variable is on the stack.

The string object is on the heap.

> **Note:** Strings are immutable and may be interned by the CLR.

---

# Example 9 - Array

```csharp
int[] numbers = {1,2,3};
```

Memory

```text
Stack

numbers ------+

               |

               V

Heap

+----------------------+
| 1 | 2 | 3            |
+----------------------+
```

Arrays always live on the Heap.

---

# Example 10 - Struct vs Class

```csharp
struct Employee
{
    public int Id;
}

class Person
{
    public int Id;
}
```

Usage

```csharp
Employee e = new Employee();

Person p = new Person();
```

Memory

```text
Stack

Employee e

Person Reference

            |

            V

Heap

Person Object
```

Struct (value type) is stored inline (typically on the stack for local variables).

Class instance is stored on the Heap.

---

# Stack Frame

Every method call creates a new **Stack Frame**.

Example

```csharp
void Main()
{
    Print();
}

void Print()
{
    int x = 10;
}
```

Memory

```text
Before Call

+-------------+
| Main()      |
+-------------+

After Print()

+-------------+
| Print()     |
| x = 10      |
+-------------+
| Main()      |
+-------------+

After Return

+-------------+
| Main()      |
+-------------+
```

When `Print()` finishes, its stack frame is immediately removed.

---

# Stack Overflow

Occurs when the Stack exceeds its limit.

Example

```csharp
void Test()
{
    Test();
}
```

Infinite recursion

```text
Main()

↓

Test()

↓

Test()

↓

Test()

↓

Test()

↓

StackOverflowException
```

---

# Heap Memory Leak Example

```csharp
static List<Person> cache = new();

void Add()
{
    cache.Add(new Person());
}
```

Even after `Add()` returns, objects remain referenced by the static list.

```text
Static List

↓

Person

↓

Person

↓

Person
```

GC cannot collect these objects because they are still reachable.

---

# Stack vs Heap Summary

| Stack | Heap |
|--------|------|
| Stores value types and references | Stores objects |
| Very fast allocation | Slower allocation |
| Automatic cleanup on method exit | Garbage Collector cleanup |
| Thread-specific | Shared memory |
| Small size | Large size |
| LIFO (Last In, First Out) | Dynamic allocation |

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. Explain the difference between Stack and Heap.

### Answer

The **Stack** is used for method execution and stores local variables, method parameters, and object references. It follows a **Last In, First Out (LIFO)** structure and is automatically cleaned up when a method exits.

The **Heap** stores dynamically allocated objects such as class instances, arrays, and strings. Memory on the Heap is managed by the .NET Garbage Collector, which reclaims memory when objects become unreachable.

---

## Q2. Where are value types and reference types stored?

### Answer

- **Value types** (e.g., `int`, `bool`, `struct`) are typically stored inline on the stack when used as local variables. If they are fields of a class, they are stored inside that object on the heap. Boxed value types are also allocated on the heap.
- **Reference types** (e.g., `class`, `string`, `array`) are allocated on the heap, while the reference variable itself is stored on the stack (for local variables).

---

## Q3. Why is Stack allocation faster than Heap allocation?

### Answer

Stack allocation is extremely fast because it only involves moving the stack pointer. No complex memory search or garbage collection is required.

Heap allocation requires locating free memory, updating heap metadata, and eventually participating in garbage collection, making it comparatively slower.

---

## Q4. Why are objects stored on the Heap?

### Answer

Objects often have dynamic lifetimes that can outlive the method that created them. Storing them on the heap allows multiple methods and threads to reference the same object, while the Garbage Collector determines when the object is no longer needed.

---

## Q5. What causes a `StackOverflowException`?

### Answer

A `StackOverflowException` occurs when the call stack exceeds its allocated size, usually due to:

- Infinite recursion.
- Excessively deep recursive calls.
- Large local variables consuming stack space.

Example:

```csharp
void Test()
{
    Test();
}
```

This keeps creating stack frames until the stack limit is reached.

---

## Q6. Can the Heap have memory leaks even with Garbage Collection?

### Answer

Yes. A memory leak in .NET occurs when objects remain **reachable** even though the application no longer needs them.

Common causes include:

- Static collections.
- Event handlers that are never unsubscribed.
- Long-lived caches.
- Singleton services retaining references.
- Timers and background tasks.

The Garbage Collector only collects **unreachable** objects, so reachable but unused objects continue consuming memory.
