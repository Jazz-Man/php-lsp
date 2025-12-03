# PHP LSP — Промпти для Claude Code (Планування)

Цей документ містить промпти для фази планування з використанням spec-kit-plus.

## Загальний Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  /sp.constitution  (один раз на початку проекту)            │
└─────────────────────────────┬───────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  Для КОЖНОЇ фічі (Phase 1, 2, 3...):                        │
│                                                             │
│  /sp.specify  → створює git branch feature/001-xxx         │
│       ↓                                                     │
│  /sp.clarify  (optional) → AI задає уточнюючі питання       │
│       ↓                                                     │
│  /sp.plan     → технічний план, data models, interfaces    │
│       ↓                                                     │
│  /sp.adr      (optional) → Architecture Decision Records   │
│       ↓                                                     │
│  /sp.tasks    → розбиття на конкретні завдання              │
│       ↓                                                     │
│  /sp.analyze  (optional) → перевірка консистентності        │
│       ↓                                                     │
│  ══════════════ SWITCH TO QWEN ══════════════               │
│       ↓                                                     │
│  /sp.implement → виконання завдань                          │
│       ↓                                                     │
│  /sp.git.commit_pr → commit + create PR                     │
│       ↓                                                     │
│  Test & Merge → merge to main                               │
│       ↓                                                     │
│  ══════════════ NEXT FEATURE ══════════════                 │
└─────────────────────────────────────────────────────────────┘
```

**ВАЖЛИВО:** Кожна фіча = окрема git гілка. Завершіть одну фічу повністю перед початком наступної!

---

## 1. Constitution (Один раз на початку)

**Команда:** `/sp.constitution`

**Промпт:**

```
## Project Overview

This is a custom Language Server Protocol (LSP) server for PHP, implemented in Rust using `async-lsp` and following Specification-Driven Development (SDD) principles with `spec-kit-plus`. The goal is to create a lightweight, modular, and hackable LSP that provides full PHP language support comparable to PHPStorm's built-in capabilities.

## Personal Motivation & Business Case

### Personal Motivation
One of my main motivations for this project is that I've long dreamed of writing an LSP server in Rust using modern async tools. I'm also not satisfied with the current state of PHP support in existing tools. I've used Intelephense extensively — while it's quite powerful and feature-rich, it often feels heavy, opaque, and hard to extend or debug. Similarly, JetBrains IDEs, although popular, tend to be resource-intensive and somewhat rigid for modern PHP workflows. What I really want is something lightweight, modular, and hackable — a language server that's truly optimized for my workflow and that I fully control. That's what pushed me toward building a custom solution from scratch.

### Business Value & Time Savings
This custom LSP is not just a technical exercise - it's a strategic investment that will save me significant time and money:

- **License Cost Savings**: Avoiding annual subscriptions to PhpStorm (~$100-200/year) or Intelephense (~$40-100/year) by having a custom, open-source solution
- **Time Efficiency**: Having full control over the LSP means I can optimize it specifically for my workflow and the specific PHP projects I work on
- **Customization**: Tailor the LSP to my exact needs rather than paying for features I don't use in commercial solutions
- **WordPress-Specific Features**: The advanced WordPress hooks system support that only PHPStorm provides adequately (but at a high cost) will be available in my custom Zed-based setup
- **Long-term Maintainability**: Having source code control means I can maintain and extend the LSP as my needs evolve without being dependent on third-party vendors

## Technology Stack

- **Language**: Rust (edition 2021)
- **LSP Framework**: async-lsp 0.2.2 with tokio runtime
- **PHP Parser**: tree-sitter-php 0.24.2
- **Text Handling**: ropey for rope-based incremental text
- **LSP Types**: lsp-types 0.97
- **Target Editor**: Zed (via WebAssembly extension using zed_extension_api)

## Development Principles

### 1. DOCUMENTATION FIRST (CRITICAL!)
Before writing ANY code:
- Read `target/doc-md/index.md` for available crates
- Read `target/doc-md/{crate}/index.md` for specific APIs
- Use `cargo info <crate>` to check versions and features
- DO NOT invent APIs — use ONLY what exists in documentation
- If documentation is missing, run `.scripts/regen-docs.sh`

