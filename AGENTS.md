# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## Repository Overview

This is a **Claude Code Plugin Marketplace**:
a personal collection of custom skills/plugins for Claude Code.
The repository distributes plugins through Claude Code's marketplace system.

**Project Type:** Static configuration/documentation repository (no build system, no compilation)

**Repository:** [sabertazimi/skills](https://github.com/sabertazimi/skills)

**License:** [MIT](./LICENSE)

## Architecture

### Directory Structure

```plaintext
├── .claude-plugin/          # Plugin configuration (required by Claude Code)
│   ├── marketplace.json     # Marketplace distribution metadata
│   └── plugin.json          # Plugin definition and metadata
├── hooks/                   # Claude Code hooks configuration
│   └── hooks.json           # System notification hooks
├── skills/                  # Custom skills directory
│   └── generating-commits/  # Example skill implementation
│       └── SKILL.md         # Skill definition (YAML frontmatter + markdown)
├── LICENSE                  # MIT License
└── README.md                # Project description
```

### Plugin System

**Plugin Configuration (.claude-plugin/):**

- `plugin.json` - Defines plugin identity (name, version, author, repository)
- `marketplace.json` - Links plugin to marketplace distribution

**Hooks Directory (hooks/):**

- `hooks.json` - Defines hooks that execute at specific Claude Code events
- Currently configured for system notifications (Notification, Stop events)
- Supports platform-specific commands (Windows, macOS, Linux)

**Skills Directory (skills/):**

- Each skill is a self-contained directory with a `SKILL.md` file
- Skills use YAML frontmatter for metadata (name, description, allowed-tools, license)
- Markdown body contains documentation and workflow instructions
- Skills are triggered by specific user commands or phrases
- The `allowed-tools` field restricts which tools the skill may use

### Skill Structure

Each `SKILL.md` file follows this format:

```yaml
---
name: Skill Name
description: When to activate this skill
allowed-tools: Tool1(pattern*), Tool2(pattern*)
license: MIT
---

# Skill Name

Documentation and workflow instructions here.
```

**Current Skills:**

- `generating-commits` - Generates Conventional Commits messages, triggered by "commit" or "git commit"

## Development Workflow

### Adding a New Skill

1. Create a new directory under `skills/<skill-name>/`
2. Create a `SKILL.md` file with:
   - YAML frontmatter (name, description, allowed-tools, license)
   - Clear documentation on when and how to use the skill
   - Step-by-step workflow instructions
3. Update plugin.json if needed (version bump for releases)

### Testing Skills

Skills are loaded by Claude Code through the plugin marketplace. To test:

- Ensure the plugin is properly installed via Claude Code's plugin system
- Trigger the skill using the defined command phrases
- Verify the skill follows its documented workflow

### Git Workflow

No automated build or test commands. Use standard git operations:

```bash
git status          # Check current state
git add <files>     # Stage specific files
git commit          # Create commits
git push            # Push to remote
```

**Note:** When committing, the repository includes a `generating-commits` skill that generates Conventional Commits messages. Type "commit" to activate it.

## Important Constraints

- **Skill isolation** - Each skill is independent; no interdependencies
- **Tool restrictions** - Skills may limit tool usage via `allowed-tools` in YAML frontmatter
- **YAML frontmatter required** - All `SKILL.md` files must have valid YAML metadata
