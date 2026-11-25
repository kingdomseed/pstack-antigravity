#!/usr/bin/env bash
set -euo pipefail

RESET_MODELS=0
if [ "${1:-}" = "--reset-models" ]; then
  RESET_MODELS=1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AGY_BIN="${AGY_BIN:-$(command -v agy || echo "$HOME/.local/bin/agy")}"

write_model_rule() {
  local dst="$1"
  {
    echo "---"
    echo "trigger: always_on"
    echo "description: pstack per-role model choices (overrides skill defaults)"
    echo "---"
    cat "$SCRIPT_DIR/pstack-models.default.md"
  } > "$dst"
}

echo "Validating pstack plugin at $PLUGIN_DIR..."
"$AGY_BIN" plugin validate "$PLUGIN_DIR" --strict

echo "Installing pstack plugin into ~/.gemini/config/plugins/pstack..."
env -u GEMINI_HOME "$AGY_BIN" plugin install "$PLUGIN_DIR"
find "$HOME/.gemini/config/plugins/pstack" -name node_modules -type d -prune -exec rm -rf {} +

# Remove duplicate loose pstack skill copies from ~/.gemini/config/skills so
# Antigravity never shows duplicate slash commands alongside the plugin.
# Standalone non-pstack skills (e.g. cua-driver, instabox*) are preserved.
SKILLS_DST="$HOME/.gemini/config/skills"
if [ -d "$SKILLS_DST" ]; then
  removed_dups=0
  for skill_path in "$PLUGIN_DIR"/skills/*; do
    [ -d "$skill_path" ] || continue
    skill_name="$(basename "$skill_path")"
    dup_path="$SKILLS_DST/$skill_name"
    if [ -e "$dup_path" ] || [ -L "$dup_path" ]; then
      rm -rf "$dup_path"
      removed_dups=$((removed_dups + 1))
    fi
  done
  if [ "$removed_dups" -gt 0 ]; then
    echo "Removed $removed_dups duplicate pstack skill folders from $SKILLS_DST."
  fi
fi

shopt -s nullglob
for t3_home in "$HOME"/.t3/userdata/providers/antigravity/*; do
  [ -d "$t3_home/config" ] || continue
  if [ ! -e "$t3_home/config/plugins" ] && [ ! -L "$t3_home/config/plugins" ]; then
    ln -s "$HOME/.gemini/config/plugins" "$t3_home/config/plugins"
    echo "Linked $t3_home/config/plugins -> $HOME/.gemini/config/plugins."
  fi
  mkdir -p "$t3_home/config/rules"
  if [ "$RESET_MODELS" -eq 1 ] || [ ! -f "$t3_home/config/rules/pstack-models.md" ]; then
    write_model_rule "$t3_home/config/rules/pstack-models.md"
    echo "Wrote $t3_home/config/rules/pstack-models.md."
  fi
done

if [ "$RESET_MODELS" -eq 1 ] || [ ! -f "$HOME/.gemini/pstack-models.md" ]; then
  cp "$SCRIPT_DIR/pstack-models.default.md" "$HOME/.gemini/pstack-models.md"
  echo "Wrote $HOME/.gemini/pstack-models.md."
fi

RULES_DIR="$HOME/.gemini/config/rules"
mkdir -p "$RULES_DIR"
if [ "$RESET_MODELS" -eq 1 ] || [ ! -f "$RULES_DIR/pstack-models.md" ]; then
  write_model_rule "$RULES_DIR/pstack-models.md"
  echo "Wrote $RULES_DIR/pstack-models.md."
fi

echo "Done. Run 'agy plugin list' or '/setup-pstack' in Antigravity."
