# Data Model: Symbol Navigation

**Feature**: 002-symbol-navigation  
**Date**: 2025-12-02  
**Purpose**: Define core entities, relationships, and state transitions

---

## Core Entities

### 1. Symbol

Represents a PHP code symbol (class, function, method, property, constant, etc.)

**Fields**:
```rust
pub struct Symbol {
    /// Unique identifier for this symbol within the workspace
    pub id: SymbolId,
    
    /// Symbol name (e.g., "UserController", "getUserById")
    pub name: String,
    
    /// Symbol kind (class, method, function, property, constant, etc.)
    pub kind: SymbolKind,
    
    /// Full span of the symbol in source code
    pub range: Range,
    
    /// Span of just the symbol identifier (for precise navigation)
    pub selection_range: Range,
    
    /// Visibility modifier (public, private, protected) if applicable
    pub visibility: Option<Visibility>,
    
    /// Parent symbol ID for hierarchy (e.g., method's parent is class)
    pub parent: Option<SymbolId>,
    
    /// Detailed signature or type information
    pub detail: Option<String>,
    
    /// File URI where this symbol is defined
    pub uri: Url,
    
    /// Namespace or container name (e.g., "App\\Controllers")
    pub container: Option<String>,
}
```

**Symbol Kind Enum**:
```rust
pub enum SymbolKind {
    File,
    Module,
    Namespace,
    Package,
    Class,
    Method,
    Property,
    Field,
    Constructor,
    Enum,
    Interface,
    Function,
    Variable,
    Constant,
    String,
    Number,
    Boolean,
    Array,
    Object,
    Key,
    Null,
    EnumMember,
    Struct,
    Event,
    Operator,
    TypeParameter,
}
```

**Visibility Enum**:
```rust
pub enum Visibility {
    Public,
    Protected,
    Private,
}
```

**Validation Rules**:
- `name` must not be empty
- `range` must be valid (start ≤ end)
- `selection_range` must be within `range`
- `parent` must reference a valid symbol (if present)
- `kind` must be appropriate for PHP (no Go-specific kinds)

**Examples**:
```rust
// Class symbol
Symbol {
    id: SymbolId::new(1),
    name: "UserController".to_string(),
    kind: SymbolKind::Class,
    range: Range { start: Position { line: 10, character: 0 }, end: Position { line: 100, character: 1 } },
    selection_range: Range { start: Position { line: 10, character: 6 }, end: Position { line: 10, character: 20 } },
    visibility: Some(Visibility::Public),
    parent: None,
    detail: Some("class UserController extends Controller".to_string()),
    uri: Url::from_file_path("/src/Controllers/UserController.php").unwrap(),
    container: Some("App\\Controllers".to_string()),
}

// Method symbol
Symbol {
    id: SymbolId::new(2),
    name: "getUserById".to_string(),
    kind: SymbolKind::Method,
    range: Range { start: Position { line: 15, character: 4 }, end: Position { line: 25, character: 5 } },
    selection_range: Range { start: Position { line: 15, character: 16 }, end: Position { line: 15, character: 27 } },
    visibility: Some(Visibility::Public),
    parent: Some(SymbolId::new(1)), // Parent is UserController
    detail: Some("public function getUserById(int $id): ?User".to_string()),
    uri: Url::from_file_path("/src/Controllers/UserController.php").unwrap(),
    container: Some("UserController".to_string()),
}
```

---

### 2. SymbolIndex

Workspace-wide symbol index for fast lookup and search

**Fields**:
```rust
pub struct SymbolIndex {
    /// Symbols organized by file URI
    by_file: DashMap<Url, Vec<Symbol>>,
    
    /// Name-based index for fast lookup (name → symbol info)
    by_name: DashMap<String, Vec<SymbolInfo>>,
    
    /// Current indexing status
    status: Arc<RwLock<IndexingStatus>>,
    
    /// Total number of indexed files
    indexed_files: AtomicUsize,
    
    /// Total number of indexed symbols
    indexed_symbols: AtomicUsize,
}
```

**SymbolInfo Struct** (lightweight symbol reference for index):
```rust
pub struct SymbolInfo {
    /// Reference to the full symbol
    pub symbol_id: SymbolId,
    
    /// File location
    pub location: Location,
    
    /// Symbol kind (for filtering)
    pub kind: SymbolKind,
    
    /// Container name (namespace or parent class)
    pub container: Option<String>,
}
```

**IndexingStatus Enum**:
```rust
pub enum IndexingStatus {
    NotStarted,
    InProgress { completed: usize, total: usize },
    Complete,
    Failed(String),
}
```

