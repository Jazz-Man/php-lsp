# Quickstart: Testing Symbol Navigation

**Feature**: 002-symbol-navigation  
**Date**: 2025-12-02  
**Purpose**: Manual testing guide for symbol navigation features

---

## Prerequisites

1. Build the LSP server:
   ```bash
   cd /path/to/php-lsp
   cargo build --release
   ```

2. Prepare test workspace:
   ```bash
   mkdir test-workspace
   cd test-workspace
   
   # Create composer.json with PSR-4 autoload
   cat > composer.json <<EOF
   {
     "autoload": {
       "psr-4": {
         "App\\\\": "src/"
       }
     }
   }
   EOF
   
   # Create sample PHP files
   mkdir -p src/Controllers src/Services
   ```

3. Create test files:

   **src/Controllers/UserController.php**:
   ```php
   <?php
   
   namespace App\Controllers;
   
   use App\Services\UserService;
   
   /**
    * Handles user-related HTTP requests
    */
   class UserController
   {
       private UserService $userService;
       
       public function __construct(UserService $userService)
       {
           $this->userService = $userService;
       }
       
       /**
        * Get a user by ID
        *
        * @param int $id The user ID
        * @return array|null User data or null if not found
        * @deprecated Use getUserDetails instead
        */
       public function getUser(int $id): ?array
       {
           return $this->userService->findById($id);
       }
       
       /**
        * Get detailed user information
        *
        * @param int $id The user ID
        * @return array User details
        * @psalm-return array{id: int, name: string, email: string}
        */
       public function getUserDetails(int $id): array
       {
           return $this->userService->getDetails($id);
       }
   }
   ```

   **src/Services/UserService.php**:
   ```php
   <?php
   
   namespace App\Services;
   
   /**
    * User service for database operations
    */
   class UserService
   {
       /**
        * Find user by ID
        *
        * @param int $id
        * @return array|null
        */
       public function findById(int $id): ?array
       {
           // Implementation
           return null;
       }
       
       /**
        * Get user details
        *
        * @param int $id
        * @return array
        * @template T of User
        */
       public function getDetails(int $id): array
       {
           return [];
       }
   }
   ```

---

## Testing Scenarios

### 1. Document Symbols (US-1)

**Goal**: Verify hierarchical outline with visibility

**Steps**:
1. Start LSP server:
   ```bash
   ./target/release/php-lsp
   ```

2. Connect editor (Zed) via stdio

3. Open `src/Controllers/UserController.php`

4. Request document symbols (Ctrl+Shift+O or outline view)

**Expected Result**:
- Hierarchical tree appears:
  ```
  UserController (class)
    ├── $userService (property, private)
    ├── __construct (method, public)
    ├── getUser (method, public)
    └── getUserDetails (method, public)
  ```
- Each symbol shows visibility indicator
- Clicking symbol navigates to its location
- Response time: <100ms

**Verification**:
```bash
# Check tracing logs
tail -f /tmp/php-lsp.log | grep "document_symbol"
# Should show: "Extracted N symbols from file in Xms"
```

---

### 2. Workspace Symbols (US-2)

**Goal**: Verify fuzzy search across workspace

**Steps**:
1. Ensure workspace has multiple files indexed

2. Check indexing status in logs:
   ```
   Indexed 10/10 files
   ```

3. Trigger workspace symbol search (Ctrl+T or Cmd+T)

4. Search with fuzzy query: "usrctrl"

**Expected Result**:
- Returns "UserController" as top result
- Shows file location and symbol kind
- Results ranked by relevance
- Response time: <500ms

**Fuzzy Query Tests**:
| Query      | Should Find           | Match Type |
|------------|-----------------------|------------|
| UserCont   | UserController        | Prefix     |
| usrctrl    | UserController        | Fuzzy      |
| getUser    | getUser, getUserDetails | Exact/Prefix |
| usrsrv     | UserService           | Fuzzy      |

**Verification**:
```bash
# Check indexing logs
grep "Workspace indexing complete" /tmp/php-lsp.log
# Should show total files and time taken (<30s for 1000 files)
```

---

### 3. Go-to-Definition (US-3)

**Goal**: Verify navigation to definitions with composer autoload

**Test Cases**:

#### 3.1 Function Call
1. Open `UserController.php`
2. Ctrl+Click on `findById` in line:
   ```php
   return $this->userService->findById($id);
   ```
3. **Expected**: Navigate to `findById` method definition in `UserService.php`

#### 3.2 Class Reference with Use Statement
1. Open `UserController.php`
2. Ctrl+Click on `UserService` in line:
   ```php
   use App\Services\UserService;
   ```
3. **Expected**: Navigate to `UserService` class definition

#### 3.3 Composer Autoload Resolution
1. Open `UserController.php`
2. Ctrl+Click on `UserService` in constructor parameter:
   ```php
   public function __construct(UserService $userService)
   ```
3. **Expected**: Resolve via composer PSR-4 mapping and navigate to `src/Services/UserService.php`

**Response Time**: <200ms per definition lookup

**Verification**:
```bash
# Check resolution logs
grep "Resolved.*to.*UserService" /tmp/php-lsp.log
# Should show: "Resolved App\Services\UserService to /path/src/Services/UserService.php"
```

---

### 4. Find References (US-4)

**Goal**: Verify cross-file reference finding

