# PHP Language Server Protocol (LSP) Server

A fast and lightweight Language Server for PHP, written in Rust. This tool makes writing PHP code more enjoyable in any code editor.

## What is this?

This is a program that runs in the background and helps you write PHP code faster with fewer errors. It shows you suggestions, finds mistakes, helps you navigate to function definitions, and much more.

## Why am I building this?

### Personal motivation
I've long dreamed of writing my own Language Server in Rust. I'm not satisfied with the current state of PHP support in existing tools:

- **Intelephense** - powerful but feels heavy and opaque inside
- **PHPStorm** - popular but resource-intensive and costs money
- **Other LSPs** - often lack comprehensive PHP or WordPress support

I want something lightweight, understandable, and customizable to my needs.

### Saving money and time
- **Licenses**: No more paying $100-200/year for PhpStorm or $40-100/year for Intelephense
- **Speed**: Optimized for my workflow and specific projects
- **Control**: I can modify and improve it however I want
- **WordPress**: Full WordPress hooks support without extra fees

## What I'm using to build it

- **Rust** - fast and reliable programming language
- **async-lsp** - library for creating Language Servers
- **tree-sitter** - fast parser for PHP code
- **spec-kit-plus** - tool for specification-driven development
- **Zed Editor** - primary editor for testing

## What it can or will be able to do

### Core features
- **Error detection** - shows syntax errors and code issues
- **Auto-completion** - suggests function names, variables, classes
- **Navigation** - jump to function definitions, find usage
- **Hover info** - shows function information when you hover over it
- **Parameter hints** - suggests function parameters while typing

### PHP-specific features
- **PHP versions** - automatically detects which PHP version you're using from composer.json
- **PHPDoc** - reads and uses code comments for better suggestions
- **Extensions** - warns if you're using extensions not declared in composer.json
- **Frameworks** - special WordPress support (planning Laravel, Symfony)

### WordPress integration
- Auto-completion for hooks, actions, and filters
- Navigate from hook usage to its definition
- Suggestions for standard WordPress functions
- Recognition of custom hooks in your code

## My roadmap

### Phase 1: Foundation
- Basic LSP protocol support
- PHP code parsing
- Simple suggestions and error detection

### Phase 2: Core features
- Go-to-definition
- Hover information
- Document symbol list

### Phase 3: WordPress and frameworks
- Full WordPress hooks system support
- Cross-file navigation
- PHP version-specific features

### Phase 4: Advanced features
- Project-wide search
- Static analyzer integration
- Performance optimization

## Current status

**Early development** - The project is actively being developed. The LSP server isn't ready for use yet, but the architecture and foundation are being built.


# PHP LSP for Zed — Development Guide

Custom PHP Language Server Protocol implementation in Rust with WordPress hooks support.

## Quick Start

```bash
# 1. Створити директорію проекту
mkdir php-lsp && cd php-lsp

# 2. Завантажити і запустити setup
curl -O https://raw.githubusercontent.com/.../setup-php-lsp.sh
chmod +x setup-php-lsp.sh
./setup-php-lsp.sh

# 3. Почати розробку з Claude
claude
```

## Структура проекту

```
php-lsp/
├── crates/
│   ├── php-lsp/              # LSP server (Rust binary)
│   │   ├── src/
│   │   │   ├── main.rs       # Entry point (--stdio)
│   │   │   ├── lib.rs        # Library exports
│   │   │   └── server/       # Server implementation
│   │   └── Cargo.toml
│   └── zed-php-lsp/          # Zed extension (WASM)
│       ├── src/lib.rs
│       ├── extension.toml
│       └── Cargo.toml
├── .specify/                  # SDD specifications
│   ├── memory/
│   │   └── constitution.md   # Project principles
│   └── specs/
│       └── 001-xxx/          # Feature specs
│           ├── spec.md
│           ├── plan.md
│           └── tasks.md
├── .claude/commands/          # Claude slash commands
├── .qwen/commands/            # Qwen slash commands
├── .scripts/                  # Helper scripts
│   ├── add-dep.sh            # Add dependency + regen docs
│   ├── regen-docs.sh         # Regenerate documentation
│   ├── build-extension.sh    # Build Zed extension
│   └── install-lsp.sh        # Install LSP binary
├── target/
│   └── doc-md/               # Markdown docs for AI agents
├── prompts-claude.md          # Prompts for planning phase
├── prompts-qwen.md            # Prompts for implementation
└── Cargo.toml                # Workspace
```