**Methods**:
```rust
impl SymbolIndex {
    /// Update symbols for a specific file
    pub fn update_file_symbols(&self, uri: Url, symbols: Vec<Symbol>);
    
    /// Get all symbols in a file
    pub fn get_file_symbols(&self, uri: &Url) -> Option<Vec<Symbol>>;
    
    /// Find symbols by name (exact match)
    pub fn find_by_name(&self, name: &str) -> Vec<SymbolInfo>;
    
    /// Search symbols with fuzzy matching
    pub fn search(&self, query: &str, limit: usize) -> Vec<SymbolInfo>;
    
    /// Get symbol by ID
    pub fn get_symbol(&self, id: SymbolId) -> Option<Symbol>;
    
    /// Remove symbols for a closed file
    pub fn remove_file(&self, uri: &Url);
    
    /// Get indexing status
    pub fn status(&self) -> IndexingStatus;
}
```

---

### 3. PHPDocBlock

Parsed PHPDoc comment with all tags

**Fields**:
```rust
pub struct PHPDocBlock {
    /// Description text (before tags)
    pub description: Option<String>,
    
    /// @param tags
    pub params: Vec<ParamTag>,
    
    /// @return tag
    pub return_type: Option<ReturnTag>,
    
    /// @var tag
    pub var_type: Option<VarTag>,
    
    /// @throws tags
    pub throws: Vec<ThrowsTag>,
    
    /// @deprecated tag
    pub deprecated: Option<DeprecatedTag>,
    
    /// @template tags (generics)
    pub templates: Vec<TemplateTag>,
    
    /// @extends/@implements tags
    pub extends: Vec<ExtendsTag>,
    
    /// @psalm-* tags
    pub psalm_tags: Vec<PsalmTag>,
    
    /// @phpstan-* tags
    pub phpstan_tags: Vec<PHPStanTag>,
    
    /// Raw docblock text (for debugging)
    pub raw: String,
}
```

**Tag Structs**:
```rust
pub struct ParamTag {
    pub name: String,        // Parameter name (without $)
    pub type_hint: String,   // Type (e.g., "int", "string[]", "User")
    pub description: Option<String>,
}

pub struct ReturnTag {
    pub type_hint: String,
    pub description: Option<String>,
}

pub struct VarTag {
    pub type_hint: String,
    pub description: Option<String>,
}

pub struct ThrowsTag {
    pub exception_type: String,
    pub description: Option<String>,
}

pub struct DeprecatedTag {
    pub message: Option<String>,
    pub since: Option<String>,
}

pub struct TemplateTag {
    pub name: String,        // Template parameter name (e.g., "T")
    pub constraint: Option<String>, // "of" constraint (e.g., "of User")
}

pub struct ExtendsTag {
    pub class_name: String,
    pub type_params: Vec<String>,
}

pub struct PsalmTag {
    pub name: String,        // Tag name after @psalm- (e.g., "param", "return")
    pub content: String,     // Full tag content
}

pub struct PHPStanTag {
    pub name: String,        // Tag name after @phpstan-
    pub content: String,
}
```

**Example**:
```rust
PHPDocBlock {
    description: Some("Retrieve a user by their unique identifier.".to_string()),
    params: vec![
        ParamTag {
            name: "id".to_string(),
            type_hint: "int".to_string(),
            description: Some("The user ID".to_string()),
        }
    ],
    return_type: Some(ReturnTag {
        type_hint: "?User".to_string(),
        description: Some("The user object or null if not found".to_string()),
    }),
    deprecated: Some(DeprecatedTag {
        message: Some("Use findUser($id) instead".to_string()),
        since: Some("2.0".to_string()),
    }),
    templates: vec![],
    extends: vec![],
    psalm_tags: vec![],
    phpstan_tags: vec![],
    raw: "/** ... */".to_string(),
}
```

---

### 4. ComposerAutoload

Parsed composer.json autoload configuration

**Fields**:
```rust
pub struct ComposerAutoload {
    /// PSR-4 autoload mapping (namespace → directories)
    pub psr4: HashMap<String, Vec<PathBuf>>,
    
    /// PSR-0 autoload mapping (optional, for legacy projects)
    pub psr0: HashMap<String, Vec<PathBuf>>,
    
    /// Classmap directories/files (optional)
    pub classmap: Vec<PathBuf>,
    
    /// Files to be included (optional)
    pub files: Vec<PathBuf>,
    
    /// Workspace root directory
    pub workspace_root: PathBuf,
}
```

**Methods**:
```rust
impl ComposerAutoload {
    /// Parse composer.json from workspace root
    pub fn from_workspace(root: PathBuf) -> Result<Self, ComposerError>;
    
    /// Resolve fully qualified class name to file path
    pub fn resolve_class(&self, fqn: &str) -> Option<PathBuf>;
    
    /// Check if a namespace is autoloaded
    pub fn is_autoloaded(&self, namespace: &str) -> bool;
}
```

**Example**:
```rust
ComposerAutoload {
    psr4: HashMap::from([
        ("App\\".to_string(), vec![PathBuf::from("src/")]),
        ("Tests\\".to_string(), vec![PathBuf::from("tests/")]),
    ]),
    psr0: HashMap::new(),
    classmap: vec![],
    files: vec![],
    workspace_root: PathBuf::from("/project/root"),
}

// Usage:
let path = autoload.resolve_class("App\\Controllers\\UserController");
// Returns: Some("/project/root/src/Controllers/UserController.php")
```

