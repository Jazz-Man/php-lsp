# Feature Specification: Core LSP Infrastructure

**Feature Branch**: `001-core-lsp-infrastructure`  
**Created**: 2025-12-02  
**Status**: Draft  
**Input**: User description: "Feature: Core LSP Infrastructure

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
- Integration test: init → open → change → close → shutdown"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Server Lifecycle Management (Priority: P1)

As a code editor (Zed), I need to establish and tear down a connection with the LSP server so that language features become available for PHP files.

**Why this priority**: Without a working initialize/shutdown cycle, no LSP features can function. This is the foundational requirement for any language server.

**Independent Test**: Can be fully tested by starting the server, sending an initialize request, verifying ServerCapabilities in the response, and cleanly shutting down. Delivers a functional but minimal LSP server that editors can connect to.

**Acceptance Scenarios**:

1. **Given** the LSP server process is started with stdio transport, **When** the editor sends an `initialize` request with client capabilities, **Then** the server responds with `InitializeResult` containing ServerCapabilities (textDocumentSync, documentSymbol support) within 500ms
2. **Given** the server has been initialized, **When** the editor sends a `shutdown` request followed by an `exit` notification, **Then** the server cleanly releases resources and terminates with exit code 0
3. **Given** the server receives an `exit` notification before `shutdown`, **Then** the server terminates with exit code 1 (protocol violation)
4. **Given** the server is in the process of initializing, **When** a second `initialize` request arrives, **Then** the server returns an error indicating already initialized

---

### User Story 2 - Document Synchronization (Priority: P2)

As a code editor, I need to notify the server when PHP files are opened, edited, or closed so that the server maintains an accurate view of the workspace and can provide up-to-date language features.

**Why this priority**: Document tracking is essential for providing accurate diagnostics and completions, but the server must first be able to initialize (P1). This enables real-time code analysis.

**Independent Test**: Can be tested independently by initializing the server, opening a PHP document, making incremental edits, and closing the document. Verifies the server correctly tracks document state without requiring symbol extraction or other features.

**Acceptance Scenarios**:

1. **Given** the server is initialized and ready, **When** the editor sends a `textDocument/didOpen` notification with PHP file content, **Then** the server stores the document text and version number in memory
2. **Given** a document is open in the server, **When** the editor sends a `textDocument/didChange` notification with incremental edits, **Then** the server applies the changes using rope-based text representation and updates the document version
3. **Given** a document is open in the server, **When** the editor sends a `textDocument/didClose` notification, **Then** the server removes the document from memory and frees associated resources
4. **Given** multiple documents are open, **When** changes are made to one document, **Then** only that document's internal state is updated without affecting others
5. **Given** a `didChange` notification arrives with an outdated version number, **When** the server receives it, **Then** the server ignores the change and logs a version mismatch warning

---

### User Story 3 - PHP Parsing and Symbol Extraction (Priority: P3)

As a code editor, I need the server to parse PHP files and extract symbols so that I can provide features like outline view, document symbols, and jump-to-definition.

**Why this priority**: Symbol extraction enables higher-level language features but depends on document synchronization (P2) being functional. It's essential for navigation features but not required for basic server connectivity.

**Independent Test**: Can be tested independently by opening a PHP file with known symbols (class, function, method, property, constant, interface, trait, enum), triggering parsing, and verifying the extracted symbol tree matches expected structure.

**Acceptance Scenarios**:

1. **Given** a PHP 8 document is opened containing a class with methods and properties, **When** the server parses the document, **Then** the server extracts symbols for the class, all public/protected/private methods, and all properties, caching the AST in memory
2. **Given** a PHP 8 document with modern syntax (attributes, named arguments, union types, match expressions), **When** the server parses the document, **Then** parsing completes without errors and symbols are correctly identified
3. **Given** a PHP document is parsed, **When** the document content changes via `didChange`, **Then** the server re-parses only the changed portions (incremental parsing) and updates the symbol cache within 50ms
4. **Given** a document with syntax errors, **When** the server parses it, **Then** the server produces a partial AST with error recovery and extracts as many valid symbols as possible
5. **Given** multiple PHP documents are open, **When** requesting document symbols, **Then** the server returns symbols only for the requested document without cross-file interference

---

### Edge Cases

