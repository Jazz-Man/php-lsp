# Feature Specification: Symbol Navigation

**Feature Branch**: `002-symbol-navigation`  
**Created**: 2025-12-02  
**Status**: Draft  
**Input**: User description: "Feature: Symbol Navigation

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
- References found cross-file"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Document Symbol Outline (Priority: P1)

As a developer writing PHP code, I need to view a hierarchical outline of all symbols in the current file so that I can quickly understand the file structure and navigate to specific classes, methods, and properties.

**Why this priority**: Document symbols (outline view) are fundamental for code navigation within a single file. This is a core LSP feature that editors expect and users rely on heavily for orientation.

**Independent Test**: Can be fully tested by opening a PHP file with classes, methods, properties, and constants, requesting document symbols, and verifying the hierarchical structure with visibility indicators (public/private/protected) is returned correctly.

**Acceptance Scenarios**:

1. **Given** a PHP file with a class containing public, private, and protected methods, **When** the editor requests document symbols, **Then** the server returns a hierarchical list showing the class as parent and methods as children with visibility markers
2. **Given** a PHP file with nested classes (class inside namespace, traits, interfaces), **When** document symbols are requested, **Then** the hierarchy correctly reflects the nesting structure (namespace → class → methods → properties)
3. **Given** a PHP file with functions outside classes, **When** document symbols are requested, **Then** both file-level functions and class members appear in the outline at appropriate hierarchy levels
4. **Given** an empty or malformed PHP file, **When** document symbols are requested, **Then** the server returns an empty list or partial symbols without errors

---

### User Story 2 - Workspace-Wide Symbol Search (Priority: P2)

As a developer working on a large PHP project, I need to search for symbols across all PHP files in the workspace using fuzzy matching so that I can quickly jump to any class, function, or method regardless of which file it's in.

**Why this priority**: Workspace symbols enable project-wide navigation, essential for large codebases. Depends on document parsing (from core infrastructure) but provides significant productivity gains. Background indexing ensures search remains fast.

**Independent Test**: Can be tested independently by opening a workspace with multiple PHP files, triggering background indexing, performing fuzzy searches for known symbols, and verifying results include symbols from all indexed files with match quality ranking.

**Acceptance Scenarios**:

1. **Given** a workspace with 100+ PHP files, **When** the workspace is opened, **Then** the server indexes all PHP files in the background without blocking editor responsiveness
2. **Given** the workspace index is complete, **When** the developer searches for "UserController" using fuzzy query "usrctrl", **Then** the server returns matching symbols ranked by relevance
3. **Given** a file is edited and saved, **When** the content changes add new symbols, **Then** the workspace index updates to include the new symbols without full re-indexing
4. **Given** multiple symbols match the search query, **When** results are returned, **Then** symbols are ranked by match quality (exact > prefix > substring > fuzzy) and include file location and symbol kind
5. **Given** the workspace contains vendor directories (composer dependencies), **When** indexing occurs, **Then** vendor files are indexed with lower priority or can be excluded via configuration

---

### User Story 3 - Go-to-Definition Navigation (Priority: P3)

As a developer reading PHP code, I need to Ctrl+Click (or use keyboard shortcut) on a symbol to jump to its definition so that I can quickly understand how functions, classes, and methods are implemented, including resolving use statements and composer autoload paths.

**Why this priority**: Go-to-definition is a critical navigation feature but requires symbol indexing (P2) and name resolution. Composer autoload resolution ensures accuracy in real PHP projects.

**Independent Test**: Can be tested independently by opening a PHP file with function calls, method invocations, class references, and use statements, triggering go-to-definition on each, and verifying the editor navigates to the correct definition location (file + line + column).

**Acceptance Scenarios**:

1. **Given** a function call in a PHP file, **When** the developer triggers go-to-definition on the function name, **Then** the server locates the function definition in the same or another file and returns its location
2. **Given** a method call on a class instance, **When** go-to-definition is triggered, **Then** the server resolves the class type, finds the method definition, and returns its location
3. **Given** a class reference with a use statement at the top of the file, **When** go-to-definition is triggered on the short class name, **Then** the server resolves the fully qualified name via the use statement and locates the class definition
4. **Given** a composer-autoloaded class (PSR-4), **When** go-to-definition is triggered, **Then** the server uses composer.json autoload configuration to map the namespace to the file path and locates the definition
5. **Given** a symbol with multiple potential definitions (e.g., overloaded methods), **When** go-to-definition is triggered, **Then** the server returns the most relevant definition based on context or provides multiple options
6. **Given** a reference to a symbol that doesn't exist or can't be resolved, **When** go-to-definition is triggered, **Then** the server returns an empty result or error message without crashing

---

### User Story 4 - Find All References (Priority: P4)

As a developer refactoring PHP code, I need to find all locations where a function, class, or method is used across the workspace so that I can safely rename or modify it knowing the impact.

**Why this priority**: Find references is essential for refactoring but depends on workspace indexing (P2) being functional. Lower priority than go-to-definition because it's used less frequently.

