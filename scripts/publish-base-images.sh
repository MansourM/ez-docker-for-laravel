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
set -euo pipefail

prefix="${1:-}"
php_version="${2:-8.3}"

if [[ -z "$prefix" ]]; then
  echo "usage: $0 <registry-prefix> [php-version]" >&2
  echo "   eg: $0 registry.example.com/group 8.3" >&2
  exit 1
fi

cd "$(dirname "$0")/../template"

build_tag="${prefix}/ez-laravel-build:${php_version}"
runtime_tag="${prefix}/ez-laravel-runtime:${php_version}"

echo "==> building $build_tag"
docker build -f base-build.Dockerfile --build-arg "PHP_VERSION=${php_version}" -t "$build_tag" .

echo "==> building $runtime_tag"
docker build -f base-runtime.Dockerfile --build-arg "PHP_VERSION=${php_version}" -t "$runtime_tag" .

echo "==> pushing"
docker push "$build_tag"
docker push "$runtime_tag"

echo
echo "published:"
echo "  $build_tag"
echo "  $runtime_tag"
