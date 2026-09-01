#!/usr/bin/env bash
# Build and push the ez-laravel base image pair for one PHP version.
#
#   scripts/publish-base-images.sh registry.example.com/group 8.3
#
# Produces:
#   <prefix>/ez-laravel-build:<php>     toolchain — composer, node, build extensions
#   <prefix>/ez-laravel-runtime:<php>   serving   — php-fpm, nginx, supervisor, configs
#
# Apps build FROM these, so a runtime fix reaches every app on its next build instead of being
# re-pasted into each app's Dockerfile. Run `docker login <registry>` first.
#
# CI IS THE PUBLISHING PATH (.gitlab-ci.yml). This script remains as a local escape hatch — for
# building a version CI does not yet cover, or publishing when the runner is down. It runs the same
# ci/assert-base-images.sh the pipeline does, so a manual publish cannot skip the checks.
set -euo pipefail

prefix="${1:-}"
php_version="${2:-8.3}"

if [[ -z "$prefix" ]]; then
  echo "usage: $0 <registry-prefix> [php-version]" >&2
  echo "   eg: $0 registry.example.com/group 8.3" >&2
  exit 1
fi

# Resolve the repo root to an ABSOLUTE path before changing directory. $0 stays relative, so any
# later "$(dirname "$0")/../ci/..." would resolve against template/ instead of the repo root and
# fail with "command not found".
repo_root="$(cd "$(dirname "$0")/.." && pwd)"

cd "$repo_root/template"

build_tag="${prefix}/ez-laravel-build:${php_version}"
runtime_tag="${prefix}/ez-laravel-runtime:${php_version}"

echo "==> building $build_tag"
docker build -f base-build.Dockerfile --build-arg "PHP_VERSION=${php_version}" -t "$build_tag" .

echo "==> building $runtime_tag"
docker build -f base-runtime.Dockerfile --build-arg "PHP_VERSION=${php_version}" -t "$runtime_tag" .

# Assert BEFORE pushing. A broken image that never reaches the registry cannot break anyone
# else's build.
echo "==> asserting"
"$repo_root/ci/assert-base-images.sh" docker build   "$build_tag"   "$php_version"
"$repo_root/ci/assert-base-images.sh" docker runtime "$runtime_tag" "$php_version"

echo "==> pushing"
docker push "$build_tag"
docker push "$runtime_tag"

echo
echo "published:"
echo "  $build_tag"
echo "  $runtime_tag"
