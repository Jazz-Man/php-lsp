---
id: 0001
title: Core LSP Infrastructure Spec
stage: spec
date: 2025-12-02
surface: agent
model: claude-sonnet-4-5-20250929
feature: 001-core-lsp-infrastructure
branch: 001-core-lsp-infrastructure
user: vasilsokolik
command: /sp.specify
labels: ["spec", "lsp", "infrastructure", "lifecycle", "document-sync", "parsing"]
links:
  spec: specs/001-core-lsp-infrastructure/spec.md
  ticket: null
  adr: null
  pr: null
files:
  - specs/001-core-lsp-infrastructure/spec.md
  - specs/001-core-lsp-infrastructure/checklists/requirements.md
tests:
  - N/A (specification document)
---

## Prompt

```text
Feature: Core LSP Infrastructure

US-1: Initialize/shutdown lifecycle with ServerCapabilities
US-2: Track documents (didOpen/didChange/didClose) with incremental sync
US-3: Parse PHP via tree-sitter-php, cache AST per document

Requirements:
- stdio transport for Zed
- ropey for rope-based text
- Extract symbols: class, interface, trait, enum, function, method, property, constant
- PHP 8 syntax: attributes, named args, union types, match

NFR: init <500ms, change <50ms, memory ∝ open docs only

Acceptance:
- Server responds to initialize
- PHP 8 files parse without errors
- Integration test: init → open → change → close → shutdown
```

## Response snapshot

Created feature specification for Core LSP Infrastructure (001-core-lsp-infrastructure) with three prioritized user stories:

**US-1 (P1): Server Lifecycle Management** - Initialize/shutdown cycle with ServerCapabilities advertisement. Enables editor connection to LSP server. Acceptance: respond to initialize within 500ms, clean shutdown, protocol violation handling.

**US-2 (P2): Document Synchronization** - Track PHP documents via didOpen/didChange/didClose notifications with incremental sync and rope-based text representation. Acceptance: maintain document state accurately, apply incremental edits, handle version mismatches.

**US-3 (P3): PHP Parsing and Symbol Extraction** - Parse PHP 8 documents using tree-sitter-php, extract symbols (class, interface, trait, enum, function, method, property, constant), cache AST per document. Acceptance: parse PHP 8 syntax without errors, incremental reparse within 50ms, error recovery.

**Functional Requirements**: 15 testable requirements covering LSP message sequence, stdio transport, ServerCapabilities, document tracking, rope data structure, tree-sitter parsing, incremental parsing, symbol extraction, PHP 8 syntax support, performance targets.

**Edge Cases**: Document closed before parsing completes, malformed UTF-8, document change without didOpen, large files >10MB, tree-sitter parse failures, rapid successive edits.

**Success Criteria**: Measurable outcomes (500ms init, 50ms reparse, linear memory scaling, integration test success) and constitution compliance (async non-blocking, incremental parsing, reliability standards).

**Quality Validation**: All checklist items passed on first validation. No [NEEDS CLARIFICATION] markers. Specification ready for `/sp.plan`.

## Outcome

- ✅ Impact: Established comprehensive specification for foundational LSP server capabilities
- 🧪 Tests: N/A (specification document; integration test defined in acceptance criteria)
- 📁 Files: Created spec.md and requirements.md checklist in specs/001-core-lsp-infrastructure/
- 🔁 Next prompts: Run `/sp.plan` to create implementation plan with architecture decisions
- 🧠 Reflection: Specification successfully balances technical precision with business focus. Performance targets (500ms init, 50ms reparse) are measurable. Prioritized user stories enable incremental delivery (P1 = server lifecycle, P2 = document sync, P3 = parsing). Explicit constitution compliance mapping ensures quality standards.

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): Manual validation PASS (all checklist items passed, no implementation details leaked, requirements testable)
- Prompt variant (if applicable): N/A (initial spec)
- Next experiment (smallest change to try): Apply planning phase to validate spec completeness and architecture decisions