### 2. ITERATIVE DEVELOPMENT (CRITICAL!)
This is the most important principle. AI agents tend to do "dump and run" — writing 500 lines then saying "done, has errors but out of scope". This is NOT acceptable.

Required approach:
- Write MAX 20-30 lines at a time
- After EVERY change: `cargo check`
- If errors: FIX IMMEDIATELY before continuing
- After fix confirmed: `git commit -m "..."`
- NEVER proceed with broken code
- NEVER say "errors exist but out of scope"

### 3. USE EXISTING FUNCTIONALITY
- Check if feature exists in dependencies before implementing
- async-lsp likely has what you need — READ ITS DOCS
- Don't reinvent wheels
- Prefer composition over custom implementations

### 4. CODE QUALITY STANDARDS
- All handlers must be async and non-blocking
- Error handling with thiserror/anyhow (no unwrap in production code)
- Tracing for all logging (not println!)
- Tests for each module
- Documentation comments for public APIs

### 5. PHP & WORDPRESS SPECIFICS
- Support PHP 8+ syntax fully
- Parse PHPDoc annotations: @param, @return, @var, @template, @psalm-*, @phpstan-*
- WordPress Hook API: all 18 functions with go-to-definition
- composer.json integration: PHP version detection, ext-* warnings, PSR-4/PSR-0 autoload

## Project Structure

```
php-lsp/
├── crates/
│   ├── php-lsp/              # Main LSP server
│   │   ├── src/
│   │   │   ├── main.rs       # Entry point with --stdio
│   │   │   ├── lib.rs        # Library exports
│   │   │   └── server/       # Server modules
│   │   └── Cargo.toml
│   └── zed-php-lsp/          # Zed extension (WASM)
│       ├── src/lib.rs
│       ├── extension.toml
│       └── Cargo.toml
├── .specify/                  # SDD specifications
├── .scripts/                  # Helper scripts
├── target/doc-md/            # Generated documentation for AI
└── Cargo.toml                # Workspace
```

## Feature Phases (Development Order)

1. **Core Infrastructure** — LSP lifecycle, document sync, PHP parsing
2. **Symbol Navigation** — Document symbols, go-to-definition, references
3. **Code Completion** — Variables, members, classes, signature help
4. **WordPress Hooks** — Hook navigation, completion, hover
5. **Composer Integration** — PHP version, autoload, vendor navigation

## Implementation Contract

For EVERY task during implementation:

1. ✅ Read relevant docs from `target/doc-md/`
2. ✅ Write max 20-30 lines of code
3. ✅ Run: `cargo check`
4. ✅ If error → fix immediately (NOT "out of scope"!)
5. ✅ Run: `cargo check` (must pass)
6. ✅ Run: `git commit -m "..."`
7. ✅ Only then → next task

ABSOLUTE RULES:
- ✗ NEVER write more than 30 lines without `cargo check`
- ✗ NEVER proceed with compilation errors
- ✗ NEVER invent APIs not in documentation
- ✗ NEVER skip commits between tasks
- ✗ NEVER implement features not in the current plan

## Reference Projects

