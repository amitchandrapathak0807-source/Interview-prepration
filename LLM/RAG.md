# RAG Terminology Explained

Before explaining how to build a RAG application, you should understand the core terminology. These are the terms interviewers expect senior developers to know.

---

# 1. Chunking

## Definition

**Chunking** is the process of breaking a large document into smaller, meaningful pieces (called **chunks**) before generating embeddings.

Instead of embedding an entire 100-page document, we split it into smaller sections.

---

## Why do we need Chunking?

LLMs and embedding models have token limits.

Large documents:

- Are expensive to process
- Produce poor retrieval results
- May exceed model limits

Smaller chunks are:

- Easier to search
- More accurate
- Faster to retrieve

---

## Example

Suppose we have a document:

```
Employee Handbook

Employees receive 12 casual leaves.

Employees receive 8 sick leaves.

Unused casual leaves expire every year.

Employees should apply through the HR Portal.
```

Without chunking

```
Entire Document

↓

One Embedding
```

If a user asks:

> "How many sick leaves are allowed?"

The model has to search within the entire document.

---

With chunking

```
Chunk 1

Employees receive 12 casual leaves.

----------------------------

Chunk 2

Employees receive 8 sick leaves.

----------------------------

Chunk 3

Unused casual leaves expire every year.

----------------------------

Chunk 4

Employees should apply through HR Portal.
```

Now each chunk has its own embedding.

The system retrieves only the relevant chunk instead of the whole document.

---

# 2. Embeddings

## Definition

An **embedding** is a numerical representation (vector) of text that captures its **semantic meaning**.

Instead of storing words, AI converts text into numbers.

---

## Example

Text

```
Employees receive 12 casual leaves.
```

Embedding

```
[0.24, -0.81, 0.62, 0.18, ...]
```

These numbers don't have a human-readable meaning individually, but together they represent the semantic meaning of the sentence.

---

## Why do we need Embeddings?

Traditional search looks for exact words.

Example

Document

```
Employee receives annual leave.
```

User asks

```
Vacation policy
```

Keyword search may fail because:

```
Vacation ≠ Annual Leave
```

Embedding search understands that both are semantically related.

---

## Real-life Analogy

Think of embeddings as GPS coordinates.

```
Mumbai

↓

(18.5204, 73.8567)
```

Similarly,

```
"Dog"

↓

Vector A

"Cat"

↓

Vector B
```

Dog and Cat vectors will be close because they have similar meanings.

Dog and Car vectors will be far apart.

---

# 3. Retrieval

## Definition

**Retrieval** is the process of finding the most relevant chunks from the knowledge base for a user's question.

---

## Example

Knowledge Base

```
Chunk 1

Leave Policy

----------------

Chunk 2

Travel Policy

----------------

Chunk 3

Medical Insurance
```

User asks

```
How many casual leaves are allowed?
```

Retriever searches the vector database and returns

```
Chunk 1

Leave Policy
```

instead of returning every document.

---

## Why Retrieval?

Without retrieval

```
User Question

↓

Entire Knowledge Base

↓

LLM
```

Too expensive.

Too slow.

---

With retrieval

```
User Question

↓

Top 5 Relevant Chunks

↓

LLM
```

Much faster and cheaper.

---

# 4. Prompt

## Definition

A **prompt** is the instruction sent to the LLM.

It contains:

- System Instructions
- Retrieved Context
- User Question

---

## Example

```
You are an HR Assistant.

Answer only from the provided context.

If the answer isn't available,
say "I don't know."

--------------------

Context

Employees receive 12 casual leaves.

--------------------

Question

How many casual leaves are allowed?
```

The quality of the prompt has a huge impact on the quality of the response.

---

# 5. Vector Search

## Definition

Vector Search finds documents based on **meaning**, not exact words.

Instead of matching text, it compares embeddings.

---

## Example

Stored Chunks

```
Chunk 1

Annual Leave Policy

↓

Vector A

-----------------------

Chunk 2

Travel Policy

↓

Vector B
```

User Question

```
Vacation Policy

↓

Vector Q
```

The vector database compares

```
Vector Q

↓

Vector A

↓

Very Similar
```

Even though

```
Vacation

≠

Annual Leave
```

the system understands that both refer to similar concepts.

---

## Real-life Analogy

Think of Spotify recommending songs.

It doesn't look only at song titles.

It recommends songs with a similar style or mood.

Vector Search works in the same way.

---

# 6. Hybrid Search

## Definition

Hybrid Search combines:

- Semantic Search (Vector Search)
- Keyword Search (BM25)

to improve retrieval quality.

---

## Why Hybrid Search?

Imagine the query

```
Azure OpenAI API Version 2025
```

The word

```
2025
```

is important.

Pure vector search may not prioritize the exact year.

Keyword search is good at finding exact terms.

Hybrid Search combines both approaches.

---

## Example

```
User Question

↓

Vector Search

↓

Top 20 Results

+

BM25 Search

↓

Top 20 Results

↓

Merge Results

↓

Best Results
```

This usually produces more accurate retrieval than either approach alone.

---

# 7. Hallucination

## Definition

A **hallucination** occurs when an LLM generates information that is incorrect or not supported by the available context.

---

## Example

Document

```
Employees receive 12 casual leaves.
```

User asks

```
Can casual leaves be carried forward?
```

Wrong Answer

```
Yes, up to 5 casual leaves can be carried forward.
```

The document never mentioned that.

The model invented the answer.

This is a hallucination.

---

Correct Answer

```
The provided documents do not mention whether casual leaves can be carried forward.
```

---

## Why does Hallucination happen?

- Missing context
- Poor retrieval
- Weak prompts
- Model using its own general knowledge instead of provided documents

---

# 8. Metadata Filtering

## Definition

Metadata is additional information stored along with each document or chunk.

It helps narrow down the search before retrieval.

---

## Example

Suppose your knowledge base contains:

```
HR Policies

Finance Policies

Engineering Documents

Legal Documents
```

Each document has metadata.

| Document | Department | Year | Country |
|----------|------------|------|----------|
| Leave Policy | HR | 2025 | India |
| Expense Policy | Finance | 2025 | India |
| Deployment Guide | Engineering | 2025 | USA |

---

User asks

```
Engineering deployment process
```

Instead of searching every document

the system first filters

```
Department = Engineering
```

Now only engineering documents are searched.

---

## Benefits

- Faster retrieval
- Better accuracy
- Lower cost
- Less irrelevant context sent to the LLM

---

# Summary

| Term | Simple Meaning |
|-------|----------------|
| **Chunking** | Splitting large documents into smaller meaningful pieces |
| **Embedding** | Converting text into vectors (numbers) representing semantic meaning |
| **Retrieval** | Finding the most relevant chunks for a user's question |
| **Prompt** | Instructions and context sent to the LLM |
| **Vector Search** | Searching by semantic meaning using embeddings |
| **Hybrid Search** | Combining Vector Search and Keyword (BM25) Search |
| **Hallucination** | The LLM generates incorrect or unsupported information |
| **Metadata Filtering** | Restricting the search using attributes like department, document type, or year |
