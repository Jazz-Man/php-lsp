<!-- 
Sync Impact Report:
- Version change: 1.0.0 → 1.1.0
- Modified principles: None (new principles added)
- Added sections: Core Principles (6), Stack, Quality
- Removed sections: None
- Templates requiring updates: N/A (new constitution)
- Follow-up TODOs: None
-->
# PHP LSP Server in Rust Constitution

## Core Principles

### I. Async Non-blocking Handlers
All LSP request handlers must operate asynchronously without blocking the main thread. Use async/await patterns with tokio for concurrency. This ensures responsive performance during intensive parsing or analysis operations.

### II. PHP 8+ Default with Composer.json Detection
The server defaults to PHP 8+ support but must detect and adapt to the PHP version specified in composer.json. This enables accurate language feature analysis based on the project's actual PHP version.

### III. PHPDoc Parsing and Annotation Support
Comprehensive parsing of PHPDoc annotations including @param, @return, @var, @template, and static analysis annotations from Psalm and PHPStan. This enables rich code intelligence based on documented type information.

### IV. WordPress Hooks Integration
Full support for WordPress hooks: add_action, add_filter, do_action, and apply_filters with go-to-definition functionality. This provides specialized language support for the WordPress ecosystem.

### V. Incremental Parsing with Memory Efficiency
Implement incremental parsing to efficiently handle large PHP files and projects. Prioritize memory-efficient parsing algorithms to maintain performance across large codebases.

### VI. Extension Warning System
Detect and warn when PHP extensions (ext-*) are used without being declared in composer.json. This helps maintain consistency between code and dependency declarations.

## Stack Requirements
- **Language**: Rust 2024 edition
- **LSP Framework**: async-lsp 0.2.2 with tokio runtime
- **Parser**: tree-sitter-php 0.24.2 for accurate PHP syntax analysis
- **Middleware**: tower for request processing and service composition
- **Architecture**: Non-blocking async handlers with concurrent request processing

## Quality Standards
- **Testing**: Comprehensive test coverage for each feature with unit and integration tests
- **Error Handling**: No panics allowed - use proper Result types and error propagation
- **Observability**: Structured tracing logs for debugging and performance monitoring
- **Documentation**: All public APIs must be documented with examples and usage patterns
- **Performance**: Optimized for speed and memory efficiency, especially for large PHP projects

## Governance
This constitution guides all development decisions for the PHP LSP server. All code changes must align with these principles. Versioning follows semantic versioning (MAJOR.MINOR.PATCH). Amendments require clear justification and documented review.

**Version**: 1.1.0 | **Ratified**: 2025-06-13 | **Last Amended**: 2025-12-02