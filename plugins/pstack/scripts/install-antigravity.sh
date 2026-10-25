#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AGY_BIN="${AGY_BIN:-$(command -v agy || echo /Users/jasonholt/.local/bin/agy)}"

echo "Validating pstack plugin at $PLUGIN_DIR..."
"$AGY_BIN" plugin validate "$PLUGIN_DIR" --strict

echo "Installing pstack plugin into ~/.gemini/config/plugins/pstack..."
env -u GEMINI_HOME "$AGY_BIN" plugin install "$PLUGIN_DIR"

for t3_home in "$HOME"/.t3/userdata/providers/antigravity/*; do
  [ -d "$t3_home" ] || continue
  echo "Installing pstack plugin into $t3_home/config/plugins/pstack..."
  GEMINI_HOME="$t3_home" "$AGY_BIN" plugin install "$PLUGIN_DIR"
  mkdir -p "$t3_home/config/rules"
  if [ ! -f "$t3_home/config/rules/pstack-models.md" ]; then
    {
      echo "---"
      echo "trigger: always_on"
      echo "description: pstack per-role model choices (overrides skill defaults)"
      echo "---"
      cat "$SCRIPT_DIR/pstack-models.default.md"
    } > "$t3_home/config/rules/pstack-models.md"
  fi
done

SKILLS_DST="$HOME/.gemini/config/skills"
mkdir -p "$SKILLS_DST"
for skill_path in "$PLUGIN_DIR"/skills/*; do
  [ -d "$skill_path" ] || continue
  skill_name="$(basename "$skill_path")"
  rm -rf "${SKILLS_DST:?}/$skill_name"
  cp -R "$skill_path" "$SKILLS_DST/$skill_name"
done
echo "Synced $(ls -1d "$PLUGIN_DIR"/skills/* | wc -l | tr -d ' ') skills into $SKILLS_DST."

if [ ! -f "$HOME/.gemini/pstack-models.md" ]; then
  cp "$SCRIPT_DIR/pstack-models.default.md" "$HOME/.gemini/pstack-models.md"
  echo "Created default $HOME/.gemini/pstack-models.md."
fi

RULES_DIR="$HOME/.gemini/config/rules"
mkdir -p "$RULES_DIR"
if [ ! -f "$RULES_DIR/pstack-models.md" ]; then
  {
    echo "---"
    echo "trigger: always_on"
    echo "description: pstack per-role model choices (overrides skill defaults)"
    echo "---"
    cat "$SCRIPT_DIR/pstack-models.default.md"
  } > "$RULES_DIR/pstack-models.md"
  echo "Created default $RULES_DIR/pstack-models.md."
fi

echo "Done. Run 'agy plugin list' or '/setup-pstack' in Antigravity."
