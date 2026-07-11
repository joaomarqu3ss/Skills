#!/usr/bin/env bash
# extract-layer-diff.sh — Extract the actual diff for a specific layer's files
#
# Usage:
#   ./extract-layer-diff.sh <diff-range> <file1> [file2] [file3] ...
#   ./extract-layer-diff.sh main..HEAD src/services/auth.ts src/services/user.ts
#
# Output: The git diff for only the specified files, ready for a subagent to review.

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <diff-range> <file1> [file2] ..."
  echo ""
  echo "Extract the diff for specific files from a git range."
  echo "Use '--' as diff-range for staged+unstaged changes."
  exit 1
fi

DIFF_RANGE="$1"
shift
FILES=("$@")

echo "============================================"
echo "  LAYER DIFF EXTRACT"
echo "  Range: $DIFF_RANGE"
echo "  Files: ${#FILES[@]}"
echo "============================================"
echo ""

for file in "${FILES[@]}"; do
  echo "────────────────────────────────────────────"
  echo "  📄 $file"
  echo "────────────────────────────────────────────"

  if [[ "$DIFF_RANGE" == "--" ]]; then
    diff_output=$(git diff HEAD -- "$file" 2>/dev/null || git diff -- "$file" 2>/dev/null || echo "")
  else
    diff_output=$(git diff "$DIFF_RANGE" -- "$file" 2>/dev/null || echo "")
  fi

  if [[ -z "$diff_output" ]]; then
    echo "  (no diff — file may be new/untracked or unchanged)"
    # Show full content for new files
    if [[ -f "$file" ]]; then
      echo "  [NEW FILE — showing content]"
      echo ""
      cat "$file"
    fi
  else
    echo "$diff_output"
  fi
  echo ""
done

# Summary
echo "============================================"
echo "  Total files in this layer: ${#FILES[@]}"
total_added=0
total_removed=0
for file in "${FILES[@]}"; do
  if [[ "$DIFF_RANGE" == "--" ]]; then
    stats=$(git diff --numstat HEAD -- "$file" 2>/dev/null || git diff --numstat -- "$file" 2>/dev/null || echo "0	0	$file")
  else
    stats=$(git diff --numstat "$DIFF_RANGE" -- "$file" 2>/dev/null || echo "0	0	$file")
  fi
  added=$(echo "$stats" | awk '{print $1}')
  removed=$(echo "$stats" | awk '{print $2}')
  [[ "$added" == "-" ]] && added=0
  [[ "$removed" == "-" ]] && removed=0
  total_added=$((total_added + added))
  total_removed=$((total_removed + removed))
done
echo "  Lines added:   +$total_added"
echo "  Lines removed: -$total_removed"
echo "============================================"
