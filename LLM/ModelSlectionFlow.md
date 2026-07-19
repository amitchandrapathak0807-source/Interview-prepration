I choose the model based on task complexity. For simple tasks like translation, grammar correction, summarization, or extracting data, I use a small model because it's fast and cost-effective. For tasks that require understanding information, such as RAG chatbots, SQL generation, or code explanation, I use a medium model. For tasks that require deep reasoning and planning, like system design, production debugging, complex code generation, or AI agents, I use a large reasoning model. My goal is always to use the smallest model that can reliably solve the task while balancing accuracy, latency, and cost.


Simple Work
    ↓
Small Model

Read + Understand
    ↓
Medium Model

Think + Plan + Reason
    ↓
Large Model

                    User Request
                         │
                         ▼
               How difficult is the task?
                         │
      ┌──────────────────┼──────────────────┐
      │                  │                  │
   Simple             Moderate          Complex
      │                  │                  │
      ▼                  ▼                  ▼
   GPT-5 nano         GPT-5 mini          GPT-5

| OpenAI     | Google                | Anthropic     |
| ---------- | --------------------- | ------------- |
| GPT-5 nano | Gemini 2.5 Flash-Lite | Claude Haiku  |
| GPT-5 mini | Gemini 2.5 Flash      | Claude Sonnet |
| GPT-5      | Gemini 2.5 Pro        | Claude Opus   |
