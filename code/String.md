# Top String DSA Interview Questions in C# (Most Asked)

These are the **most frequently asked String problems** in interviews at companies like:

- Microsoft
- Amazon
- Google
- Bloomberg
- Point72
- Goldman Sachs
- Uber
- Adobe

---

# Difficulty Legend

| Level | Meaning |
|--------|----------|
| ⭐ Easy | Basic Interview |
| ⭐⭐ Medium | Standard Coding Round |
| ⭐⭐⭐ Hard | Senior / FAANG |

---

# 1. Reverse a String ⭐

## Problem

Input

```text
hello
```

Output

```text
olleh
```

### Solution

```csharp
public static string Reverse(string input)
{
    char[] arr = input.ToCharArray();

    Array.Reverse(arr);

    return new string(arr);
}
```

### Time Complexity

```
O(n)
```

### Space Complexity

```
O(n)
```

---

# 2. Check Palindrome ⭐

## Problem

Input

```text
madam
```

Output

```text
True
```

### Solution

```csharp
public static bool IsPalindrome(string str)
{
    int left = 0;
    int right = str.Length - 1;

    while (left < right)
    {
        if (str[left] != str[right])
            return false;

        left++;
        right--;
    }

    return true;
}
```

### Complexity

```
Time : O(n)

Space : O(1)
```

---

# 3. First Non-Repeating Character ⭐⭐

## Problem

Input

```text
aabbcddee
```

Output

```text
c
```

### Solution

```csharp
public static char FirstUnique(string str)
{
    Dictionary<char, int> map = new();

    foreach (char c in str)
    {
        map[c] = map.GetValueOrDefault(c, 0) + 1;
    }

    foreach (char c in str)
    {
        if (map[c] == 1)
            return c;
    }

    return '\0';
}
```

### Complexity

```
Time : O(n)

Space : O(n)
```

---

# 4. Count Character Frequency ⭐

## Problem

Input

```text
banana
```

Output

```text
b -> 1

a -> 3

n -> 2
```

### Solution

```csharp
public static Dictionary<char,int> Frequency(string str)
{
    Dictionary<char,int> map = new();

    foreach(char c in str)
    {
        map[c] = map.GetValueOrDefault(c,0)+1;
    }

    return map;
}
```

---

# 5. Check Anagram ⭐⭐

## Problem

Input

```text
listen

silent
```

Output

```text
True
```

### Solution

```csharp
public static bool IsAnagram(string s1,string s2)
{
    if(s1.Length!=s2.Length)
        return false;

    char[] a=s1.ToCharArray();
    char[] b=s2.ToCharArray();

    Array.Sort(a);
    Array.Sort(b);

    return new string(a)==new string(b);
}
```

### Complexity

```
Time : O(n log n)
```

---

# Optimized Solution

```csharp
public static bool IsAnagram(string s1,string s2)
{
    if(s1.Length!=s2.Length)
        return false;

    int[] freq=new int[26];

    foreach(char c in s1)
        freq[c-'a']++;

    foreach(char c in s2)
        freq[c-'a']--;

    return freq.All(x=>x==0);
}
```

```
Time : O(n)
```

---

# 6. Longest Common Prefix ⭐⭐

## Problem

Input

```text
flower

flow

flight
```

Output

```text
fl
```

### Solution

```csharp
public static string LongestCommonPrefix(string[] strs)
{
    if(strs.Length==0)
        return "";

    string prefix=strs[0];

    foreach(var word in strs)
    {
        while(!word.StartsWith(prefix))
        {
            prefix=prefix[..^1];
        }
    }

    return prefix;
}
```

---

# 7. Remove Duplicate Characters ⭐⭐

Input

```text
programming
```

Output

```text
progamin
```

### Solution

```csharp
public static string RemoveDuplicates(string str)
{
    HashSet<char> set=new();

    StringBuilder sb=new();

    foreach(char c in str)
    {
        if(set.Add(c))
            sb.Append(c);
    }

    return sb.ToString();
}
```

---

# 8. String Compression ⭐⭐

Input

```text
aaabbcccc
```

Output

```text
a3b2c4
```

### Solution

```csharp
public static string Compress(string str)
{
    StringBuilder sb=new();

    int count=1;

    for(int i=1;i<=str.Length;i++)
    {
        if(i<str.Length && str[i]==str[i-1])
        {
            count++;
        }
        else
        {
            sb.Append(str[i-1]);
            sb.Append(count);
            count=1;
        }
    }

    return sb.ToString();
}
```

---

# 9. Reverse Words ⭐⭐

Input

```text
I Love CSharp
```

Output

```text
CSharp Love I
```

### Solution

```csharp
public static string ReverseWords(string str)
{
    string[] words=str.Split(' ');

    Array.Reverse(words);

    return string.Join(" ",words);
}
```

---

# 10. Maximum Occurring Character ⭐⭐

Input

```text
banana
```

Output

```text
a
```

### Solution

```csharp
public static char MaxChar(string str)
{
    Dictionary<char,int> map=new();

    foreach(char c in str)
        map[c]=map.GetValueOrDefault(c,0)+1;

    return map.MaxBy(x=>x.Value).Key;
}
```

---

# 11. Longest Substring Without Repeating Characters ⭐⭐⭐

## Problem

Input

```text
abcabcbb
```

Output

