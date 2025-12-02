---
id: 0002
title: Symbol Navigation Plan
stage: plan
date: 2025-12-02
surface: agent
model: claude-sonnet-4-5-20250929
feature: 002-symbol-navigation
branch: 002-symbol-navigation
user: vasilsokolik
command: /sp.plan
labels: ["plan", "architecture", "symbol-navigation", "indexing", "phpdoc", "composer"]
links:
  spec: specs/002-symbol-navigation/spec.md
  ticket: null
  adr: null
  pr: null
files:
  - specs/002-symbol-navigation/plan.md
  - specs/002-symbol-navigation/research.md
  - specs/002-symbol-navigation/data-model.md
  - specs/002-symbol-navigation/quickstart.md
tests:
  - N/A (planning artifacts)
---

## Prompt

```text
Stack:
- async-lsp 0.2 (tokio, stdio, tracing, omni-trait features)
- lsp-types 0.97
- tree-sitter 0.25, tree-sitter-php 0.24
- ropey 1.x, dashmap 6, thiserror 2, tracing 0.1

Architecture:
src/
├── main.rs (stdio entry)
├── server/ (state, capabilities, handlers/)
├── parser/ (tree-sitter wrapper, Document with rope+AST)
├── symbols/ (extractor, index)
├── completion/ (context, providers)
├── wordpress/ (hooks registry, stubs)
└── composer/ (parser, autoload resolver)

Patterns:
- Router builder for request/notification routing
- Middleware: Lifecycle → Concurrency → Tracing → Router
- ServerState: documents DashMap<Url, Document>, config
- Document: { content: Rope, tree: Option<Tree>, version: i32 }

Implement incrementally by phase.
```

## Response snapshot

Created comprehensive implementation plan for Symbol Navigation feature (002-symbol-navigation) with complete architecture and design decisions:

**Technical Context**: Rust 2021+, async-lsp 0.2, tree-sitter 0.25, ropey, DashMap for concurrent index access, nucleo-matcher for fuzzy search, serde for composer.json parsing. Performance targets: <100ms document symbols, <500ms workspace search for 1000 files, <3s find-references, <30s background indexing.

**Constitution Check**: ✅ PASSED - All applicable principles satisfied (async non-blocking, PHPDoc support, incremental parsing, reliability). WordPress hooks and extension validation out of scope for this feature.

**Architecture Decision - Phase 0 Research** (research.md):
1. **Fuzzy Matching**: nucleo-matcher (LSP-optimized, SIMD performance, battle-tested in Helix)
2. **PHPDoc Parsing**: Manual regex-based (robust to malformed input, fast <10ms, graceful error recovery)
3. **Symbol Index**: DashMap<String, Vec<SymbolInfo>> (concurrent access, O(1) lookup, incremental updates)
4. **Composer Autoload**: PSR-4 first (covers 95%+ use cases, simple file path computation)
5. **Background Indexing**: tokio::spawn + Arc (non-blocking, partial results available, simple cancellation)

**Data Model - Phase 1 Design** (data-model.md):
- **Symbol**: name, kind, range, visibility, parent hierarchy, detail, uri, container (200 bytes/symbol)
- **SymbolIndex**: by_file and by_name DashMap indexes, concurrent access, ~15-20MB for 1000-file workspace
- **PHPDocBlock**: description, params, return, deprecated, templates, Psalm/PHPStan tags with regex parsing
- **ComposerAutoload**: PSR-4 mapping with cached resolution, supports namespace→file path lookup
- **DefinitionLocation/ReferenceLocation**: file URI + range for navigation

**Module Structure**:
- `symbols/` (extractor, index, indexer, search, resolver)
- `phpdoc/` (parser, tags, markdown renderer)
- `composer/` (parser, autoload resolver, cache)
- New LSP handlers: document_symbol, workspace_symbol, definition, references, hover

**Testing Strategy** (quickstart.md):
- Manual testing scenarios for all 5 user stories
- Performance testing with 1000-file workspace
- Verification checklists for each feature
- Troubleshooting guide with log patterns

**Key Technical Challenges**:
1. Fuzzy search performance (nucleo-matcher solves with SIMD)
2. Background indexing coordination (tokio::spawn + DashMap enables partial reads)
3. PHPDoc robustness (regex + graceful error recovery handles malformed docs)
4. Composer PSR-4 resolution (cache + longest-prefix matching)
5. Memory efficiency (lightweight SymbolInfo refs, incremental updates)

**Estimated Complexity**: ~95 tasks across 11 task groups (setup, extraction, indexing, 5 LSP handlers, PHPDoc, composer, integration)

## Outcome

- ✅ Impact: Established complete architecture and design for symbol navigation with proven technology choices
- 🧪 Tests: Testing strategy defined in quickstart.md; unit tests for each module, integration tests for LSP requests
- 📁 Files: Created plan.md, research.md, data-model.md, quickstart.md in specs/002-symbol-navigation/
- 🔁 Next prompts: Run `/sp.tasks` to generate detailed task breakdown (~95 tasks); consider ADR for indexing strategy
- 🧠 Reflection: Planning resolved all technical unknowns with research-backed decisions. Architecture balances performance (DashMap, nucleo-matcher) with simplicity (regex PHPDoc, PSR-4 only). Memory estimates (~20MB for 1000 files) well under constitution limit (8GB). Background indexing design ensures non-blocking LSP operations. Ready for task generation and implementation.

## Evaluation notes (flywheel)

- Failure modes observed: None (all technical unknowns resolved in research phase)
- Graders run and results (PASS/FAIL): Manual validation PASS (constitution check passed, all dependencies justified, performance targets realistic)
- Prompt variant (if applicable): N/A (initial plan)
- Next experiment (smallest change to try): Prototype nucleo-matcher integration to validate fuzzy search performance before full implementation