## Development Workflow

### Dual-Agent Strategy

| Agent | Phase | Strengths |
|-------|-------|-----------|
| **Claude Code** | Planning | Better specifications, code quality |
| **Qwen Code** | Implementation | 256K+ context, free tier |

### Complete Workflow

```
┌────────────────────────────────────────────────────────────────┐
│                    ONE-TIME SETUP                              │
├────────────────────────────────────────────────────────────────┤
│  ./setup-php-lsp.sh                                            │
│  claude → /sp.constitution (paste from prompts-claude.md)     │
└───────────────────────────┬────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────────┐
│                 FOR EACH FEATURE (Phase 1, 2, 3...)            │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌─────────────── CLAUDE (Planning) ───────────────┐           │
│  │                                                 │           │
│  │  /sp.specify  ← paste Phase N prompt            │           │
│  │       ↓                                         │           │
│  │  /sp.clarify  (optional)                        │           │
│  │       ↓                                         │           │
│  │  /sp.plan                                       │           │
│  │       ↓                                         │           │
│  │  /sp.adr      (optional)                        │           │
│  │       ↓                                         │           │
│  │  /sp.tasks                                      │           │
│  │       ↓                                         │           │
│  │  /sp.analyze  (optional)                        │           │
│  │                                                 │           │
│  └─────────────────────┬───────────────────────────┘           │
│                        ↓                                       │
│  ┌─────────────── QWEN (Implementation) ───────────┐           │
│  │                                                 │           │
│  │  /sp.implement  ← with context from prompts     │           │
│  │       ↓                                         │           │
│  │  Loop: 20-30 lines → cargo check → fix → commit │           │
│  │       ↓                                         │           │
│  │  /sp.git.commit_pr                              │           │
│  │                                                 │           │
│  └─────────────────────┬───────────────────────────┘           │
│                        ↓                                       │
│                   Test & Merge                                 │
│                        ↓                                       │
│                   NEXT FEATURE                                 │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### Feature Phases

| Phase | Feature | Key Deliverables |
|-------|---------|------------------|
| 1 | Core Infrastructure | LSP lifecycle, document sync, PHP parsing |
| 2 | Symbol Navigation | Outline, go-to-definition, references, hover |
| 3 | Code Completion | Variables, members, classes, signature help |
| 4 | WordPress Hooks | Hook navigation, completion (18 functions) |
| 5 | Composer Integration | PHP version, autoload, vendor navigation |

## Key Commands

### spec-kit-plus Commands

| Command | Description |
|---------|-------------|
| `/sp.constitution` | Set project principles (once) |
| `/sp.specify` | Define feature requirements |
| `/sp.clarify` | AI asks clarifying questions |
| `/sp.plan` | Create technical plan |
| `/sp.adr` | Document architecture decisions |
| `/sp.tasks` | Generate task list |
| `/sp.analyze` | Check consistency |
| `/sp.implement` | Execute implementation |
| `/sp.git.commit_pr` | Commit and create PR |
| `/sp.phr` | Record conversation as PHR |

### Helper Scripts

```bash
# Add a new dependency (auto-regenerates docs)
.scripts/add-dep.sh tokio --features full

# Regenerate documentation for AI
.scripts/regen-docs.sh

# Build Zed extension
.scripts/build-extension.sh

# Install LSP binary to ~/.local/bin
.scripts/install-lsp.sh
```

## Critical Rules

### The Implementation Contract

```
For EVERY task:

1. ✅ Read docs from target/doc-md/
2. ✅ Write MAX 20-30 lines
3. ✅ Run: cargo check
4. ✅ If error → FIX IMMEDIATELY
5. ✅ Run: cargo check (must pass)
6. ✅ Run: git commit
7. ✅ Only then → next task
```

### Absolute Don'ts

- ❌ NEVER write 100+ lines without checking
- ❌ NEVER proceed with compilation errors
- ❌ NEVER invent APIs not in documentation
- ❌ NEVER skip commits between tasks
- ❌ NEVER say "errors exist but out of scope"

### Absolute Do's

- ✅ ALWAYS read docs before coding
- ✅ ALWAYS cargo check after changes
- ✅ ALWAYS fix errors immediately
- ✅ ALWAYS commit working code
- ✅ ALWAYS follow task order

## Documentation System

AI agents need accurate API documentation. We use `cargo-doc-md` to generate Markdown docs:

```bash
# Generate/update docs
.scripts/regen-docs.sh

# View index
cat target/doc-md/index.md

# View specific crate
cat target/doc-md/async_lsp/index.md
cat target/doc-md/tree_sitter/index.md
cat target/doc-md/lsp_types/index.md
```

**Before ANY implementation**: Read the relevant docs!

## Zed Integration

### Building the Extension

```bash
# Build WASM extension
.scripts/build-extension.sh

# Install in Zed
# 1. Open Zed
# 2. Command Palette → "zed: install dev extension"
# 3. Select: crates/zed-php-lsp/
```

### Installing the LSP

```bash
# Build and install binary
.scripts/install-lsp.sh

# Add to PATH (if not already)
export PATH="$HOME/.local/bin:$PATH"
```

### Zed Settings

```json
{
  "lsp": {
    "php-lsp": {
      "binary": {
        "path": "php-lsp",
        "arguments": ["--stdio"]
      }
    }
  },
  "languages": {
    "PHP": {
      "language_servers": ["php-lsp"]
    }
  }
}
```

## Troubleshooting

### Compilation Errors

```bash
# See the error
cargo check 2>&1 | head -50

# Fix ONE error at a time
# Run cargo check again
# Repeat until clean
```

### Missing Documentation

```bash
# Regenerate all docs
.scripts/regen-docs.sh

# Check if docs exist
ls -la target/doc-md/
```

### Git Issues

```bash
# Check status
git status
git branch

# Reset uncommitted changes
git checkout -- .

# Delete feature branch and restart
git checkout main
git branch -D feature/001-xxx
```

### Qwen Context Issues

If Qwen loses context:
1. Use the CONTINUATION PROMPT from prompts-qwen.md
2. Let it check git status and last commits
3. Resume from where it left off

## WordPress Hook Functions (Reference)

All 18 functions that need to be supported:

| Category | Functions |
|----------|-----------|
| Registration | `add_action`, `add_filter` |
| Invocation | `do_action`, `do_action_ref_array`, `apply_filters`, `apply_filters_ref_array` |
| Removal | `remove_action`, `remove_filter`, `remove_all_actions`, `remove_all_filters` |
| Inspection | `has_action`, `has_filter`, `did_action`, `did_filter`, `doing_action`, `doing_filter`, `current_action`, `current_filter` |

## Resources

- [async-lsp crate](https://crates.io/crates/async-lsp)
- [tree-sitter-php](https://github.com/tree-sitter/tree-sitter-php)
- [LSP Specification](https://microsoft.github.io/language-server-protocol/)
- [spec-kit-plus](https://github.com/panaversity/spec-kit-plus)
- [Zed Extension API](https://docs.zed.dev/extensions)
- [WordPress Plugin API](https://developer.wordpress.org/plugins/hooks/)

## License

MIT


## License

This project will be open source. License details will be added later.

---

*Built with ❤️ in Rust for the PHP community*