```text
3

abc
```

### Sliding Window Solution

```csharp
public static int Length(string s)
{
    HashSet<char> set=new();

    int left=0;

    int max=0;

    for(int right=0;right<s.Length;right++)
    {
        while(set.Contains(s[right]))
        {
            set.Remove(s[left]);
            left++;
        }

        set.Add(s[right]);

        max=Math.Max(max,right-left+1);
    }

    return max;
}
```

### Complexity

```
Time : O(n)

Space : O(n)
```

---

# 12. Longest Palindromic Substring ⭐⭐⭐

Input

```text
babad
```

Output

```text
bab
```

### Approach

Expand Around Center

```
Time : O(n²)

Space : O(1)
```

*(Frequently asked in FAANG interviews.)*

---

# 13. Group Anagrams ⭐⭐⭐

Input

```text
eat

tea

tan

ate

nat

bat
```

Output

```text
[eat tea ate]

[tan nat]

[bat]
```

### Solution

```csharp
public static IList<IList<string>> Group(string[] strs)
{
    Dictionary<string,List<string>> map=new();

    foreach(var word in strs)
    {
        char[] arr=word.ToCharArray();

        Array.Sort(arr);

        string key=new(arr);

        if(!map.ContainsKey(key))
            map[key]=new();

        map[key].Add(word);
    }

    return map.Values
              .Select(x=>(IList<string>)x)
              .ToList();
}
```

---

# 14. Minimum Window Substring ⭐⭐⭐

LeetCode 76

Uses

- Sliding Window
- Dictionary
- Two Pointers

```
Time : O(n)
```

Very common in Google.

---

# 15. Valid Parentheses ⭐⭐

Input

```text
()

[]

{}
```

Output

```text
True
```

### Solution

```csharp
public static bool IsValid(string s)
{
    Stack<char> stack = new();

    foreach (char c in s)
    {
        if (c == '(' || c == '{' || c == '[')
        {
            stack.Push(c);
        }
        else
        {
            if (stack.Count == 0)
                return false;

            char top = stack.Pop();

            if ((c == ')' && top != '(') ||
                (c == '}' && top != '{') ||
                (c == ']' && top != '['))
                return false;
        }
    }

    return stack.Count == 0;
}
```

---

# Most Asked LeetCode String Problems

| Problem | Difficulty |
|----------|------------|
| Reverse String | ⭐ |
| Valid Anagram | ⭐ |
| Valid Palindrome | ⭐ |
| Reverse Words | ⭐ |
| Longest Common Prefix | ⭐⭐ |
| Longest Substring Without Repeating Characters | ⭐⭐⭐ |
| Group Anagrams | ⭐⭐⭐ |
| Longest Palindromic Substring | ⭐⭐⭐ |
| Minimum Window Substring | ⭐⭐⭐ |
| String Compression | ⭐⭐ |
| Decode String | ⭐⭐⭐ |
| Implement `strStr()` (KMP) | ⭐⭐⭐ |
| Zigzag Conversion | ⭐⭐ |
| Multiply Strings | ⭐⭐⭐ |
| Text Justification | ⭐⭐⭐ |

---

# Common String Patterns

| Pattern | Problems |
|----------|----------|
| Two Pointers | Reverse String, Palindrome |
| Sliding Window | Longest Substring, Minimum Window |
| HashMap | Anagram, Frequency Count |
| Stack | Parentheses, Decode String |
| Sorting | Group Anagrams |
| Expand Around Center | Longest Palindrome |
| Dynamic Programming | Edit Distance, Regex Matching |
| KMP | Pattern Searching |
| Trie | Prefix Search, Auto Complete |

---

# Interview Questions & Answers (10+ Years Experience)

## Q1. Why is `StringBuilder` preferred over string concatenation in loops?

### Answer

`string` is immutable in .NET. Every concatenation creates a **new string object**, resulting in repeated memory allocations and increased GC pressure.

```csharp
string result = "";

for(int i = 0; i < 10000; i++)
{
    result += i;
}
```

This creates thousands of temporary string objects.

Using `StringBuilder`:

```csharp
StringBuilder sb = new();

for(int i = 0; i < 10000; i++)
{
    sb.Append(i);
}

string result = sb.ToString();
```

`StringBuilder` uses a resizable buffer, significantly reducing allocations and improving performance.

---

## Q2. How would you optimize string algorithms for large datasets?

### Answer

For large-scale processing:

- Use **`Span<char>` / `ReadOnlySpan<char>`** to avoid unnecessary allocations.
- Prefer **Sliding Window** over nested loops where applicable.
- Use **HashSet** or **Dictionary** for O(1) lookups.
- Avoid repeated `Substring()` calls.
- Use `StringBuilder` for concatenation.
- Minimize copying of strings and arrays.

---

## Q3. Which string problems are asked most frequently in senior interviews?

### Answer

The most common problems include:

1. Longest Substring Without Repeating Characters.
2. Group Anagrams.
3. Longest Palindromic Substring.
4. Minimum Window Substring.
5. Valid Parentheses.
6. Reverse Words in a String.
7. String Compression.
8. Pattern Matching (KMP).
9. Edit Distance.
10. Decode String.

Interviewers often evaluate not only correctness but also the chosen algorithm, time complexity, space complexity, and the ability to discuss optimizations and trade-offs.
