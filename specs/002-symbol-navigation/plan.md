# Implementation Plan: Symbol Navigation

**Branch**: `002-symbol-navigation` | **Date**: 2025-12-02 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/002-symbol-navigation/spec.md`

## Summary

Implement comprehensive symbol navigation capabilities for the PHP LSP server including document symbols (outline), workspace-wide symbol search with fuzzy matching, go-to-definition with composer autoload resolution, find-references across workspace, and hover information with PHPDoc rendering. This builds on core LSP infrastructure (001) by adding symbol extraction, indexing, and cross-file resolution capabilities.

**Technical Approach**: Use tree-sitter AST traversal to extract symbols, maintain an in-memory symbol index with DashMap for concurrent access, implement fuzzy search with relevance ranking, parse composer.json for PSR-4 autoload mapping, implement PHPDoc parser with markdown rendering, and ensure all operations are async/non-blocking.

## Technical Context

**Language/Version**: Rust 2021+ (Constitution mandates Rust edition 2021 or 2024)

**Primary Dependencies**:
- async-lsp 0.2 (tokio, stdio, tracing, omni-trait features)
- lsp-types 0.97 (LSP protocol types)
- tree-sitter 0.25, tree-sitter-php 0.24 (parsing)
- ropey 1.x (rope-based text)
- dashmap 6 (concurrent hash map for indexes)
- thiserror 2 (error handling)
- tracing 0.1 (observability)
- serde_json, serde (composer.json parsing)
- fuzzy-matcher or similar (fuzzy string matching)

**Storage**: In-memory symbol index (DashMap<SymbolName, Vec<SymbolInfo>>), in-memory composer autoload cache, document AST cache from core infrastructure

**Testing**: cargo test (unit tests for symbol extraction, fuzzy matching, name resolution; integration tests for LSP requests; 80%+ coverage target)

**Target Platform**: Cross-platform (Linux, macOS, Windows) as LSP server

**Project Type**: Single Rust project (LSP server library + binary)

**Performance Goals**:
- Document symbols: <100ms response
- Workspace symbol search: <500ms for 1000 files
- Go-to-definition: <200ms resolution
- Find-references: <3 seconds for large workspaces
- Hover: <100ms response
- Background indexing: <30 seconds for 1000 files

**Constraints**:
- <8GB RAM for 1000+ file projects
- No blocking operations (all handlers async)
- Incremental index updates (no full re-indexing on file change)
- Background indexing must not block LSP message handling

**Scale/Scope**: Large PHP projects (1000+ files), WordPress codebases, composer projects with PSR-4 autoload

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

<!-- Reference: .specify/memory/constitution.md -->

**Async Architecture (Principle I)**:
- [x] All LSP handlers use async/await patterns (document symbols, workspace symbols, go-to-definition, references, hover)
- [x] No blocking operations on tokio runtime (background indexing uses tokio::spawn)
- [x] Tower middleware layers are composable and non-blocking (reuses core infrastructure middleware)

**PHP Version Compliance (Principle II)**:
- [~] composer.json PHP version detection implemented (core infrastructure feature, not in scope for this feature)
- [x] Code analysis respects detected PHP version features (symbol extraction works with PHP 8+ syntax from core parser)

**PHPDoc Support (Principle III)**:
- [x] Parser handles standard tags (@param, @return, @var, @throws, @property)
- [x] Template/generic type support (@template, @extends, @implements)
- [x] Psalm/PHPStan annotations supported (@psalm-*, @phpstan-*)

**WordPress Integration (Principle IV)**:
- [~] Go-to-definition for WordPress hooks implemented (separate feature, not in scope)
- [~] Cross-file hook discovery working (separate feature, not in scope)

**Incremental Parsing (Principle V)**:
- [x] Tree-sitter incremental parsing used for edits (reuses core infrastructure Document with cached AST)
- [x] Index structures support partial updates (symbol index updates on file change, not full rebuild)
- [x] Memory usage tested with large projects (1000+ files) (performance testing in integration tests)

**Extension Validation (Principle VI)**:
- [~] Extension usage detection implemented (not in scope for this feature)
- [~] Warning system for missing ext-* dependencies (not in scope for this feature)

**Reliability Standards (Principle VII)**:
- [x] No panic paths in code (all unwrap/expect replaced with Result/Option)
- [x] Result/Option types used for error handling (SymbolError, ResolutionError types)
- [x] Tracing logs for LSP operations (symbol extraction, indexing progress, search queries, resolution attempts)
- [x] Public APIs documented (symbol extractor, index, resolver, PHPDoc parser with doc comments)
- [x] Tests written per feature (unit + integration tests per user story)
- [x] Test coverage target: 80%+

**Gate Status**: ✅ PASSED - All applicable principles satisfied. WordPress and extension validation are out of scope. PHP version detection is core infrastructure (reused here).

## Project Structure

### Documentation (this feature)

```text
specs/002-symbol-navigation/
├── spec.md              # Feature specification
├── plan.md              # This file (/sp.plan command output)
├── research.md          # Phase 0 output (fuzzy matching, PHPDoc parsing, indexing strategies)
├── data-model.md        # Phase 1 output (Symbol, SymbolIndex, PHPDocBlock entities)
├── quickstart.md        # Phase 1 output (how to test symbol navigation features)
├── contracts/           # Phase 1 output (LSP request/response examples)
│   ├── document_symbol.json
│   ├── workspace_symbol.json
│   ├── definition.json
│   ├── references.json
│   └── hover.json
└── tasks.md             # Phase 2 output (/sp.tasks command - NOT created by /sp.plan)
```

### Source Code (repository root)

```text
# PHP LSP Server - Extended structure for symbol navigation
src/
├── main.rs                      # stdio entry point
├── server/
│   ├── mod.rs
│   ├── state.rs                 # ServerState: documents DashMap, symbol_index, composer_resolver
│   ├── capabilities.rs          # ServerCapabilities: add documentSymbol, workspaceSymbol, definition, references, hover
│   └── handlers/
│       ├── mod.rs
│       ├── lifecycle.rs         # initialize, shutdown (from core infra)
│       ├── text_sync.rs         # didOpen, didChange, didClose (from core infra)
│       ├── document_symbol.rs   # NEW: textDocument/documentSymbol handler
│       ├── workspace_symbol.rs  # NEW: workspace/symbol handler
│       ├── definition.rs        # NEW: textDocument/definition handler
│       ├── references.rs        # NEW: textDocument/references handler
│       └── hover.rs             # NEW: textDocument/hover handler
├── parser/
│   ├── mod.rs
│   ├── document.rs              # Document { content: Rope, tree: Option<Tree>, version }
│   └── tree_sitter_wrapper.rs
├── symbols/                     # NEW MODULE
│   ├── mod.rs
│   ├── extractor.rs             # Extract symbols from tree-sitter AST
│   ├── symbol.rs                # Symbol struct (name, kind, range, visibility, parent)
│   ├── index.rs                 # SymbolIndex (DashMap-based workspace symbol index)
│   ├── indexer.rs               # Background indexing task
│   ├── search.rs                # Fuzzy search with relevance ranking
│   └── resolver.rs              # Symbol resolution (name → definition location)
├── phpdoc/                      # NEW MODULE
│   ├── mod.rs
│   ├── parser.rs                # Parse PHPDoc comments from source
│   ├── tags.rs                  # PHPDoc tag types (@param, @return, @template, etc.)
│   └── markdown.rs              # Render PHPDoc as markdown for hover
├── composer/                    # NEW MODULE
│   ├── mod.rs
│   ├── parser.rs                # Parse composer.json
│   ├── autoload.rs              # Autoload resolver (PSR-4, PSR-0, classmap)
│   └── cache.rs                 # Cache autoload mappings
└── wordpress/                   # (Out of scope for this feature)