**Test Cases**:

#### 4.1 Method References
1. Open `UserService.php`
2. Trigger find-references on `findById` method definition (line 15)
3. **Expected**: Returns:
   - Definition in `UserService.php:15`
   - Usage in `UserController.php:30`

#### 4.2 Class References
1. Open `UserService.php`
2. Trigger find-references on `UserService` class name
3. **Expected**: Returns all locations:
   - Definition in `UserService.php`
   - Use statement in `UserController.php`
   - Constructor parameter in `UserController.php`
   - Property type in `UserController.php`

**Response Time**: <3 seconds

**Verification**:
```bash
# Check search logs
grep "Found.*references.*for" /tmp/php-lsp.log
# Should show: "Found 4 references for UserService in 250ms"
```

---

### 5. Hover with PHPDoc (US-5)

**Goal**: Verify hover displays formatted documentation

**Test Cases**:

#### 5.1 Method with Standard PHPDoc
1. Open `UserController.php`
2. Hover over `getUser` method call
3. **Expected**: Hover tooltip shows:
   ```markdown
   ```php
   public function getUser(int $id): ?array
   ```
   
   Get a user by ID
   
   **Parameters:**
   - `$id` (int): The user ID
   
   **Returns:** `array|null` - User data or null if not found
   
   **⚠️ Deprecated:** Use getUserDetails instead
   ```

#### 5.2 Method with Psalm Annotations
1. Hover over `getUserDetails`
2. **Expected**: Shows Psalm type annotation:
   ```markdown
   ```php
   public function getUserDetails(int $id): array
   ```
   
   Get detailed user information
   
   **Parameters:**
   - `$id` (int): The user ID
   
   **Returns:** `array` - User details
   
   **Psalm Type:** `array{id: int, name: string, email: string}`
   ```

#### 5.3 Method with Template Tags
1. Hover over `getDetails` in `UserService`
2. **Expected**: Shows template information:
   ```markdown
   ```php
   public function getDetails(int $id): array
   ```
   
   **Template:** `T of User`
   ```

**Response Time**: <100ms

**Verification**:
```bash
# Check hover logs
grep "Rendered hover.*for" /tmp/php-lsp.log
# Should show: "Rendered hover for getUser with PHPDoc in 15ms"
```

---

## Performance Testing

### Workspace Indexing Performance

**Goal**: Verify 1000-file workspace indexes within 30 seconds

**Steps**:
1. Generate test workspace:
   ```bash
   for i in {1..1000}; do
     mkdir -p src/Generated
     echo "<?php namespace App\\Generated; class Class${i} {}" > src/Generated/Class${i}.php
   done
   ```

2. Start LSP server with tracing enabled

3. Wait for indexing to complete

4. Check logs:
   ```bash
   grep "Workspace indexing complete" /tmp/php-lsp.log
   ```

**Expected**:
- Total time: <30 seconds
- Memory usage: <8GB (check with `ps aux | grep php-lsp`)
- No blocked LSP messages during indexing

**Verification**:
```bash
# Memory usage
ps aux | grep php-lsp | awk '{print $6/1024 " MB"}'
# Should be <8000 MB

# Indexing time
grep -A 1 "Starting workspace indexing" /tmp/php-lsp.log
# Should show completion within 30s
```

---

## Troubleshooting

### Symbols Not Appearing
- Check if file is opened (`didOpen` notification sent)
- Verify tree-sitter parsing succeeded (check logs for parse errors)
- Ensure file is saved (some editors only send content on save)

### Go-to-Definition Not Working
- Verify composer.json exists and is valid
- Check PSR-4 namespace matches directory structure
- Look for resolution errors in logs

### Fuzzy Search Returns No Results
- Ensure workspace indexing completed
- Check indexing status logs
- Verify search query doesn't have typos beyond fuzzy tolerance

### Hover Shows No Documentation
- Check if PHPDoc comment exists and is well-formed
- Verify comment is immediately before symbol (no blank lines)
- Check logs for PHPDoc parse errors

---

## Success Criteria Checklist

- [ ] Document symbols response within 100ms
- [ ] Workspace symbol search within 500ms for 1000 files
- [ ] Go-to-definition accuracy: 95%+ for valid references
- [ ] Find-references returns all usage sites within 3 seconds
- [ ] Hover displays formatted PHPDoc within 100ms
- [ ] Background indexing completes within 30 seconds for 1000 files
- [ ] Memory usage stays under 8GB
- [ ] No LSP request blocking during indexing

---

## Logs and Debugging

**Enable detailed logging**:
```bash
export RUST_LOG=php_lsp=debug
./target/release/php-lsp 2>&1 | tee /tmp/php-lsp.log
```

**Key log patterns to look for**:
- `Extracted N symbols from file in Xms`
- `Indexed K/N files`
- `Workspace indexing complete: N files`
- `Fuzzy search for 'query' returned N results in Xms`
- `Resolved FQN to file path in Xms`
- `Found N references for symbol in Xms`
- `Rendered hover for symbol in Xms`

**Common issues**:
- Parse errors → Check PHP syntax, ensure PHP 8+ code
- Missing symbols → Verify tree-sitter-php version supports PHP 8 syntax
- Slow indexing → Profile with cargo flamegraph
- High memory → Check for memory leaks with valgrind
