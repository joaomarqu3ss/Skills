#!/usr/bin/env bash
# classify-changes.sh — Classify changed files into architectural layers
#
# Usage:
#   ./classify-changes.sh [diff-range] [--config path/to/layer-map.json]
#
# Examples:
#   ./classify-changes.sh main..HEAD
#   ./classify-changes.sh abc123
#   ./classify-changes.sh                    # defaults to staged + unstaged changes
#   ./classify-changes.sh --config .layermap.json main..HEAD
#
# Output: JSON with files grouped by layer, ready for the agent to consume.

set -euo pipefail

CONFIG_FILE=""
DIFF_RANGE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)
      CONFIG_FILE="$2"
      shift 2
      ;;
    *)
      DIFF_RANGE="$1"
      shift
      ;;
  esac
done

# Get changed files
if [[ -z "$DIFF_RANGE" ]]; then
  # No range: show staged + unstaged + untracked
  FILES=$(git diff --name-only HEAD 2>/dev/null || git diff --name-only)
  UNSTAGED=$(git diff --name-only 2>/dev/null || true)
  UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null || true)
  FILES=$(printf '%s\n%s\n%s' "$FILES" "$UNSTAGED" "$UNTRACKED" | sort -u | grep -v '^$' || true)
else
  FILES=$(git diff --name-only "$DIFF_RANGE" 2>/dev/null || git show --name-only --format='' "$DIFF_RANGE" 2>/dev/null || echo "")
fi

if [[ -z "$FILES" ]]; then
  echo '{"error": "No changed files found", "layers": {}}'
  exit 0
fi

# Default layer classification patterns
# These can be overridden by a .layermap.json config file
classify_file() {
  local file="$1"
  local basename
  basename=$(basename "$file")
  local dir
  dir=$(dirname "$file")

  # If a config file is provided, use it (simple JSON pattern matching)
  if [[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]]; then
    # Config-based classification is handled by the agent reading the JSON
    # Here we just output the file for manual mapping
    echo "custom"
    return
  fi

  # --- Test layer (check first — tests can live anywhere) ---
  if [[ "$file" =~ (test|tests|spec|specs|__tests__|__mocks__|fixtures|factories)/ ]] ||
     [[ "$basename" =~ \.(test|spec)\. ]] ||
     [[ "$basename" =~ ^test_ ]] ||
     [[ "$basename" =~ _test\. ]]; then
    echo "tests"
    return
  fi

  # --- Infrastructure & Config layer ---
  if [[ "$file" =~ ^(\.github|\.gitlab|\.circleci|\.jenkins|ci|\.docker|infra|infrastructure|terraform|pulumi|k8s|kubernetes|helm|deploy|scripts|bin)/ ]] ||
     [[ "$basename" =~ ^(Dockerfile|docker-compose|Makefile|Procfile|Vagrantfile|Jenkinsfile)$ ]] ||
     [[ "$basename" =~ ^(\.)?(env|gitignore|dockerignore|editorconfig|eslintrc|prettierrc|tsconfig|babel\.config|jest\.config|vitest\.config|webpack\.config|vite\.config|rollup\.config|nginx\.conf) ]] ||
     [[ "$basename" =~ \.(ya?ml|toml|ini|cfg)$ && "$dir" =~ ^(\.|\./|config|conf|deploy|infra|\.github) ]] ||
     [[ "$basename" =~ ^(package\.json|package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Gemfile|Gemfile\.lock|Cargo\.toml|Cargo\.lock|go\.mod|go\.sum|requirements\.txt|pyproject\.toml|poetry\.lock|pom\.xml|build\.gradle|settings\.gradle|composer\.json|composer\.lock)$ ]]; then
    echo "infra"
    return
  fi

  # --- Persistence / Data layer ---
  if [[ "$file" =~ (migration|migrations|migrate|schema|seed|seeds|model|models|entity|entities|repository|repositories|dao|DAO|orm|prisma|typeorm|sequelize|knex|alembic|flyway|liquibase)/ ]] ||
     [[ "$basename" =~ ^(schema|migration|seed) ]] ||
     [[ "$file" =~ (\.sql|\.prisma)$ ]] ||
     [[ "$dir" =~ (db|database|data|persistence|store|cache|redis) ]]; then
    echo "persistence"
    return
  fi

  # --- API & Routes layer ---
  if [[ "$file" =~ (controller|controllers|route|routes|router|routers|handler|handlers|endpoint|endpoints|middleware|middlewares|api|rest|graphql|grpc|proto|dto|dtos|serializer|serializers|resolver|resolvers)/ ]] ||
     [[ "$basename" =~ (controller|handler|route|router|middleware|endpoint|resolver)\. ]] ||
     [[ "$file" =~ \.proto$ ]]; then
    echo "api"
    return
  fi

  # --- Business Logic / Services layer (default for code files) ---
  if [[ "$file" =~ (service|services|usecase|usecases|use-case|use-cases|domain|core|lib|src|app|business|logic|util|utils|helper|helpers|command|commands|query|queries|event|events|job|jobs|worker|workers|task|tasks)/ ]] ||
     [[ "$basename" =~ \.(js|ts|tsx|jsx|py|rb|go|rs|java|kt|cs|php|ex|exs|clj|scala|swift|dart)$ ]]; then
    echo "services"
    return
  fi

  # --- Fallback ---
  echo "unclassified"
}

# Build JSON output
echo '{'
echo '  "diff_range": "'"${DIFF_RANGE:-working tree}"'",'
echo '  "total_files": '"$(echo "$FILES" | wc -l | tr -d ' ')"','
echo '  "layers": {'

declare -A LAYER_FILES
LAYERS=("api" "services" "persistence" "tests" "infra" "unclassified")

for layer in "${LAYERS[@]}"; do
  LAYER_FILES[$layer]=""
done

while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  layer=$(classify_file "$file")
  if [[ -n "${LAYER_FILES[$layer]}" ]]; then
    LAYER_FILES[$layer]="${LAYER_FILES[$layer]},$file"
  else
    LAYER_FILES[$layer]="$file"
  fi
done <<< "$FILES"

first_layer=true
for layer in "${LAYERS[@]}"; do
  files="${LAYER_FILES[$layer]}"
  [[ -z "$files" ]] && continue

  if [[ "$first_layer" == true ]]; then
    first_layer=false
  else
    echo ','
  fi

  echo -n '    "'"$layer"'": ['
  first_file=true
  IFS=',' read -ra FILE_ARRAY <<< "$files"
  for f in "${FILE_ARRAY[@]}"; do
    if [[ "$first_file" == true ]]; then
      first_file=false
    else
      echo -n ', '
    fi
    echo -n '"'"$f"'"'
  done
  echo -n ']'
done

echo ''
echo '  },'

# Stats per layer
echo '  "layer_summary": {'
first_stat=true
for layer in "${LAYERS[@]}"; do
  files="${LAYER_FILES[$layer]}"
  [[ -z "$files" ]] && continue
  IFS=',' read -ra FILE_ARRAY <<< "$files"
  count=${#FILE_ARRAY[@]}
  if [[ "$first_stat" == true ]]; then
    first_stat=false
  else
    echo ','
  fi
  echo -n '    "'"$layer"'": '"$count"
done
echo ''
echo '  }'
echo '}'
