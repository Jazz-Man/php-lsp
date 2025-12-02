# PHP Language Server Protocol (LSP) Server

A fast and lightweight Language Server for PHP, written in Rust. This tool makes writing PHP code more enjoyable in any code editor.

## What is this?

This is a program that runs in the background and helps you write PHP code faster with fewer errors. It shows you suggestions, finds mistakes, helps you navigate to function definitions, and much more.

## Why am I building this?

### Personal motivation
I've long dreamed of writing my own Language Server in Rust. I'm not satisfied with the current state of PHP support in existing tools:

- **Intelephense** - powerful but feels heavy and opaque inside
- **PHPStorm** - popular but resource-intensive and costs money
- **Other LSPs** - often lack comprehensive PHP or WordPress support

I want something lightweight, understandable, and customizable to my needs.

### Saving money and time
- **Licenses**: No more paying $100-200/year for PhpStorm or $40-100/year for Intelephense
- **Speed**: Optimized for my workflow and specific projects
- **Control**: I can modify and improve it however I want
- **WordPress**: Full WordPress hooks support without extra fees

## What I'm using to build it

- **Rust** - fast and reliable programming language
- **async-lsp** - library for creating Language Servers
- **tree-sitter** - fast parser for PHP code
- **spec-kit-plus** - tool for specification-driven development
- **Zed Editor** - primary editor for testing

## What it can or will be able to do

### Core features
- **Error detection** - shows syntax errors and code issues
- **Auto-completion** - suggests function names, variables, classes
- **Navigation** - jump to function definitions, find usage
- **Hover info** - shows function information when you hover over it
- **Parameter hints** - suggests function parameters while typing

### PHP-specific features
- **PHP versions** - automatically detects which PHP version you're using from composer.json
- **PHPDoc** - reads and uses code comments for better suggestions
- **Extensions** - warns if you're using extensions not declared in composer.json
- **Frameworks** - special WordPress support (planning Laravel, Symfony)

### WordPress integration
- Auto-completion for hooks, actions, and filters
- Navigate from hook usage to its definition
- Suggestions for standard WordPress functions
- Recognition of custom hooks in your code

## My roadmap

### Phase 1: Foundation
- Basic LSP protocol support
- PHP code parsing
- Simple suggestions and error detection

### Phase 2: Core features
- Go-to-definition
- Hover information
- Document symbol list

### Phase 3: WordPress and frameworks
- Full WordPress hooks system support
- Cross-file navigation
- PHP version-specific features

### Phase 4: Advanced features
- Project-wide search
- Static analyzer integration
- Performance optimization

## Current status

**Early development** - The project is actively being developed. The LSP server isn't ready for use yet, but the architecture and foundation are being built.

## License

This project will be open source. License details will be added later.

---

*Built with ❤️ in Rust for the PHP community*