**Independent Test**: Can be tested independently by defining a function/class/method in one file, referencing it in multiple other files, triggering find-references, and verifying all usage locations are returned with file paths and line numbers.

**Acceptance Scenarios**:

1. **Given** a function is defined in one file and called in three other files, **When** find-references is triggered on the function definition, **Then** the server returns all four locations (definition + three usages)
2. **Given** a class is instantiated in multiple files, **When** find-references is triggered on the class name, **Then** all instantiation locations are returned
3. **Given** a method is called on objects of a specific class, **When** find-references is triggered on the method definition, **Then** all call sites are returned, correctly distinguishing from methods with the same name in other classes
4. **Given** a variable is used multiple times within a single function, **When** find-references is triggered, **Then** only references within the appropriate scope are returned (local variable references don't cross function boundaries)
5. **Given** a large workspace with hundreds of files, **When** find-references is triggered, **Then** results are returned within 3 seconds with a progress indicator for long-running searches

---

### User Story 5 - Hover Information with PHPDoc (Priority: P5)

As a developer reading PHP code, I need to hover over a symbol to see its signature (parameters, return type) and documentation extracted from PHPDoc comments, formatted as markdown, so that I can understand how to use functions and methods without navigating away from my current context.

**Why this priority**: Hover information enhances code comprehension and reduces context switching, but it's a "nice-to-have" compared to core navigation features. Requires PHPDoc parsing which adds complexity.

**Independent Test**: Can be tested independently by defining functions/methods/classes with PHPDoc comments containing @param, @return, @var, @deprecated tags, hovering over references to these symbols, and verifying the hover tooltip displays formatted documentation.

**Acceptance Scenarios**:

1. **Given** a function with a PHPDoc comment containing @param and @return tags, **When** the developer hovers over a call to that function, **Then** the hover tooltip displays the function signature and parsed documentation in markdown format
2. **Given** a method with @deprecated tag in PHPDoc, **When** hovering over a call to that method, **Then** the hover tooltip prominently displays the deprecation notice
3. **Given** a class with @template tags (generics) and psalm/phpstan annotations, **When** hovering over the class name, **Then** the hover tooltip includes template information and extended type annotations
4. **Given** a variable with an inline @var docblock, **When** hovering over the variable, **Then** the hover tooltip shows the declared type from @var
5. **Given** a symbol with no PHPDoc, **When** hovering, **Then** the server displays the signature derived from the code (parameter types, return type from PHP 7+ type hints) without documentation
6. **Given** hover is triggered on a built-in PHP function (e.g., array_map), **When** the server has no local definition, **Then** the server optionally provides standard PHP manual information or returns empty

---

### Edge Cases

- What happens when a symbol is defined multiple times in the workspace (name collision)? (Go-to-definition should return multiple options or prioritize based on proximity/namespace context)
- How does the system handle symbols in files that are not yet indexed? (Show partial results with a notice that indexing is in progress)
- What happens when hovering over a symbol in a file with syntax errors? (Show best-effort signature and documentation from cached parse tree)
- How does find-references handle symbols in generated files (build artifacts)? (Configurable: include or exclude generated files from indexing)
- What happens when composer.json is missing or invalid? (Fall back to file-path-based symbol resolution without autoload mapping)
- How does the system handle extremely large workspaces (10,000+ files)? (Progressive indexing with priority for open files, configurable index size limits)
- What happens when PHPDoc contains invalid markdown or malformed tags? (Parse what's valid, ignore malformed tags gracefully, show partial documentation)

## Requirements *(mandatory)*

### Functional Requirements

#### Document Symbols (US-1)

- **FR-001**: Server MUST implement the `textDocument/documentSymbol` LSP request and return a hierarchical symbol tree for the requested document
- **FR-002**: Symbol tree MUST include symbol name, kind (class, method, function, property, constant, interface, trait, enum), range (start/end position), and selection range (identifier position)
- **FR-003**: Symbols MUST be organized hierarchically (namespace contains classes, classes contain methods/properties, methods contain local symbols if supported)
- **FR-004**: Symbol information MUST include visibility indicators (public, private, protected) where applicable
- **FR-005**: Server MUST extract symbols from cached AST (from core infrastructure) without re-parsing

#### Workspace Symbols (US-2)

- **FR-006**: Server MUST implement the `workspace/symbol` LSP request and return matching symbols from the entire workspace
- **FR-007**: Server MUST index all PHP files in the workspace on initialization or workspace folder changes
- **FR-008**: Indexing MUST occur in the background without blocking LSP message handling or editor responsiveness
- **FR-009**: Symbol search MUST support fuzzy matching (e.g., "usrctrl" matches "UserController")
- **FR-010**: Search results MUST be ranked by match quality (exact match > prefix match > substring match > fuzzy match)
- **FR-011**: Workspace index MUST update incrementally when files are added, modified, or deleted
- **FR-012**: Index MUST be memory-efficient and support workspaces with 1000+ PHP files

#### Go-to-Definition (US-3)

- **FR-013**: Server MUST implement the `textDocument/definition` LSP request and return the location of the symbol definition
- **FR-014**: Server MUST resolve function, class, method, property, and constant definitions across files
- **FR-015**: Server MUST resolve use statements (aliases and imports) to fully qualified names when determining definitions
- **FR-016**: Server MUST integrate with composer autoload configuration (PSR-4, PSR-0, classmap) to resolve namespaced classes to file paths
- **FR-017**: Server MUST return definition locations with file URI, line number, and character offset
- **FR-018**: Server MUST handle cases where definitions cannot be found gracefully (return empty or null)

#### Find References (US-4)

- **FR-019**: Server MUST implement the `textDocument/references` LSP request and return all locations where the symbol is referenced
- **FR-020**: Reference locations MUST include the definition location if the `includeDeclaration` parameter is true
- **FR-021**: Server MUST search across all indexed files in the workspace to find references
- **FR-022**: Reference search MUST distinguish between different symbols with the same name (e.g., methods in different classes)
- **FR-023**: Server MUST return reference locations with file URI, line number, and character offset

#### Hover Information (US-5)

- **FR-024**: Server MUST implement the `textDocument/hover` LSP request and return hover information for the symbol at the cursor position
- **FR-025**: Hover content MUST include the symbol signature (function/method parameters, return type, class signature)
- **FR-026**: Server MUST parse PHPDoc comments and extract @param, @return, @var, @deprecated, @template tags
- **FR-027**: Server MUST parse extended PHPDoc tags including @psalm-* and @phpstan-* annotations
- **FR-028**: Hover content MUST be formatted as markdown for proper rendering in editor hover tooltips
- **FR-029**: Server MUST display deprecation notices prominently when @deprecated tag is present
- **FR-030**: Server MUST provide signature information even when PHPDoc is absent (use PHP type hints)

### Key Entities

- **Symbol**: Represents a code symbol (class, function, method, property, constant, etc.) with name, kind, range, visibility, parent hierarchy, and documentation
- **Symbol Index**: In-memory database mapping symbol names to their definition locations and metadata, supporting fuzzy search and quick lookups across the workspace
- **Definition Location**: File URI, line number, and character offset identifying where a symbol is defined
- **Reference Location**: File URI, line number, and character offset identifying where a symbol is used
- **PHPDoc Block**: Parsed documentation comment containing tags (@param, @return, @var, @deprecated, @template, @psalm-*, @phpstan-*) and description text
- **Hover Content**: Markdown-formatted text combining signature and PHPDoc information displayed in editor tooltips
- **Composer Autoload Mapping**: Configuration from composer.json defining namespace-to-directory mappings (PSR-4, PSR-0) used for symbol resolution

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Editor displays hierarchical document outline with nested class members and visibility indicators for any PHP file within 100ms of request
- **SC-002**: Workspace symbol search returns relevant results for fuzzy queries within 500ms for workspaces up to 1000 files
- **SC-003**: Go-to-definition successfully navigates to correct definition location for 95%+ of function/class/method references in properly structured PHP projects
- **SC-004**: Find-references locates all usage sites across the workspace and returns results within 3 seconds for typical codebases
- **SC-005**: Hover tooltips display formatted signature and PHPDoc documentation within 100ms of hover trigger
- **SC-006**: Background indexing completes for 1000-file workspace within 30 seconds without blocking editor interactions
- **SC-007**: Composer autoload resolution correctly maps namespaced classes to file paths for projects following PSR-4 conventions

### Constitution Compliance

- **Async Non-Blocking (Principle I)**: All LSP request handlers use async/await, workspace indexing runs in background task, no blocking operations on tokio runtime
- **PHP Version Awareness (Principle II)**: Symbol extraction respects PHP version-specific syntax (enums in 8.1+, attributes in 8.0+); version detection from composer.json (if implemented) influences parsing
- **PHPDoc Support (Principle III)**: Full implementation of PHPDoc parsing including standard tags, template types, and Psalm/PHPStan annotations as specified
- **WordPress Integration (Principle IV)**: Not applicable to this feature (will be separate feature for WordPress-specific hooks)
- **Incremental Parsing (Principle V)**: Symbol extraction uses cached AST from core infrastructure, index updates incrementally on file changes
- **Extension Validation (Principle VI)**: Not applicable to this feature (symbol navigation doesn't require extension validation)
- **Reliability (Principle VII)**:
  - **Quality**: Unit tests for symbol extraction, indexing, search, resolution logic; integration tests for each user story; target 80%+ coverage
  - **Reliability**: No panic paths, all errors handled with Result/Option types, graceful degradation when symbols can't be resolved or indexed
  - **Observability**: Tracing logs for indexing progress, search queries, resolution attempts, cache hits/misses, errors
  - **Documentation**: Public APIs (symbol index, search, resolver, PHPDoc parser) documented with doc comments
