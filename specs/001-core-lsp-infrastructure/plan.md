# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/sp.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Rust 2021+ (Constitution mandates Rust edition 2021 or 2024)
**Primary Dependencies**: async-lsp 0.2.2, tree-sitter-php 0.24.2, tokio, tower
**Storage**: In-memory index structures (memory-efficient, incremental)
**Testing**: cargo test (unit + integration tests, 80%+ coverage target)
**Target Platform**: Cross-platform (Linux, macOS, Windows) as LSP server
**Project Type**: single (LSP server library + binary)
**Performance Goals**: Non-blocking async handlers, incremental parsing on edits
**Constraints**: <8GB RAM for 1000+ file projects, no blocking operations
**Scale/Scope**: Large PHP projects (1000+ files), WordPress codebases

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

<!-- Reference: .specify/memory/constitution.md -->

**Async Architecture (Principle I)**:
- [ ] All LSP handlers use async/await patterns
- [ ] No blocking operations on tokio runtime
- [ ] Tower middleware layers are composable and non-blocking

**PHP Version Compliance (Principle II)**:
- [ ] composer.json PHP version detection implemented
- [ ] Code analysis respects detected PHP version features

**PHPDoc Support (Principle III)**:
- [ ] Parser handles standard tags (@param, @return, @var, @throws, @property)
- [ ] Template/generic type support (@template, @extends, @implements)
- [ ] Psalm/PHPStan annotations supported

**WordPress Integration (Principle IV)**:
- [ ] (If applicable) Go-to-definition for WordPress hooks implemented
- [ ] Cross-file hook discovery working

**Incremental Parsing (Principle V)**:
- [ ] Tree-sitter incremental parsing used for edits
- [ ] Index structures support partial updates
- [ ] Memory usage tested with large projects (1000+ files)

**Extension Validation (Principle VI)**:
- [ ] Extension usage detection implemented
- [ ] Warning system for missing ext-* dependencies

**Reliability Standards (Principle VII)**:
- [ ] No panic paths in code
- [ ] Result/Option types used for error handling
- [ ] Tracing logs for LSP operations
- [ ] Public APIs documented
- [ ] Tests written per feature (unit + integration as needed)
- [ ] Test coverage target: 80%+

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/sp.plan command output)
├── research.md          # Phase 0 output (/sp.plan command)
├── data-model.md        # Phase 1 output (/sp.plan command)
├── quickstart.md        # Phase 1 output (/sp.plan command)
├── contracts/           # Phase 1 output (/sp.plan command)
└── tasks.md             # Phase 2 output (/sp.tasks command - NOT created by /sp.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# PHP LSP Server - Single Rust project structure
src/
├── lsp/           # LSP protocol handlers
├── parser/        # tree-sitter-php integration
├── analysis/      # Type inference, symbol resolution
├── index/         # Project indexing, symbol database
├── phpdoc/        # PHPDoc parsing
├── wordpress/     # WordPress hooks support
└── main.rs        # Binary entry point

tests/
├── integration/   # End-to-end LSP scenarios
└── unit/          # Module-level tests

Cargo.toml         # Dependencies: async-lsp, tree-sitter-php, tokio, tower
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