---

### 5. DefinitionLocation

Location where a symbol is defined

**Fields**:
```rust
pub struct DefinitionLocation {
    /// File URI
    pub uri: Url,
    
    /// Range of the definition
    pub range: Range,
}
```

**Conversion to LSP Location**:
```rust
impl From<DefinitionLocation> for Location {
    fn from(def: DefinitionLocation) -> Self {
        Location {
            uri: def.uri,
            range: def.range,
        }
    }
}
```

---

### 6. ReferenceLocation

Location where a symbol is referenced

**Fields**:
```rust
pub struct ReferenceLocation {
    /// File URI
    pub uri: Url,
    
    /// Range of the reference
    pub range: Range,
    
    /// Is this the definition location?
    pub is_definition: bool,
}
```

---

## Relationships

```
Symbol
  ├──> SymbolIndex (many-to-one: many symbols belong to one index)
  ├──> PHPDocBlock (one-to-optional-one: symbol may have documentation)
  └──> Symbol (optional parent: method belongs to class)

SymbolIndex
  ├──> Symbol (one-to-many: index contains many symbols)
  └──> SymbolInfo (one-to-many: index contains many symbol references)

ComposerAutoload
  └──> DefinitionLocation (resolves FQN to location)

PHPDocBlock
  └──> Symbol (provides documentation for symbol)
```

---

## State Transitions

### IndexingStatus State Machine

```
NotStarted
    ↓ (start_background_indexing)
InProgress { completed: 0, total: N }
    ↓ (file indexed)
InProgress { completed: K, total: N } (K < N)
    ↓ (all files indexed)
Complete
    ↓ (file added/changed)
InProgress { completed: K, total: N+1 }
    ↓ (re-indexing complete)
Complete

Failed(error)
    ↓ (retry)
InProgress { completed: 0, total: N }
```

### Symbol Lifecycle

```
Created (symbol extracted from AST)
    ↓
Indexed (added to SymbolIndex)
    ↓
Referenced (used in go-to-definition, references, hover)
    ↓
Updated (file changed, symbol re-extracted)
    ↓
Removed (file closed or deleted)
```

---

## Validation Rules

### Symbol Validation
- `name` must not be empty
- `range` must be valid (start <= end)
- `selection_range` must be within `range`
- `uri` must be a valid file:// URL
- `kind` must be appropriate for PHP

### PHPDocBlock Validation
- Tag types must match PHP type syntax (scalar types, class names, union types, array types)
- `@param` name must match function parameter names (warning if mismatch)
- `@return` type should not be used on constructors/destructors (warning)

### ComposerAutoload Validation
- Namespace prefixes must end with \\
- Directory paths must exist or be creatable
- PSR-4 directories must match namespace structure

---

## Performance Considerations

### Memory Estimates
- Symbol: ~200 bytes (name, ranges, metadata)
- SymbolInfo: ~100 bytes (lightweight reference)
- PHPDocBlock: ~500-2000 bytes (varies by docblock size)
- 1000-file project: ~50k symbols × 200 bytes = ~10 MB for symbols
- Name index: ~50k entries × 100 bytes = ~5 MB
- Total: ~15-20 MB for symbol data (well under 8GB limit)

### Lookup Performance
- By name (exact): O(1) average case (HashMap)
- By file: O(1) average case (DashMap)
- Fuzzy search: O(N) where N = total unique symbol names (~5-10k for typical project)
- Composer resolve: O(1) with cache, O(M) without cache (M = number of PSR-4 prefixes)

### Update Performance
- Single file update: O(K) where K = symbols in that file (~50-200)
- Full workspace index: O(N × K) where N = files, K = avg symbols per file
- Estimate: 1000 files × 50 symbols × 1ms parse = ~50 seconds (exceeds target)
- Optimization: Parallel parsing with rayon, target 30 seconds

---

## Integration Points

### With Core Infrastructure (001)
- Reuses `Document` struct with cached AST
- Reuses `ServerState` for document storage
- Symbol extraction reads from `tree: Option<Tree>`

### With LSP Handlers
- Document symbols: reads from SymbolIndex by file URI
- Workspace symbols: searches SymbolIndex with fuzzy matcher
- Go-to-definition: resolves name via SymbolIndex + ComposerAutoload
- Find-references: searches SymbolIndex for all occurrences
- Hover: resolves symbol + parses PHPDoc from source

---

## Error Handling

### SymbolError Enum
```rust
pub enum SymbolError {
    ParseError(String),
    NotFound(String),
    InvalidSymbolKind,
    IndexingFailed(String),
}
```

### ComposerError Enum
```rust
pub enum ComposerError {
    FileNotFound(PathBuf),
    ParseError(String),
    InvalidAutoloadConfig(String),
}
```

### PHPDocError Enum
```rust
pub enum PHPDocError {
    MalformedTag(String),
    InvalidType(String),
}
```

**Error Strategy**:
- Parsing errors: return partial results + log warning
- Not found errors: return empty/None (not user error)
- Invalid config: return error to client, don't crash server
