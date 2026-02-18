# wopr-claude-hooks

Claude Code hooks configuration for the WOPR project — automates formatting, linting, and coordination on file save and session events.

## Structure

```
hooks.json     # Claude Code hooks configuration
```

## Key Details

- `hooks.json` is the Claude Code hooks config — defines what runs on pre-edit, post-edit, session-start, etc.
- Hooks automate: Biome format/lint on file save, session state persistence, swarm coordination
- Changes here affect ALL Claude Code agents working in WOPR repos
- **Gotcha**: A broken hook script will silently fail or block operations. Test hook scripts before committing.

## Issue Tracking

All issues in **Linear** (team: WOPR). Issue descriptions start with `**Repo:** wopr-network/wopr-claude-hooks`.
