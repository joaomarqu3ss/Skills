#!/usr/bin/env bash
# detect-stack.sh — Detect project tech stack, framework, and architecture
#
# Usage:
#   ./detect-stack.sh [project-root]
#
# Output: JSON with detected language, framework, architecture patterns,
#         and suggested layer-to-directory mappings.

set -euo pipefail

ROOT="${1:-.}"

detect_languages() {
  local langs=()

  [[ -f "$ROOT/package.json" ]] && langs+=("javascript/typescript")
  [[ -f "$ROOT/tsconfig.json" ]] && langs+=("typescript")
  [[ -f "$ROOT/pyproject.toml" || -f "$ROOT/setup.py" || -f "$ROOT/requirements.txt" || -f "$ROOT/Pipfile" ]] && langs+=("python")
  [[ -f "$ROOT/go.mod" ]] && langs+=("go")
  [[ -f "$ROOT/Cargo.toml" ]] && langs+=("rust")
  [[ -f "$ROOT/Gemfile" ]] && langs+=("ruby")
  [[ -f "$ROOT/pom.xml" || -f "$ROOT/build.gradle" || -f "$ROOT/build.gradle.kts" ]] && langs+=("java/kotlin")
  [[ -f "$ROOT/composer.json" ]] && langs+=("php")
  [[ -f "$ROOT/mix.exs" ]] && langs+=("elixir")
  [[ -f "$ROOT/pubspec.yaml" ]] && langs+=("dart")
  [[ -f "$ROOT/*.csproj" || -f "$ROOT/*.sln" ]] 2>/dev/null && langs+=("csharp")

  # Deduplicate
  printf '%s\n' "${langs[@]}" | sort -u | tr '\n' ',' | sed 's/,$//'
}

detect_frameworks() {
  local frameworks=()

  # JavaScript/TypeScript frameworks
  if [[ -f "$ROOT/package.json" ]]; then
    local pkg
    pkg=$(cat "$ROOT/package.json" 2>/dev/null || echo "{}")

    echo "$pkg" | grep -q '"next"' && frameworks+=("nextjs")
    echo "$pkg" | grep -q '"nuxt"' && frameworks+=("nuxt")
    echo "$pkg" | grep -q '"react"' && frameworks+=("react")
    echo "$pkg" | grep -q '"vue"' && frameworks+=("vue")
    echo "$pkg" | grep -q '"angular"' && frameworks+=("angular")
    echo "$pkg" | grep -q '"svelte"' && frameworks+=("svelte")
    echo "$pkg" | grep -q '"express"' && frameworks+=("express")
    echo "$pkg" | grep -q '"fastify"' && frameworks+=("fastify")
    echo "$pkg" | grep -q '"nestjs\|@nestjs"' && frameworks+=("nestjs")
    echo "$pkg" | grep -q '"hono"' && frameworks+=("hono")
    echo "$pkg" | grep -q '"prisma\|@prisma"' && frameworks+=("prisma")
    echo "$pkg" | grep -q '"typeorm"' && frameworks+=("typeorm")
    echo "$pkg" | grep -q '"sequelize"' && frameworks+=("sequelize")
    echo "$pkg" | grep -q '"drizzle"' && frameworks+=("drizzle")
    echo "$pkg" | grep -q '"mongoose"' && frameworks+=("mongoose")
    echo "$pkg" | grep -q '"knex"' && frameworks+=("knex")
  fi

  # Python frameworks
  if [[ -f "$ROOT/pyproject.toml" || -f "$ROOT/requirements.txt" ]]; then
    local deps
    deps=$(cat "$ROOT/pyproject.toml" "$ROOT/requirements.txt" 2>/dev/null || echo "")
    echo "$deps" | grep -qi 'django' && frameworks+=("django")
    echo "$deps" | grep -qi 'fastapi' && frameworks+=("fastapi")
    echo "$deps" | grep -qi 'flask' && frameworks+=("flask")
    echo "$deps" | grep -qi 'sqlalchemy' && frameworks+=("sqlalchemy")
    echo "$deps" | grep -qi 'alembic' && frameworks+=("alembic")
  fi

  # Ruby
  if [[ -f "$ROOT/Gemfile" ]]; then
    grep -q 'rails' "$ROOT/Gemfile" 2>/dev/null && frameworks+=("rails")
    grep -q 'sinatra' "$ROOT/Gemfile" 2>/dev/null && frameworks+=("sinatra")
  fi

  # Go
  if [[ -f "$ROOT/go.mod" ]]; then
    grep -q 'gin-gonic' "$ROOT/go.mod" 2>/dev/null && frameworks+=("gin")
    grep -q 'labstack/echo' "$ROOT/go.mod" 2>/dev/null && frameworks+=("echo")
    grep -q 'gofiber' "$ROOT/go.mod" 2>/dev/null && frameworks+=("fiber")
  fi

  # Java/Kotlin
  if [[ -f "$ROOT/pom.xml" || -f "$ROOT/build.gradle" || -f "$ROOT/build.gradle.kts" ]]; then
    local build
    build=$(cat "$ROOT/pom.xml" "$ROOT/build.gradle" "$ROOT/build.gradle.kts" 2>/dev/null || echo "")
    echo "$build" | grep -qi 'spring' && frameworks+=("spring")
    echo "$build" | grep -qi 'quarkus' && frameworks+=("quarkus")
  fi

  printf '%s\n' "${frameworks[@]}" | sort -u | tr '\n' ',' | sed 's/,$//'
}

