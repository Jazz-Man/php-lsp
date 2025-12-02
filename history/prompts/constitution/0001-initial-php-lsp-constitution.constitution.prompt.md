---
id: 0001
title: Initial PHP LSP Constitution
stage: constitution
date: 2025-12-02
surface: agent
model: claude-sonnet-4-5-20250929
feature: none
branch: master
user: vasilsokolik
command: /sp.constitution
labels: ["constitution", "principles", "rust", "async-lsp", "php", "wordpress"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
  - .specify/memory/constitution.md
  - .specify/templates/plan-template.md
  - .specify/templates/spec-template.md
  - .specify/templates/tasks-template.md
tests:
  - N/A (constitution document)
---

## Prompt

```text
PHP LSP server in Rust using async-lsp crate.

Stack: Rust 2024, async-lsp 0.2.2, tree-sitter-php 0.24.2, tokio, tower middleware.

Principles:
- Async non-blocking handlers
- PHP 8+ default, version from composer.json
- PHPDoc parsing (@param, @return, @var, @template, psalm/phpstan annotations)
- WordPress hooks: add_action/add_filter/do_action/apply_filters go-to-definition
- Incremental parsing, memory-efficient
- Extension warnings when ext-* not in composer.json

Quality: tests per feature, no panics, tracing logs, documented APIs.
```

## Response snapshot

Created PHP LSP Server Constitution v1.0.0 with seven core principles:

**I. Async Non-Blocking Architecture**: All LSP handlers MUST use async/await, no blocking operations on tokio runtime, tower middleware composable and non-blocking.

**II. PHP Version Detection**: Default PHP 8.0+, detect version from composer.json, respect version-specific features.

**III. PHPDoc Parsing**: Parse standard tags (@param, @return, @var, @throws), template types (@template, @extends), and Psalm/PHPStan annotations.

**IV. WordPress Hooks Integration**: Go-to-definition for add_action/add_filter → do_action/apply_filters, cross-file discovery.

**V. Incremental Parsing**: Use tree-sitter incremental parsing, memory-efficient indexes, <8GB RAM for 1000+ files.

**VI. Extension Validation**: Warn when extension functions used but ext-* missing from composer.json.

**VII. Reliability and Observability**: No panics, Result/Option error handling, tracing logs, documented APIs, 80%+ test coverage.

**Technology Stack**: Rust 2021+, async-lsp 0.2.2, tree-sitter-php 0.24.2, tokio, tower.

**Templates Updated**:
- plan-template.md: Added constitution checks, Rust-specific tech context, LSP project structure
- spec-template.md: Added constitution compliance section
- tasks-template.md: Changed tests from optional to required, updated paths to .rs files, added quality gates

## Outcome

- ✅ Impact: Established foundational governance for PHP LSP server development with seven actionable principles
- 🧪 Tests: N/A (constitution is governance document)
- 📁 Files: Created constitution.md, updated 3 template files for consistency
- 🔁 Next prompts: Feature specifications can now reference constitution principles; /sp.plan will enforce constitution checks
- 🧠 Reflection: Constitution provides clear quality standards (no panics, tests required, async-first) and technical constraints (Rust stack, memory limits) that will guide all future development

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): Manual validation PASS (no placeholder tokens remain, templates aligned)
- Prompt variant (if applicable): N/A (initial constitution)
- Next experiment (smallest change to try): Apply constitution checks to first feature specification to validate template integration