tests/
├── integration/
│   ├── document_symbol_test.rs  # NEW
│   ├── workspace_symbol_test.rs # NEW
│   ├── definition_test.rs       # NEW
│   ├── references_test.rs       # NEW
│   └── hover_test.rs            # NEW
└── unit/
    ├── symbol_extractor_test.rs # NEW
    ├── fuzzy_search_test.rs     # NEW
    ├── phpdoc_parser_test.rs    # NEW
    └── composer_autoload_test.rs # NEW

Cargo.toml                        # Dependencies: async-lsp, lsp-types, tree-sitter, ropey, dashmap, etc.
```

**Structure Decision**: Single Rust project with modular structure. New modules (`symbols/`, `phpdoc/`, `composer/`) extend core infrastructure. Symbol extraction and indexing are separate concerns. PHPDoc parsing is isolated for maintainability. Composer autoload resolution is its own module for PSR-4 logic.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations. All complexity is necessary and justified:
- **Background indexing**: Required for <500ms workspace symbol search (Principle V: memory efficiency)
- **DashMap**: Required for concurrent index access without blocking (Principle I: async non-blocking)
- **Fuzzy matching**: Required per spec (US-2 acceptance scenario 2)
- **Composer parser**: Required for PSR-4 autoload resolution (US-3 acceptance scenario 4)
- **PHPDoc parser**: Required per spec (US-5, Constitution Principle III)

---

## Phase 0: Research

**Purpose**: Resolve unknowns and validate technology choices

### Research Tasks

1. **Fuzzy String Matching Libraries**
   - **Question**: Which Rust fuzzy matching library best balances performance and quality?
   - **Options**: fuzzy-matcher, sublime_fuzzy, nucleo-matcher, custom Levenshtein
   - **Criteria**: Support for prefix/substring/fuzzy modes, relevance scoring, performance (<10ms for 10k symbols)

2. **PHPDoc Parsing Strategy**
   - **Question**: Should we use regex, pest grammar, or manual parsing for PHPDoc?
   - **Concerns**: Robustness to malformed input, performance, maintainability
   - **Requirements**: Extract @param, @return, @var, @deprecated, @template, @psalm-*, @phpstan-*

3. **Symbol Index Data Structure**
   - **Question**: What's the optimal index structure for fast lookup + fuzzy search?
   - **Options**: HashMap<String, Vec<Symbol>>, Trie, inverted index
   - **Trade-offs**: Memory usage vs search speed, incremental update complexity

4. **Composer Autoload Resolution**
   - **Question**: How to efficiently map FQN to file path for PSR-4?
   - **Concerns**: Handling multiple autoload sections, composer.lock vs composer.json, caching strategy
   - **Requirements**: Support PSR-4, PSR-0, classmap

5. **Background Indexing Coordination**
   - **Question**: How to coordinate background indexing with LSP request handling?
   - **Options**: tokio::spawn with Arc<RwLock>, separate thread with message passing, async streams
   - **Concerns**: Blocking writes, partial index visibility, cancellation on shutdown

**Output**: `research.md` with decisions, rationale, and code examples

---

## Phase 1: Design

**Purpose**: Define data models, API contracts, and integration points

### Data Model (`data-model.md`)

**Core Entities**:

1. **Symbol**
   ```
   - id: SymbolId (unique identifier)
   - name: String (symbol name)
   - kind: SymbolKind (class, function, method, property, constant, etc.)
   - range: Range (full span in source)
   - selection_range: Range (identifier span)
   - visibility: Option<Visibility> (public, private, protected)
   - parent: Option<SymbolId> (for hierarchy)
   - detail: Option<String> (signature, type hint)
   - uri: Url (file location)
   ```

2. **SymbolIndex**
   ```
   - symbols: DashMap<Url, Vec<Symbol>> (symbols per file)
   - name_index: DashMap<String, Vec<SymbolId>> (name → symbol lookup)
   - indexing_status: IndexingStatus (NotStarted, InProgress, Complete)
   ```

3. **PHPDocBlock**
   ```
   - description: Option<String>
   - params: Vec<ParamTag> (name, type, description)
   - return_type: Option<ReturnTag>
   - var_type: Option<VarTag>
   - deprecated: Option<DeprecatedTag>
   - templates: Vec<TemplateTag>
   - psalm_tags: Vec<PsalmTag>
   - phpstan_tags: Vec<PHPStanTag>
   ```

4. **ComposerAutoload**
   ```
   - psr4: HashMap<String, Vec<PathBuf>> (namespace → dirs)
   - psr0: HashMap<String, Vec<PathBuf>>
   - classmap: Vec<PathBuf>
   - files: Vec<PathBuf>
   ```

5. **DefinitionLocation**
   ```
   - uri: Url
   - range: Range
   ```

**Relationships**:
- Symbol → SymbolIndex: Many-to-one (index contains many symbols)
- Symbol → PHPDocBlock: One-to-optional-one (symbol may have docs)
- Symbol → DefinitionLocation: Resolved via name and SymbolIndex

**State Transitions**:
- IndexingStatus: NotStarted → InProgress → Complete → InProgress (on file change)

### API Contracts (`contracts/`)

**textDocument/documentSymbol**
```json
// Request
{
  "textDocument": { "uri": "file:///path/to/file.php" }
}