detect_directories() {
  # Find directories that map to layers
  local api_dirs=()
  local service_dirs=()
  local persistence_dirs=()
  local test_dirs=()
  local infra_dirs=()

  # Scan top-level and one level deep
  for dir in "$ROOT"/*/ "$ROOT"/*/*/ 2>/dev/null; do
    [[ ! -d "$dir" ]] && continue
    local rel
    rel=$(realpath --relative-to="$ROOT" "$dir" 2>/dev/null || echo "$dir")

    case "$rel" in
      *controller*|*controllers*|*route*|*routes*|*handler*|*handlers*|*middleware*|*api*|*endpoint*|*resolver*|*graphql*|*grpc*|*proto*)
        api_dirs+=("$rel") ;;
      *service*|*services*|*usecase*|*use-case*|*domain*|*core*|*business*|*logic*|*command*|*commands*|*query*|*queries*|*event*|*events*|*worker*|*workers*|*job*|*jobs*)
        service_dirs+=("$rel") ;;
      *model*|*models*|*entity*|*entities*|*repository*|*repositories*|*migration*|*migrations*|*schema*|*prisma*|*dao*|*database*|*db*|*persistence*|*seed*)
        persistence_dirs+=("$rel") ;;
      *test*|*tests*|*spec*|*specs*|*__tests__*|*__mocks__*|*fixture*|*fixtures*)
        test_dirs+=("$rel") ;;
      *.github*|*.gitlab*|*ci*|*docker*|*infra*|*infrastructure*|*terraform*|*k8s*|*kubernetes*|*helm*|*deploy*|*script*|*scripts*|*bin*|*config*|*conf*)
        infra_dirs+=("$rel") ;;
    esac
  done

  # Output
  echo '    "api": ['
  printf '      "%s"\n' "${api_dirs[@]}" 2>/dev/null | paste -sd',' | sed 's/,/", "/g; s/^/      ["/; s/$/"]/' 2>/dev/null || echo '      '
  echo '    ],'
  echo '    "services": ['
  printf '      "%s"\n' "${service_dirs[@]}" 2>/dev/null | paste -sd',' | sed 's/,/", "/g; s/^/      ["/; s/$/"]/' 2>/dev/null || echo '      '
  echo '    ],'
  echo '    "persistence": ['
  printf '      "%s"\n' "${persistence_dirs[@]}" 2>/dev/null | paste -sd',' | sed 's/,/", "/g; s/^/      ["/; s/$/"]/' 2>/dev/null || echo '      '
  echo '    ],'
  echo '    "tests": ['
  printf '      "%s"\n' "${test_dirs[@]}" 2>/dev/null | paste -sd',' | sed 's/,/", "/g; s/^/      ["/; s/$/"]/' 2>/dev/null || echo '      '
  echo '    ],'
  echo '    "infra": ['
  printf '      "%s"\n' "${infra_dirs[@]}" 2>/dev/null | paste -sd',' | sed 's/,/", "/g; s/^/      ["/; s/$/"]/' 2>/dev/null || echo '      '
  echo '    ]'
}

detect_testing() {
  local test_tools=()

  if [[ -f "$ROOT/package.json" ]]; then
    local pkg
    pkg=$(cat "$ROOT/package.json" 2>/dev/null || echo "{}")
    echo "$pkg" | grep -q '"jest"' && test_tools+=("jest")
    echo "$pkg" | grep -q '"vitest"' && test_tools+=("vitest")
    echo "$pkg" | grep -q '"mocha"' && test_tools+=("mocha")
    echo "$pkg" | grep -q '"cypress"' && test_tools+=("cypress")
    echo "$pkg" | grep -q '"playwright"' && test_tools+=("playwright")
  fi

  [[ -f "$ROOT/pytest.ini" || -f "$ROOT/conftest.py" || -f "$ROOT/setup.cfg" ]] && test_tools+=("pytest")
  [[ -f "$ROOT/.rspec" ]] && test_tools+=("rspec")

  printf '%s\n' "${test_tools[@]}" | sort -u | tr '\n' ',' | sed 's/,$//'
}

detect_ci() {
  local ci_tools=()

  [[ -d "$ROOT/.github/workflows" ]] && ci_tools+=("github-actions")
  [[ -f "$ROOT/.gitlab-ci.yml" ]] && ci_tools+=("gitlab-ci")
  [[ -f "$ROOT/Jenkinsfile" ]] && ci_tools+=("jenkins")
  [[ -d "$ROOT/.circleci" ]] && ci_tools+=("circleci")
  [[ -f "$ROOT/.travis.yml" ]] && ci_tools+=("travis")
  [[ -f "$ROOT/bitbucket-pipelines.yml" ]] && ci_tools+=("bitbucket-pipelines")

  printf '%s\n' "${ci_tools[@]}" | sort -u | tr '\n' ',' | sed 's/,$//'
}

# --- Main output ---

LANGUAGES=$(detect_languages)
FRAMEWORKS=$(detect_frameworks)
TESTING=$(detect_testing)
CI=$(detect_ci)

echo '{'
echo '  "project_root": "'"$(realpath "$ROOT")"'",'
echo '  "languages": "'"$LANGUAGES"'",'
echo '  "frameworks": "'"$FRAMEWORKS"'",'
echo '  "testing": "'"$TESTING"'",'
echo '  "ci": "'"$CI"'",'
echo '  "has_docker": '$([ -f "$ROOT/Dockerfile" ] || [ -f "$ROOT/docker-compose.yml" ] || [ -f "$ROOT/docker-compose.yaml" ] && echo "true" || echo "false")','
echo '  "has_monorepo": '$([ -f "$ROOT/lerna.json" ] || [ -f "$ROOT/pnpm-workspace.yaml" ] || [ -d "$ROOT/packages" ] && echo "true" || echo "false")','
echo '  "detected_layer_dirs": {'
detect_directories
echo '  }'
echo '}'
