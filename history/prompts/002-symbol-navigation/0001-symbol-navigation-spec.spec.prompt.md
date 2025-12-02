---
id: 0001
title: Symbol Navigation Spec
stage: spec
date: 2025-12-02
surface: agent
model: claude-sonnet-4-5-20250929
feature: 002-symbol-navigation
branch: 002-symbol-navigation
user: vasilsokolik
command: /sp.specify
labels: ["spec", "symbol-navigation", "document-symbols", "workspace-symbols", "go-to-definition", "find-references", "hover", "phpdoc"]
links:
  spec: specs/002-symbol-navigation/spec.md
  ticket: null
  adr: null
  pr: null
files:
  - specs/002-symbol-navigation/spec.md
  - specs/002-symbol-navigation/checklists/requirements.md
tests:
  - N/A (specification document)
---

## Prompt

```text
Feature: Symbol Navigation

US-1: Document symbols (outline) - hierarchical with visibility
US-2: Workspace symbols - index all PHP, fuzzy search, background indexing
US-3: Go-to-definition - functions, methods, classes, use statements, composer autoload
US-4: Find references - across workspace
US-5: Hover - signature + PHPDoc as markdown

PHPDoc: @param, @return, @var, @deprecated, @template, @psalm-*, @phpstan-*

Acceptance:
- Outline shows nested class members
- Ctrl+Click resolves correctly
- Hover displays PHPDoc
- References found cross-file
```

## Response snapshot

Created comprehensive specification for Symbol Navigation (002-symbol-navigation) with five prioritized user stories covering complete navigation and documentation capabilities:

**US-1 (P1): Document Symbol Outline** - Hierarchical outline of symbols in current file with visibility indicators (public/private/protected). Enables quick file structure understanding and navigation. Acceptance: nested class members, proper hierarchy (namespace → class → methods → properties), file-level functions.

**US-2 (P2): Workspace-Wide Symbol Search** - Index all PHP files with background indexing, fuzzy search with relevance ranking. Enables project-wide navigation. Acceptance: 100+ file indexing, fuzzy matching ("usrctrl" → "UserController"), incremental index updates, configurable vendor exclusion.

**US-3 (P3): Go-to-Definition Navigation** - Ctrl+Click navigation to function/class/method definitions with use statement resolution and composer autoload integration. Acceptance: cross-file resolution, use statement aliases, PSR-4 autoload mapping, graceful handling of missing definitions.

**US-4 (P4): Find All References** - Locate all usage sites of symbols across workspace for safe refactoring. Acceptance: definition + usage locations, correct symbol disambiguation (same-name methods in different classes), scoped variable handling, 3-second response time.

**US-5 (P5): Hover Information with PHPDoc** - Display signature + parsed PHPDoc documentation as markdown. Supports @param, @return, @var, @deprecated, @template, @psalm-*, @phpstan-*. Acceptance: formatted markdown, prominent deprecation notices, template types, fallback to PHP type hints when PHPDoc absent.

**Functional Requirements**: 30 testable requirements organized by user story, covering LSP message implementations, hierarchical symbol extraction, fuzzy search algorithms, name resolution, composer autoload integration, PHPDoc parsing with extended annotations.

**Edge Cases**: Symbol name collisions, partial indexing, syntax errors during hover, generated files in find-references, missing/invalid composer.json, large workspaces (10k+ files), malformed PHPDoc markdown.

**Success Criteria**: Measurable performance targets (100ms outline, 500ms search for 1000 files, 95%+ go-to-definition accuracy, 3s find-references, 100ms hover, 30s background indexing for 1000 files) and constitution compliance (async non-blocking, incremental parsing, PHPDoc support, reliability standards).

**Quality Validation**: All checklist items passed. No [NEEDS CLARIFICATION] markers. Clear prioritization enables incremental delivery (P1+P2 as MVP baseline, P3-P5 as enhancements).

## Outcome

- ✅ Impact: Established specification for complete LSP symbol navigation capabilities including advanced features like fuzzy search and PHPDoc rendering
- 🧪 Tests: N/A (specification document; integration tests defined in acceptance criteria for each user story)
- 📁 Files: Created spec.md and requirements.md checklist in specs/002-symbol-navigation/
- 🔁 Next prompts: Run `/sp.plan` to design indexing architecture and symbol resolution strategy; consider ADR for in-memory vs persistent indexing
- 🧠 Reflection: Specification balances comprehensive feature coverage with realistic prioritization. Five user stories enable flexible delivery: P1+P2 provide baseline navigation, P3 adds definition jumping, P4 enables refactoring, P5 enhances documentation. PHPDoc scope includes Psalm/PHPStan for real-world PHP project compatibility. Performance targets are ambitious but achievable (30s indexing for 1000 files, 500ms fuzzy search).

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): Manual validation PASS (all checklist items passed, comprehensive edge cases, clear scope boundaries)
- Prompt variant (if applicable): N/A (initial spec)
- Next experiment (smallest change to try): Planning phase will validate architectural decisions for workspace indexing (in-memory data structures, incremental update strategy, fuzzy matching algorithm)