// Response
[
  {
    "name": "MyClass",
    "kind": 5,  // Class
    "range": { "start": { "line": 10, "character": 0 }, "end": { "line": 50, "character": 1 } },
    "selectionRange": { "start": { "line": 10, "character": 6 }, "end": { "line": 10, "character": 13 } },
    "children": [
      {
        "name": "myMethod",
        "kind": 6,  // Method
        "range": { "start": { "line": 15, "character": 4 }, "end": { "line": 20, "character": 5 } },
        "selectionRange": { "start": { "line": 15, "character": 16 }, "end": { "line": 15, "character": 24 } },
        "detail": "public function myMethod(string $param): bool"
      }
    ]
  }
]
```

**workspace/symbol**
```json
// Request
{
  "query": "usrctrl"
}

// Response
[
  {
    "name": "UserController",
    "kind": 5,
    "location": {
      "uri": "file:///src/Controllers/UserController.php",
      "range": { "start": { "line": 5, "character": 0 }, "end": { "line": 100, "character": 1 } }
    },
    "containerName": "App\\Controllers"
  }
]
```

**textDocument/definition**
```json
// Request
{
  "textDocument": { "uri": "file:///path/to/file.php" },
  "position": { "line": 25, "character": 10 }
}

// Response
{
  "uri": "file:///src/Services/UserService.php",
  "range": { "start": { "line": 15, "character": 0 }, "end": { "line": 15, "character": 30 } }
}
```

**textDocument/references**
```json
// Request
{
  "textDocument": { "uri": "file:///path/to/file.php" },
  "position": { "line": 15, "character": 20 },
  "context": { "includeDeclaration": true }
}

