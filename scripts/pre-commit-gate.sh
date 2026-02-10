#!/bin/bash
# pre-commit-gate.sh — Block git commit if lint or type-check fail
# Runs on every Bash tool call, but only gates "git commit" commands
set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only gate git commit commands
if ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
  exit 0
fi

# Detect package manager
if [ -f "bun.lockb" ]; then
  PM="bun"
elif [ -f "pnpm-lock.yaml" ]; then
  PM="pnpm"
elif [ -f "yarn.lock" ]; then
  PM="yarn"
else
  PM="npm"
fi
RUN="$PM run"

# --- If repo has a "check" script (biome + tsc combined), use it ---
if jq -e '.scripts["check"]' package.json >/dev/null 2>&1; then
  CHECK_OUTPUT=$($RUN check 2>&1) || {
    echo "Quality gate failed ('$PM run check'):" >&2
    echo "$CHECK_OUTPUT" | tail -30 >&2
    exit 2
  }
  exit 0
fi

# --- Otherwise, run biome and tsc separately ---

# Biome lint (if available)
if [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then
  if jq -e '.scripts["lint"]' package.json >/dev/null 2>&1; then
    LINT_OUTPUT=$($RUN lint 2>&1) || {
      echo "Biome lint failed. Run '$PM run lint:fix' first:" >&2
      echo "$LINT_OUTPUT" | tail -20 >&2
      exit 2
    }
  else
    LINT_OUTPUT=$(npx biome check src/ 2>&1) || {
      echo "Biome check failed. Run 'npx biome check --fix src/' first:" >&2
      echo "$LINT_OUTPUT" | tail -20 >&2
      exit 2
    }
  fi
fi

# TypeScript type check
TSC_OUTPUT=$(npx tsc --noEmit 2>&1) || {
  echo "TypeScript errors. Fix before committing:" >&2
  echo "$TSC_OUTPUT" | tail -20 >&2
  exit 2
}

exit 0
