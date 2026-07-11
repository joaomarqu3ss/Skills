#!/usr/bin/env bash
# diff-stats.sh — Extract structured diff statistics for code review
#
# Usage:
#   ./diff-stats.sh [diff-range]
#
# Examples:
#   ./diff-stats.sh main..HEAD
#   ./diff-stats.sh abc123
#   ./diff-stats.sh              # defaults to staged + unstaged
#
# Output: Formatted summary of changes with per-file stats and hotspots.

set -euo pipefail

DIFF_RANGE="${1:-}"

# Get diff stat
if [[ -z "$DIFF_RANGE" ]]; then
  STAT=$(git diff --stat HEAD 2>/dev/null || git diff --stat)
  NUMSTAT=$(git diff --numstat HEAD 2>/dev/null || git diff --numstat)
  SHORT=$(git diff --shortstat HEAD 2>/dev/null || git diff --shortstat)
else
  STAT=$(git diff --stat "$DIFF_RANGE" 2>/dev/null || git show --stat --format='' "$DIFF_RANGE" 2>/dev/null || echo "")
  NUMSTAT=$(git diff --numstat "$DIFF_RANGE" 2>/dev/null || git show --numstat --format='' "$DIFF_RANGE" 2>/dev/null || echo "")
  SHORT=$(git diff --shortstat "$DIFF_RANGE" 2>/dev/null || git show --shortstat --format='' "$DIFF_RANGE" 2>/dev/null || echo "")
fi

echo "============================================"
echo "  DIFF STATISTICS"
echo "  Range: ${DIFF_RANGE:-working tree}"
echo "============================================"
echo ""

# Overall summary
echo "## Summary"
echo "$SHORT"
echo ""

# Per-file breakdown sorted by churn (most changed first)
echo "## Per-File Breakdown (sorted by churn)"
echo ""
printf "%-8s %-8s %-8s %s\n" "Added" "Removed" "Total" "File"
printf "%-8s %-8s %-8s %s\n" "-----" "-------" "-----" "----"

if [[ -n "$NUMSTAT" ]]; then
  echo "$NUMSTAT" | while IFS=$'\t' read -r added removed file; do
    [[ -z "$file" ]] && continue
    # Handle binary files
    if [[ "$added" == "-" ]]; then
      added="bin"
      removed="bin"
      total="bin"
    else
      total=$((added + removed))
    fi
    printf "%-8s %-8s %-8s %s\n" "+$added" "-$removed" "$total" "$file"
  done | sort -t' ' -k3 -rn 2>/dev/null || true
fi

echo ""

# Hotspot detection: files with >100 lines changed
echo "## Hotspots (>100 lines changed)"
echo ""
hotspot_found=false
if [[ -n "$NUMSTAT" ]]; then
  echo "$NUMSTAT" | while IFS=$'\t' read -r added removed file; do
    [[ -z "$file" ]] && continue
    [[ "$added" == "-" ]] && continue
    total=$((added + removed))
    if [[ $total -gt 100 ]]; then
      hotspot_found=true
      echo "  ⚠️  $file ($total lines changed)"
    fi
  done
fi
if [[ "$hotspot_found" == false ]]; then
  echo "  None detected."
fi

echo ""

# File type breakdown
echo "## File Types Changed"
echo ""
if [[ -n "$NUMSTAT" ]]; then
  echo "$NUMSTAT" | while IFS=$'\t' read -r _ _ file; do
    [[ -z "$file" ]] && continue
    ext="${file##*.}"
    if [[ "$ext" == "$file" ]]; then
      echo "no-extension"
    else
      echo ".$ext"
    fi
  done | sort | uniq -c | sort -rn | while read -r count ext; do
    printf "  %4d  %s\n" "$count" "$ext"
  done
fi

echo ""

# New files vs modified vs deleted
echo "## Change Types"
if [[ -z "$DIFF_RANGE" ]]; then
  new=$(git diff --diff-filter=A --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')
  modified=$(git diff --diff-filter=M --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')
  deleted=$(git diff --diff-filter=D --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')
  renamed=$(git diff --diff-filter=R --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')
else
  new=$(git diff --diff-filter=A --name-only "$DIFF_RANGE" 2>/dev/null | wc -l | tr -d ' ')
  modified=$(git diff --diff-filter=M --name-only "$DIFF_RANGE" 2>/dev/null | wc -l | tr -d ' ')
  deleted=$(git diff --diff-filter=D --name-only "$DIFF_RANGE" 2>/dev/null | wc -l | tr -d ' ')
  renamed=$(git diff --diff-filter=R --name-only "$DIFF_RANGE" 2>/dev/null | wc -l | tr -d ' ')
fi
echo "  Added:    $new"
echo "  Modified: $modified"
echo "  Deleted:  $deleted"
echo "  Renamed:  $renamed"
echo ""