// Response
[
  {
    "uri": "file:///src/Services/UserService.php",
    "range": { "start": { "line": 15, "character": 16 }, "end": { "line": 15, "character": 26 } }
  },
  {
    "uri": "file:///src/Controllers/UserController.php",
    "range": { "start": { "line": 30, "character": 8 }, "end": { "line": 30, "character": 18 } }
  }
]
```

**textDocument/hover**
```json
// Request
{
  "textDocument": { "uri": "file:///path/to/file.php" },
  "position": { "line": 25, "character": 10 }
}

// Response
{
  "contents": {
    "kind": "markdown",
    "value": "```php\npublic function getUserById(int $id): ?User\n```\n\n---\n\nRetrieve a user by their unique identifier.\n\n**Parameters:**\n- `$id` (int): The user ID\n\n**Returns:** `?User` - The user object or null if not found\n\n**Deprecated:** Use `findUser($id)` instead"
  },
  "range": { "start": { "line": 25, "character": 8 }, "end": { "line": 25, "character": 19 } }
}
```

### Quickstart (`quickstart.md`)

**Purpose**: Manual testing guide for developers

**Steps**:
1. Start LSP server: `cargo run`
2. Connect editor (e.g., Zed) via stdio
3. Open workspace with PHP files
4. Wait for background indexing to complete (check logs)
5. Test document symbols: open file, request outline
6. Test workspace symbols: search for known class name with fuzzy query
7. Test go-to-definition: Ctrl+Click on class reference
8. Test find-references: trigger on function definition
9. Test hover: hover over method call with PHPDoc

**Expected Results**: All requests return within performance targets, results are accurate

---

## Phase 2: Tasks

**NOTE**: Tasks are generated by `/sp.tasks` command (separate from this planning phase)

**High-Level Task Groups** (for reference):

1. **Setup & Dependencies** (T001-T005)
   - Add dependencies to Cargo.toml
   - Create module structure (symbols/, phpdoc/, composer/)
   - Update ServerCapabilities to advertise new features

2. **Symbol Extraction** (T006-T015)
   - Implement symbol extractor from tree-sitter AST
   - Handle all PHP symbol kinds (class, interface, trait, enum, function, method, property, constant)
   - Extract visibility, hierarchy, signature
   - Unit tests for symbol extraction

3. **Symbol Indexing** (T016-T025)
   - Implement SymbolIndex with DashMap
   - Background indexing task (tokio::spawn)
   - Incremental index updates on file change
   - Fuzzy search implementation
   - Unit tests for indexing and search

4. **Document Symbols Handler** (T026-T030)
   - Implement textDocument/documentSymbol handler
   - Build hierarchical symbol tree
   - Integration test for document symbols

5. **Workspace Symbols Handler** (T031-T035)
   - Implement workspace/symbol handler
   - Fuzzy search integration
   - Result ranking
   - Integration test for workspace symbols

6. **Composer Autoload** (T036-T045)
   - Parse composer.json
   - Implement PSR-4 resolver
   - Implement PSR-0 resolver (optional)
   - Implement classmap resolver
   - Cache autoload mappings
   - Unit tests for composer parsing and resolution

7. **Go-to-Definition Handler** (T046-T055)
   - Implement textDocument/definition handler
   - Symbol name resolution (use statements, FQN)
   - Composer autoload integration
   - Integration test for go-to-definition

8. **Find References Handler** (T056-T065)
   - Implement textDocument/references handler
   - Workspace-wide symbol search
   - Scope-aware matching
   - Integration test for find-references

9. **PHPDoc Parser** (T066-T075)
   - Implement PHPDoc parser (regex or pest)
   - Extract standard tags (@param, @return, @var, @deprecated)
   - Extract template tags (@template, @extends, @implements)
   - Extract Psalm/PHPStan tags
   - Unit tests for PHPDoc parsing

10. **Hover Handler** (T076-T085)
    - Implement textDocument/hover handler
    - Build markdown from signature + PHPDoc
    - Integration test for hover

11. **Integration & Polish** (T086-T095)
    - End-to-end tests for all user stories
    - Performance testing (1000-file workspace)
    - Memory profiling
    - Error handling and edge cases
    - Documentation updates

**Estimated Task Count**: ~95 tasks

---

## Dependencies & Execution Order

### Prerequisites
- **Core LSP Infrastructure (001)** must be complete:
  - ServerState with documents DashMap
  - Document with rope + AST caching
  - Lifecycle handlers (initialize, shutdown)
  - Text sync handlers (didOpen, didChange, didClose)
  - tree-sitter-php parsing

### Phase Dependencies
- **Phase 0 (Research)**: No dependencies, can start immediately
- **Phase 1 (Design)**: Depends on Phase 0 research decisions
- **Phase 2 (Tasks)**: Depends on Phase 1 design artifacts

### Feature Dependencies
- **Document Symbols (US-1)**: Depends on symbol extractor
- **Workspace Symbols (US-2)**: Depends on symbol index + fuzzy search
- **Go-to-Definition (US-3)**: Depends on workspace index + composer autoload
- **Find References (US-4)**: Depends on workspace index
- **Hover (US-5)**: Depends on symbol resolution + PHPDoc parser

### Parallelization Opportunities
- Symbol extraction, PHPDoc parsing, Composer parsing can be developed in parallel
- Document symbols and workspace symbols share the extractor but have independent handlers
- Integration tests for each handler can be written in parallel

---

## Risks & Mitigation

1. **Risk**: Fuzzy search is too slow for large workspaces
   - **Mitigation**: Profile with 1000-file workspace, optimize index structure, limit search scope if needed

2. **Risk**: Background indexing blocks LSP message handling
   - **Mitigation**: Use tokio::spawn for background task, yield control regularly, prioritize LSP requests

3. **Risk**: PHPDoc parsing is fragile with real-world malformed docs
   - **Mitigation**: Graceful error recovery, parse what's valid and ignore rest, extensive test cases

4. **Risk**: Composer autoload resolution is complex (PSR-4 edge cases)
   - **Mitigation**: Start with PSR-4 only, add PSR-0/classmap later, test with real composer projects

5. **Risk**: Memory usage exceeds 8GB for 1000-file workspace
   - **Mitigation**: Profile memory, use weak references if needed, implement configurable index size limits

6. **Risk**: Name resolution fails for complex use statements (aliases, grouped imports)
   - **Mitigation**: Test with real-world PHP codebases, handle edge cases incrementally

---

## Notes

- Symbol navigation is a foundational feature set that enables higher-level features (refactoring, diagnostics)
- Prioritization allows incremental delivery: US-1+US-2 provide baseline, US-3-5 add advanced capabilities
- Constitution compliance ensures async/non-blocking architecture, incremental parsing, and PHPDoc support
- Dependency on core infrastructure (001) means this feature can't start until 001 is complete
- Performance targets are ambitious but realistic based on similar LSP implementations
- Fuzzy search and composer autoload are the most complex technical challenges