Study these for patterns (but don't copy blindly):
- filiptibell/async-language-server — higher-level abstraction on async-lsp
- phpactor/phpactor — generic PHP LSP (no WordPress support)

## Success Criteria

The LSP is complete when:
1. Zed editor loads it successfully via extension
2. Basic PHP editing works (syntax highlighting, errors)
3. Go-to-definition works for functions, classes, methods
4. WordPress hooks navigation works (do_action → add_action)
5. Code completion provides relevant suggestions
6. Performance is acceptable (no noticeable lag)
```

---

## 2. Phase 1 — Core Infrastructure

**Команда:** `/sp.specify`

**Промпт:**

```
# Feature: Core Infrastructure

## Overview
Implement the foundational LSP server infrastructure that handles lifecycle management, document synchronization, and PHP parsing with tree-sitter.

## User Stories

### US-1: LSP Lifecycle
As a Zed user, I want the PHP LSP to properly initialize and shutdown so that my editor integrates smoothly.

Acceptance Criteria:
- Server responds to `initialize` request with capabilities
- Server handles `initialized` notification
- Server responds to `shutdown` request
- Server exits cleanly on `exit` notification
- Capabilities include: textDocumentSync, hoverProvider, definitionProvider, referencesProvider, documentSymbolProvider, completionProvider

### US-2: Document Synchronization
As a developer, I want my PHP files to be tracked by the LSP so that I get real-time feedback.

Acceptance Criteria:
- Handle `textDocument/didOpen` — store document content
- Handle `textDocument/didChange` — update content (incremental sync)
- Handle `textDocument/didClose` — cleanup document
- Use ropey for efficient text rope handling
- Cache parsed AST per document

### US-3: PHP Parsing
As a developer, I want PHP files to be parsed correctly so that all language features work.

Acceptance Criteria:
- Initialize tree-sitter with PHP grammar
- Parse documents on open and change
- Cache AST with document version
- Handle parse errors gracefully (partial AST)
- Support PHP 8+ syntax (attributes, named arguments, match, etc.)

### US-4: stdio Transport
As a Zed extension, I want the LSP to communicate via stdio so that it integrates with Zed.

Acceptance Criteria:
- Accept `--stdio` command line flag
- Read JSON-RPC from stdin
- Write JSON-RPC to stdout
- Use async-lsp's stdio transport
- Proper error handling for malformed messages

## Technical Notes

- Use async-lsp's `MainLoop` and `ServerSocket` for the server
- Use `LanguageServer` trait for request/notification handlers
- Store documents in `DashMap<Url, Document>` for concurrent access
- Document struct should contain: uri, version, content (Rope), ast (Tree)
- Use tracing for logging, not println

## Out of Scope
- Diagnostics (Phase 2)
- Symbol navigation (Phase 2)
- Completion (Phase 3)
- WordPress hooks (Phase 4)
```

---

## 3. Phase 2 — Symbol Navigation

**Команда:** `/sp.specify`

**Промпт:**

```
# Feature: Symbol Navigation

## Overview
Implement symbol-related LSP features including document outline, go-to-definition, find references, and hover information.

## User Stories

### US-1: Document Symbols (Outline)
As a developer, I want to see an outline of my PHP file so that I can navigate quickly.

Acceptance Criteria:
- Handle `textDocument/documentSymbol` request
- Return hierarchical symbols: classes, methods, functions, constants
- Include symbol kind, name, range, selection range
- Support nested symbols (methods inside classes)
- Include properties and class constants

### US-2: Go to Definition
As a developer, I want to jump to where a symbol is defined so that I can understand the code.

Acceptance Criteria:
- Handle `textDocument/definition` request
- Resolve function calls to function definitions
- Resolve class instantiation to class definitions
- Resolve method calls to method definitions
- Resolve property access to property definitions
- Support same-file and cross-file navigation
- Handle `$this->method()` and `self::method()` and `static::method()`

### US-3: Find References
As a developer, I want to find all usages of a symbol so that I can refactor safely.

Acceptance Criteria:
- Handle `textDocument/references` request
- Find all references to functions
- Find all references to classes
- Find all references to methods
- Find all references to properties
- Include or exclude declaration based on context.includeDeclaration

### US-4: Hover Information
As a developer, I want to see information about a symbol when I hover so that I understand its purpose.

Acceptance Criteria:
- Handle `textDocument/hover` request
- Show function/method signature
- Show PHPDoc description if available
- Show parameter types and return type
- Show class/interface documentation
- Format as Markdown

## Technical Notes

- Build a symbol index per workspace
- Index structure: symbol name → location(s)
- Use tree-sitter queries for extracting symbols
- PHPDoc parsing: extract @param, @return, @var
- Cross-file navigation requires workspace scanning

## Dependencies
- Phase 1 (Core Infrastructure) must be complete
- Document storage and AST caching must work
```

---

## 4. Phase 3 — Code Completion

**Команда:** `/sp.specify`

**Промпт:**

```
# Feature: Code Completion

## Overview
Implement intelligent code completion for PHP including variables, class members, functions, and signature help.

## User Stories

### US-1: Variable Completion
As a developer, I want to complete variable names so that I type faster and avoid typos.

Acceptance Criteria:
- Trigger on `$` character
- Complete local variables in scope
- Complete function parameters
- Complete `$this` in class context
- Show variable type if known from PHPDoc or assignment

### US-2: Member Completion
As a developer, I want to complete class members after `->` and `::` so that I discover available methods.

Acceptance Criteria:
- Trigger on `->` after object variable
- Trigger on `::` after class name
- Complete methods with visibility filtering
- Complete properties with visibility filtering
- Complete static members for `::`
- Show method signatures in detail

### US-3: Class/Function Completion
As a developer, I want to complete class and function names so that I use the correct names.

Acceptance Criteria:
- Complete class names for `new ` context
- Complete function names in expression context
- Complete namespace-qualified names
- Include use statements in suggestions
- Support auto-import (add use statement)

### US-4: Signature Help
As a developer, I want to see parameter hints when calling functions so that I pass correct arguments.

Acceptance Criteria:
- Handle `textDocument/signatureHelp` request
- Trigger on `(` after function/method name
- Show parameter names and types
- Highlight current parameter based on cursor position
- Show PHPDoc parameter descriptions

## Technical Notes

- Use `textDocument/completion` with trigger characters: `$`, `>`, `:`
- CompletionItem should include: label, kind, detail, documentation, insertText
- For member completion, need to resolve the type of the object
- Type inference: assignments, PHPDoc @var, function return types
- Signature help triggers: `(`, `,`

## Dependencies
- Phase 2 (Symbol Navigation) — need symbol index
- Type information from PHPDoc parsing
```

---

## 5. Phase 4 — WordPress Hooks

**Команда:** `/sp.specify`

**Промпт:**

```
# Feature: WordPress Hooks Integration

## Overview
Implement WordPress-specific features for hook navigation, completion, and documentation. This is the key differentiator from other PHP LSPs.

## WordPress Detection

A project is WordPress if any of these exist:
- `wp-config.php` in project root
- `wp-includes/` directory
- `wp-content/` directory
- `wordpress` in composer.json dependencies

## WordPress Hook API — All 18 Functions

### Registration Functions
1. `add_action($hook, $callback, $priority=10, $args=1)`
2. `add_filter($hook, $callback, $priority=10, $args=1)`

### Invocation Functions (define hooks)
3. `do_action($hook, ...$args)`
4. `do_action_ref_array($hook, $args)`
5. `apply_filters($hook, $value, ...$args)`
6. `apply_filters_ref_array($hook, $args)`

### Removal Functions
7. `remove_action($hook, $callback, $priority=10)`
8. `remove_filter($hook, $callback, $priority=10)`
9. `remove_all_actions($hook, $priority=false)`
10. `remove_all_filters($hook, $priority=false)`

### Inspection Functions
11. `has_action($hook, $callback=false)`
12. `has_filter($hook, $callback=false)`
13. `did_action($hook)` → int
14. `did_filter($hook)` → int
15. `doing_action($hook=null)` → bool
16. `doing_filter($hook=null)` → bool
17. `current_action()` → string
18. `current_filter()` → string

## User Stories

### US-1: Hook Definition Navigation
As a WordPress developer, I want to go-to-definition on a hook name to see where it's invoked.

Acceptance Criteria:
- From `add_action('init', ...)` → jump to `do_action('init')`
- From `add_filter('the_content', ...)` → jump to `apply_filters('the_content', ...)`
- Show all invocation locations if multiple
- Work across all files in workspace

### US-2: Callback Navigation
As a WordPress developer, I want to go-to-definition on a callback to see the handler function.

Acceptance Criteria:
- Resolve string callback: `'my_function'` → function definition
- Resolve array callback: `[$this, 'method']` → method definition
- Resolve static callback: `[ClassName::class, 'method']` → static method
- Handle closure callbacks (show location)

### US-3: Hook References
As a WordPress developer, I want to find all registrations for a hook.

Acceptance Criteria:
- From `do_action('init')` → find all `add_action('init', ...)`
- Show file, line, callback, priority for each
- Include `remove_action` calls too

### US-4: Hook Completion
As a WordPress developer, I want to complete hook names so that I use correct hooks.

Acceptance Criteria:
- Complete hook names from known hooks in workspace
- Include WordPress core hooks (common ones)
- Show hook documentation if available
- Trigger inside first argument of hook functions

### US-5: Hook Hover
As a WordPress developer, I want to see hook information on hover.

Acceptance Criteria:
- Show all registered callbacks for a hook
- Show invocation location(s)
- Show parameter count from do_action/apply_filters
- Format as readable documentation

## Technical Notes

- Build a hook index: hook_name → { invocations: [], registrations: [] }
- Callback formats to parse:
  - `'function_name'` — string
  - `[$this, 'method']` — array with $this
  - `[ClassName::class, 'method']` — array with class
  - `[self::class, 'method']` — array with self
  - `function() {}` — closure (just note location)
- Scan all PHP files for hook function calls
- Core hooks list: init, wp_loaded, admin_init, the_content, etc.

## Dependencies
- Phase 2 (Symbol Navigation) — for callback resolution
- Phase 3 (Completion) — for completion infrastructure
```

---

## 6. Phase 5 — Composer Integration

**Команда:** `/sp.specify`

**Промпт:**

```
# Feature: Composer Integration

## Overview
Integrate with composer.json for PHP version detection, extension warnings, and PSR-4/PSR-0 autoload resolution for vendor navigation.

## User Stories

### US-1: PHP Version Detection
As a developer, I want the LSP to respect my project's PHP version for syntax support.

Acceptance Criteria:
- Read `require.php` from composer.json
- Parse version constraint (^8.1, >=8.0, etc.)
- Use minimum version for feature detection
- Warn about syntax not supported by target version
- Fall back to PHP 8.1 if not specified

### US-2: Extension Warnings
As a developer, I want to be warned about missing PHP extensions so I configure my environment correctly.

Acceptance Criteria:
- Detect `ext-*` in require/require-dev
- Show info about required extensions
- Don't error, just inform (extensions are runtime)

### US-3: PSR-4 Autoload Resolution
As a developer, I want to navigate to vendor classes so I can understand dependencies.

Acceptance Criteria:
- Parse `autoload.psr-4` from composer.json
- Map namespace prefixes to directories
- Resolve `use App\Service\UserService` to file path
- Support multiple namespace roots
- Include vendor/ packages (parse their composer.json)

### US-4: Vendor Class Navigation
As a developer, I want go-to-definition to work for vendor classes.

Acceptance Criteria:
- Index classes from vendor/ on workspace load
- Go-to-definition on vendor class names
- Show vendor class in hover
- Don't modify vendor files (read-only navigation)

## Technical Notes

- Parse composer.json with serde_json
- Cache autoload mappings per workspace
- For vendor, only index on-demand or with limits
- PSR-4 rules: namespace prefix → directory, then class name → file path
- Consider composer.lock for exact versions

## Dependencies
- Phase 2 (Symbol Navigation) — for definition/references
- File system scanning for vendor/
```

---

## Швидкий довідник команд

| Етап | Команда | Опис |
|------|---------|------|
| 1 | `/sp.constitution` | Встановити принципи (один раз) |
| 2 | `/sp.specify` | Описати фічу (вставити промпт Phase N) |
| 3 | `/sp.clarify` | (опціонально) AI задає питання |
| 4 | `/sp.plan` | Створити технічний план |
| 5 | `/sp.adr` | (опціонально) Документувати рішення |
| 6 | `/sp.tasks` | Розбити на завдання |
| 7 | `/sp.analyze` | (опціонально) Перевірити консистентність |
| 8 | **→ Qwen** | Перемкнутися на Qwen для імплементації |
| 9 | `/sp.implement` | Виконати завдання |
| 10 | `/sp.git.commit_pr` | Commit і створити PR |
| 11 | Merge & Next | Змержити і почати наступну фічу |

---

## Примітки

### Перед /sp.plan
Завжди переконайтесь що документація згенерована:
```bash
.scripts/regen-docs.sh
```

### Між фічами
Після merge однієї фічі:
```bash
git checkout main
git pull
# Тепер можна /sp.specify для наступної фази
```

### Якщо щось пішло не так
```bash
# Подивитися стан
git status
git branch

# Скинути незакомічені зміни
git checkout -- .

# Видалити гілку і почати заново
git checkout main
git branch -D feature/001-xxx
```
