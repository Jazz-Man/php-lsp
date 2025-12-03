# PHP LSP — Промпти для Qwen Code (Імплементація)

Цей документ містить промпти для фази імплементації з Qwen Code.

## Коли використовувати Qwen

Qwen Code використовується ПІСЛЯ того як Claude завершив планування:
- ✅ `/sp.constitution` виконано
- ✅ `/sp.specify` створив spec.md
- ✅ `/sp.plan` створив plan.md  
- ✅ `/sp.tasks` створив tasks.md
- ✅ `/sp.analyze` (опціонально) пройшов

Тепер час для `/sp.implement`!

---

## MASTER IMPLEMENTATION PROMPT

**Команда:** `/sp.implement`

**Контекст для Qwen (вставити перед або разом з командою):**

```
## Implementation Context

You are implementing a PHP Language Server in Rust. Before writing ANY code:

### STEP 0: Read Documentation (MANDATORY!)

```bash
# Check available crate documentation
cat target/doc-md/index.md

# Read specific crate APIs you'll use
cat target/doc-md/async_lsp/index.md
cat target/doc-md/tree_sitter/index.md
cat target/doc-md/lsp_types/index.md
cat target/doc-md/ropey/index.md

# If docs are missing
.scripts/regen-docs.sh
```

DO NOT invent APIs. Use ONLY what exists in the documentation.

### Implementation Contract (CRITICAL!)

For EACH task in tasks.md:

1. **Read docs** for the APIs you'll use
2. **Write MAX 20-30 lines** of code
3. **Run:** `cargo check`
4. **If error → FIX IMMEDIATELY** (not "out of scope"!)
5. **Run:** `cargo check` (must pass)
6. **Run:** `git add -A && git commit -m "task: description"`
7. **Only then → next task**

### ABSOLUTE RULES

✗ NEVER write more than 30 lines without `cargo check`
✗ NEVER proceed with compilation errors  
✗ NEVER invent APIs not in documentation
✗ NEVER skip commits between tasks
✗ NEVER say "errors exist but out of scope"
✗ NEVER implement features not in the current plan

✓ ALWAYS read docs before writing code
✓ ALWAYS `cargo check` after every change
✓ ALWAYS fix errors immediately
✓ ALWAYS commit working code
✓ ALWAYS follow the task order from tasks.md

### Code Style

- Use `tracing` for logging (not println!)
- Use `thiserror` for custom errors
- Use `anyhow` for error propagation
- All handlers must be async
- No `.unwrap()` in production code (use `?` or proper error handling)
- Document public APIs with `///` comments

### Project Structure

```
crates/php-lsp/src/
├── main.rs          # Entry point, CLI parsing, server start
├── lib.rs           # Library exports
└── server/
    ├── mod.rs       # Server struct and LanguageServer impl
    ├── documents.rs # Document storage (DashMap<Url, Document>)
    ├── parser.rs    # tree-sitter PHP parsing
    └── handlers/    # LSP request/notification handlers
```

### Example Workflow

```bash
# Task 1: Add Document struct
# 1. Read ropey docs
cat target/doc-md/ropey/index.md

# 2. Write ~20 lines for Document struct
# 3. Check
cargo check

# 4. If OK, commit
git add -A && git commit -m "feat: add Document struct with Rope"

# Task 2: Add DocumentStore
# Repeat process...
```

Now proceed with the tasks in `.specify/specs/{feature}/tasks.md`
```

---

## CONTINUATION PROMPT

Використовуйте коли сесія перервалася і потрібно продовжити:

```
## Continue Implementation

I was implementing the PHP LSP. Let me check the current state:

```bash
# What branch am I on?
git branch --show-current

# What's the status?
git status

# What was the last commit?
git log --oneline -5

# Does it compile?
cargo check
```

Based on the state, I'll continue from where I left off.

Current feature tasks are in: `.specify/specs/{feature}/tasks.md`

Remember the rules:
- Max 20-30 lines per change
- `cargo check` after every change
- Fix errors immediately
- Commit after each successful change
```

---

## FIX/DEBUG PROMPT

Використовуйте коли є помилки компіляції:

```
## Fix Compilation Error

There's a compilation error. Let me fix it properly.

### Step 1: Understand the error
```bash
cargo check 2>&1 | head -50
```

### Step 2: Read relevant documentation
The error mentions a specific type/function. Let me check the docs:
```bash
# Find the crate
cat target/doc-md/index.md

# Read the specific crate docs
cat target/doc-md/{crate}/index.md
```

### Step 3: Fix ONE error at a time
I will:
1. Fix only the FIRST error
2. Run `cargo check`
3. If more errors, repeat

### Step 4: Commit the fix
```bash
git add -A && git commit -m "fix: {description of what was fixed}"
```

DO NOT try to fix everything at once. One error at a time.
```

---

## RESEARCH PROMPT

Використовуйте коли потрібно дослідити API перед імплементацією:

```
## Research API Before Implementation

Before implementing, I need to understand the available APIs.

### Step 1: List available crates
```bash
cat target/doc-md/index.md
```

### Step 2: Read the main crate I'll use
```bash
cat target/doc-md/{crate}/index.md
```

### Step 3: Find specific types/functions
```bash
# Search in docs
grep -r "TypeName" target/doc-md/{crate}/
```

### Step 4: Check crate info
```bash
cargo info {crate}
```

### Step 5: Look at examples in the crate repo
If the docs aren't enough, I may need to look at the crate's GitHub examples.

Now I understand the API and can implement correctly.
```

---

## COMMON PATTERNS

### async-lsp Server Setup

```rust
use async_lsp::{
    lsp_types::*, 
    router::Router,
    MainLoop,
    ServerSocket,
};

struct Backend {
    // your state
}

impl LanguageServer for Backend {
    // implement handlers
}
```

### Document Storage

```rust
use dashmap::DashMap;
use ropey::Rope;
use url::Url;

struct Document {
    uri: Url,
    version: i32,
    content: Rope,
    tree: Option<tree_sitter::Tree>,
}

struct DocumentStore {
    documents: DashMap<Url, Document>,
}
```

### tree-sitter Parsing

```rust
use tree_sitter::{Parser, Language};

fn create_parser() -> Parser {
    let mut parser = Parser::new();
    parser.set_language(&tree_sitter_php::LANGUAGE_PHP.into()).unwrap();
    parser
}
```

### Error Handling

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum LspError {
    #[error("Document not found: {0}")]
    DocumentNotFound(Url),
    
    #[error("Parse error: {0}")]
    ParseError(String),
}
```

---

## Checklist перед /sp.implement

- [ ] Документація згенерована: `ls target/doc-md/`
- [ ] План існує: `cat .specify/specs/{feature}/plan.md`
- [ ] Завдання є: `cat .specify/specs/{feature}/tasks.md`
- [ ] Код компілюється: `cargo check`
- [ ] Git чистий: `git status`

---

## Після завершення імплементації

```bash
# 1. Фінальна перевірка
cargo check
cargo test
cargo clippy

# 2. Commit якщо є незакомічене
git add -A && git commit -m "feat: complete {feature}"

# 3. Створити PR
/sp.git.commit_pr

# Або вручну:
git push -u origin feature/001-xxx
# Створити PR в GitHub
```
