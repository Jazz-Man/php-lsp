#!/bin/bash
# setup-multi-agent.sh
# Налаштовує спільну папку .ai/ для роботи з різними AI агентами
# (Claude Code, Qwen Code, Gemini CLI, etc.)

set -e

# Кольори
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Setting up multi-agent development environment...${NC}"
echo ""

# 1. Створити базову структуру .ai/
echo -e "${BLUE}[1/5] Creating .ai/ structure...${NC}"
mkdir -p .ai/{commands,context,prompts}

# 2. Список агентів для налаштування
AGENTS=("claude" "qwen" "gemini")
CONTEXT_FILES=("CLAUDE.md" "QWEN.md" "GEMINI.md")

# 3. Зібрати існуючі команди з усіх агентів в .ai/commands
echo -e "${BLUE}[2/5] Collecting existing commands...${NC}"
for agent in "${AGENTS[@]}"; do
    if [ -d ".$agent/commands" ] && [ ! -L ".$agent/commands" ]; then
        echo "  Found commands in .$agent/commands, copying to .ai/commands/"
        cp -rn ".$agent/commands/"* .ai/commands/ 2>/dev/null || true
    fi
done

# 4. Налаштувати symlinks для кожного агента
echo -e "${BLUE}[3/5] Setting up agent symlinks...${NC}"
for i in "${!AGENTS[@]}"; do
    agent="${AGENTS[$i]}"
    context_file="${CONTEXT_FILES[$i]}"

    echo "  Setting up .$agent/"
    mkdir -p ".$agent"

    # Видалити стару папку/symlink commands
    if [ -L ".$agent/commands" ]; then
        rm ".$agent/commands"
    elif [ -d ".$agent/commands" ]; then
        rm -rf ".$agent/commands"
    fi

    # Створити symlink
    ln -sf ../.ai/commands ".$agent/commands"

    # Symlink для контекстного файлу
    if [ -f ".ai/context/PROJECT.md" ]; then
        if [ -L "$context_file" ]; then
            rm "$context_file"
        fi
        ln -sf .ai/context/PROJECT.md "$context_file"
    fi
done

# 5. Створити PROJECT.md якщо не існує
echo -e "${BLUE}[4/5] Creating PROJECT.md template...${NC}"
if [ ! -f ".ai/context/PROJECT.md" ]; then
    cat > .ai/context/PROJECT.md << 'EOF'
# Project Context

<!-- This file is shared across all AI agents (Claude, Qwen, Gemini, etc.) -->
<!-- Symlinked as CLAUDE.md, QWEN.md, GEMINI.md in project root -->

## Overview
[Describe your project here]

## Tech Stack
[List technologies]

## Key Commands
- `/constitution` - Create project principles
- `/specify` - Define feature specifications
- `/plan` - Create technical plans
- `/tasks` - Generate task lists
- `/implement` - Execute implementation

## Notes
[Any additional context for AI agents]
EOF
    echo "  Created .ai/context/PROJECT.md"
else
    echo "  PROJECT.md already exists, skipping"
fi

# 6. Оновити .gitignore
echo -e "${BLUE}[5/5] Updating .gitignore...${NC}"
if [ -f ".gitignore" ]; then
    # Перевірити чи вже є записи
    if ! grep -q "# AI Agent settings" .gitignore 2>/dev/null; then
        cat >> .gitignore << 'EOF'

# AI Agent settings (may contain API keys)
.claude/settings.json
.qwen/settings.json
.gemini/settings.json
.ai/**/settings.json
EOF
        echo "  Updated .gitignore"
    else
        echo "  .gitignore already configured"
    fi
else
    echo "  No .gitignore found, skipping"
fi

# Результат
echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Structure:"
echo "  .ai/"
echo "  ├── commands/      <- shared commands (source of truth)"
echo "  ├── context/       <- shared project context"
echo "  │   └── PROJECT.md"
echo "  └── prompts/       <- saved prompts (optional)"
echo ""
echo "  .claude/commands   -> ../.ai/commands (symlink)"
echo "  .qwen/commands     -> ../.ai/commands (symlink)"
echo "  .gemini/commands   -> ../.ai/commands (symlink)"
echo ""
echo "  CLAUDE.md          -> .ai/context/PROJECT.md (symlink)"
echo "  QWEN.md            -> .ai/context/PROJECT.md (symlink)"
echo "  GEMINI.md          -> .ai/context/PROJECT.md (symlink)"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Edit .ai/context/PROJECT.md with your project details"
echo "  2. Add your command files to .ai/commands/"
echo "  3. Run: claude, qwen, or gemini"
