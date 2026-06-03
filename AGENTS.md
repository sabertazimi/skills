# AGENTS.md

This file provides guidance to coding agents when working with code in this repository.

## Project Overview

A Claude Code plugin package (`sabertaz`) providing custom skills and hooks.
The plugin is installed via `claude plugin install sabertaz@sabertaz`
and distributed through a marketplace registry in `.claude-plugin/marketplace.json`.

## Architecture

**Plugin manifest**: `.claude-plugin/plugin.json` defines identity and metadata. The marketplace registry at `.claude-plugin/marketplace.json` points to `./` as the plugin source.

**Skills** (`skills/` directory): Each skill lives in its own subdirectory containing a `SKILL.md` file. SKILL.md uses YAML frontmatter (`name`, `description`, `allowed-tools`, `license`) followed by a Markdown body that defines the skill's workflow and rules. Skills are invoked by Claude Code when the user's request matches the skill's trigger description.

**Hooks** (`hooks/` directory): `hooks.json` subscribes to Claude Code lifecycle events (`Stop`, `Notification`) and routes them to `notify.sh`, which sends Linux desktop notifications via `notify-send`. The script reads event JSON from stdin, parses it with `jq` (or falls back to grep-based detection), and truncates messages to 200 characters.

## Commit Conventions

This project follows Conventional Commits.
When committing, **never add co-author lines or mention any agent** (Claude Code, Cursor, etc.) in commit messages.