- What happens when a document is closed before parsing completes? (Server should cancel the parse operation and clean up resources)
- How does the system handle malformed UTF-8 in document content? (Server should handle encoding errors gracefully and report them to the editor)
- What happens when the server receives a `didChange` for a document that was never opened? (Server should log an error and ignore the change)
- How does the system handle extremely large files (>10MB)? (Server should still parse but may take longer; performance degradation should be graceful)
- What happens when tree-sitter fails to parse a document? (Server should return an empty symbol list and log the error without crashing)
- How does the system handle rapid successive edits (typing quickly)? (Server should queue changes and process them incrementally without blocking)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Server MUST implement the LSP initialize/initialized/shutdown/exit message sequence according to the LSP specification
- **FR-002**: Server MUST communicate over stdio transport for compatibility with Zed editor
- **FR-003**: Server MUST advertise ServerCapabilities including textDocumentSync (incremental) and documentSymbolProvider in the initialize response
- **FR-004**: Server MUST accept `textDocument/didOpen`, `textDocument/didChange`, and `textDocument/didClose` notifications and update internal document state accordingly
- **FR-005**: Server MUST use incremental text synchronization (TextDocumentSyncKind.Incremental) to minimize data transfer
- **FR-006**: Server MUST represent document text using a rope data structure for efficient incremental edits
- **FR-007**: Server MUST parse PHP documents using the tree-sitter-php parser
- **FR-008**: Server MUST cache the Abstract Syntax Tree (AST) for each open document to avoid redundant parsing
- **FR-009**: Server MUST use tree-sitter's incremental parsing capability when document content changes
- **FR-010**: Server MUST extract the following PHP symbol types: class, interface, trait, enum, function, method, property, constant
- **FR-011**: Server MUST correctly parse PHP 8 syntax including attributes, named arguments, union types, and match expressions
- **FR-012**: Server MUST maintain memory usage proportional to the number of open documents only (no background indexing of closed files in this phase)
- **FR-013**: Server MUST respond to the initialize request within 500ms
- **FR-014**: Server MUST process document change notifications and re-parse within 50ms for typical edits
- **FR-015**: Server MUST clean up document state and release memory when documents are closed

### Key Entities

- **LSP Server Instance**: Represents the running server process, maintains initialization state, manages document collection, and routes LSP messages
- **Text Document**: Represents an open PHP file with URI, version number, language identifier, and rope-based content representation
- **Syntax Tree**: Represents the parsed AST for a document, produced by tree-sitter-php, cached per document
- **Symbol**: Represents a code symbol (class, function, method, etc.) with name, kind, range, and parent hierarchy
- **Server Capabilities**: Describes which LSP features the server supports, communicated during initialization

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Server responds to initialize request from Zed editor and returns ServerCapabilities within 500ms
- **SC-002**: Server processes document open/change/close notifications and maintains accurate document state with 100% consistency
- **SC-003**: Server parses PHP 8 files containing modern syntax (attributes, named arguments, union types, match) without parse errors for valid code
- **SC-004**: Server re-parses incremental document changes within 50ms for typical edits (single line changes, small block edits)
- **SC-005**: Server memory usage scales linearly with the number of open documents (no memory leaks, no unbounded growth)
- **SC-006**: Integration test successfully executes the full lifecycle: initialize → open document → make changes → close document → shutdown

### Constitution Compliance

- **Async Non-Blocking (Principle I)**: All LSP message handlers use async/await, parsing operations yield control regularly, no blocking operations on tokio runtime
- **PHP Version Awareness (Principle II)**: Parser configured to support PHP 8+ syntax; future enhancements will detect version from composer.json (not in scope for this feature)
- **PHPDoc Support (Principle III)**: Not in scope for this feature (will be added in future enhancement)
- **WordPress Integration (Principle IV)**: Not applicable to this feature (core infrastructure only)
- **Incremental Parsing (Principle V)**: Tree-sitter incremental parsing used for document changes, rope data structure enables efficient edits
- **Extension Validation (Principle VI)**: Not in scope for this feature (will be added in future enhancement)
- **Reliability (Principle VII)**:
  - **Quality**: Feature has unit tests for message handlers, document tracking, and parsing; integration test for full lifecycle; target 80%+ coverage
  - **Reliability**: No panic paths, all errors handled with Result/Option types, no unwrap/expect in production code
  - **Observability**: Tracing logs for initialize/shutdown, document open/change/close, parsing start/complete, errors
  - **Documentation**: Public APIs (message handlers, document manager, parser interface) documented with doc comments
