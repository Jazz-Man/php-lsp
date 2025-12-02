<!--
Sync Impact Report
==================
Version change: [NEW] → 1.0.0 (Initial constitution ratification)
Modified principles: N/A (Initial creation)
Added sections:
  - Core Principles (I-VII)
  - Technology Stack Constraints
  - Quality Standards
  - Governance
Removed sections: N/A
Templates requiring updates:
  ✅ .specify/templates/plan-template.md - updated (constitution checks, tech context, project structure)
  ✅ .specify/templates/spec-template.md - updated (constitution compliance section added)
  ✅ .specify/templates/tasks-template.md - updated (required tests, Rust paths, quality standards)
Follow-up TODOs: None
-->

# PHP LSP Server Constitution

## Core Principles

### I. Async Non-Blocking Architecture

All LSP handlers MUST use async/await patterns and MUST NOT block the tokio runtime.
Long-running operations (parsing, indexing, file I/O) MUST yield control regularly.
Tower middleware layers MUST be composable and non-blocking.

**Rationale**: Language servers must remain responsive during large project operations.
Blocking operations freeze the editor and degrade user experience.

### II. PHP Version Detection and Compliance

Default PHP version is 8.0 or higher. The server MUST read `composer.json` to detect
the project's required PHP version from `require.php` or `config.platform.php`.
Code analysis and suggestions MUST respect the detected PHP version's features and syntax.

**Rationale**: Different PHP projects target different versions. Features like union types
(8.0+), enums (8.1+), and readonly properties vary by version.

### III. PHPDoc Parsing and Type Inference

The server MUST parse and honor PHPDoc annotations including:
- Standard tags: `@param`, `@return`, `@var`, `@throws`, `@property`
- Template/generic types: `@template`, `@extends`, `@implements`
- Static analysis extensions: Psalm and PHPStan annotations (`@psalm-*`, `@phpstan-*`)

Type information from PHPDoc MUST take precedence over inferred types when explicit.

**Rationale**: PHPDoc is the standard for documenting PHP types, especially generics
and complex types that native PHP syntax cannot express.

### IV. WordPress Hooks Integration

The server MUST provide go-to-definition support for WordPress hooks:
- `add_action()` → `do_action()` call sites
- `add_filter()` → `apply_filters()` call sites
- Custom hooks defined in project code

Hook discovery MUST work across file boundaries in the project workspace.

**Rationale**: WordPress development heavily relies on hooks. Navigation between
hook registration and invocation is essential for productivity.

### V. Incremental Parsing and Memory Efficiency

Use tree-sitter's incremental parsing for document edits. The server MUST NOT
reparse entire files on each keystroke. Index structures MUST be memory-efficient
and support partial updates.

Large projects (1000+ files) MUST remain usable on machines with 8GB RAM.

**Rationale**: Full reparse on every edit causes lag. Memory bloat makes the server
unusable on typical developer machines.

### VI. Extension Dependency Validation

When PHP code uses extension-specific functions (e.g., `json_encode`, `mysqli_connect`),
the server SHOULD warn if the corresponding `ext-*` dependency is missing from
`composer.json` `require` or `require-dev`.

**Rationale**: Missing extension declarations cause runtime failures in deployment.
Early detection prevents production issues.

### VII. Reliability and Observability

The server MUST NOT panic. All errors MUST be handled gracefully with Result/Option types.
Tracing logs MUST be emitted for all LSP requests/responses and significant operations.
All public APIs MUST have documentation comments explaining purpose, parameters, and behavior.

**Rationale**: Language servers run in user editors; crashes lose unsaved work and trust.
Observability enables debugging reported issues.

## Technology Stack Constraints

**Language**: Rust edition 2021 or 2024
**LSP Framework**: async-lsp 0.2.2 or compatible
**Parser**: tree-sitter-php 0.24.2 or compatible
**Runtime**: tokio (latest stable)
**Middleware**: tower (latest stable)

Dependency updates MUST maintain API compatibility or include migration guides.

## Quality Standards

### Testing
Every feature MUST have unit tests. Complex features (cross-file resolution,
incremental updates) MUST have integration tests. Test coverage target is 80%+.

### Error Handling
MUST use `Result<T, E>` for fallible operations. MUST use `Option<T>` for nullable
values. `unwrap()` and `expect()` are forbidden in production code paths
(test code may use them).

### Logging
MUST use the `tracing` crate for structured logging. Log levels:
- ERROR: unrecoverable failures affecting functionality
- WARN: recoverable issues (missing config, degraded features)
- INFO: significant lifecycle events (server start, project indexed)
- DEBUG: detailed operation traces (helpful for issue reports)
- TRACE: verbose internal state (disabled in release builds)

### Documentation
All public modules, structs, functions, and traits MUST have doc comments.
Complex algorithms MUST have inline comments explaining non-obvious logic.

## Governance

This constitution supersedes all other project practices and guidelines.

**Amendments** require:
1. Documented rationale for the change
2. Impact analysis on existing code and templates
3. Migration plan if breaking existing practices
4. Version bump (MAJOR for breaking changes, MINOR for additions, PATCH for clarifications)

**Compliance**: All pull requests MUST verify adherence to these principles.
Code reviews MUST check for async-blocking operations, panic paths, missing tests,
and undocumented APIs.

**Runtime Guidance**: Developers SHOULD consult `CLAUDE.md` for agent-specific
development workflows. When conflicts arise, this constitution takes precedence.

**Version**: 1.0.0 | **Ratified**: 2025-12-02 | **Last Amended**: 2025-12-02
