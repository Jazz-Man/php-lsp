---
id: 1
title: Update PHP LSP Constitution
stage: constitution
date_iso: 2025-12-02
surface: agent
model: Qwen
feature: none
branch: main
user: vasilsokolik
command: /sp.constitution PHP LSP server in Rust using async-lsp crate.
labels: ["constitution", "php", "lsp", "rust"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files_yaml:
  - ".specify/memory/constitution.md"
tests_yaml: []
---

# Constitution Update for PHP LSP Server

## Original Prompt
```
$ARGUMENTS
```

## User Input Summary
User requested to create or update the project constitution for a PHP LSP server in Rust using async-lsp crate.

Stack: Rust 2024, async-lsp 0.2.2, tree-sitter-php 0.24.2, tokio, tower middleware.

Principles:
- Async non-blocking handlers
- PHP 8+ default, version from composer.json
- PHPDoc parsing (@param, @return, @var, @template, psalm/phpstan annotations)
- WordPress hooks: add_action/add_filter/do_action/apply_filters go-to-definition
- Incremental parsing, memory-efficient
- Extension warnings when ext-* not in composer.json

Quality: tests per feature, no panics, tracing logs, documented APIs.

## Response Summary
The project constitution has been successfully updated with:
- 6 core principles as specified by the user
- Stack requirements section detailing the technology stack
- Quality standards section with testing and documentation requirements
- Governance section with versioning and amendment procedures
- Sync impact report included in the file

The constitution now reflects the specific requirements for the PHP LSP server project, focusing on async handlers, PHP version detection, PHPDoc parsing, WordPress integration, memory efficiency, and extension warnings.

## Outcome
The constitution file `.specify/memory/constitution.md` has been updated with all the specified principles and requirements, following the template structure while incorporating the project-specific details provided by the user.