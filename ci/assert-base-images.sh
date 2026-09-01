#!/usr/bin/env sh
# Assert a freshly built ez-laravel base image actually works.
#
#   usage: ci/assert-base-images.sh <docker|buildah> <build|runtime> <image-ref> <expected-php-version>
#
# WHY THIS IS A SEPARATE FILE: the same assertions must run in two places — the CI pipeline
# (buildah) and a manual publish via scripts/publish-base-images.sh (docker). One copy is the
# point; a divergent second copy is how a check quietly stops covering the thing it was written
# for. That is also why it takes the engine as an argument rather than assuming docker.
#
# WHY ASSERT AT ALL: a build can exit 0 and still produce a broken image. Real examples from this
# image pair and its sibling:
#   - gd configured without --with-jpeg builds fine and silently omits JPEG support, so
#     imagejpeg() is simply missing. Every image this repo produced before 2026-09-01 had it,
#     8.3 included, and nothing caught it because nothing looked.
#   - purging -dev packages reclaims runtime libicu, so `php -m` silently omits intl.
#
# Every assertion below is something a consumer actually needs. Do not relax one to make a build
# pass; fix the image.
set -eu

ENGINE="${1:?engine required: docker|buildah}"
ROLE="${2:?role required: build|runtime}"
IMAGE="${3:?image ref required}"
WANT="${4:?expected php version required, e.g. 8.5}"

# The toolchain half: resolve and compile an app. It deliberately carries FEWER extensions than
# the runtime half (no gd/pdo_mysql/bcmath/pcntl/sockets) because it never serves traffic.
# Do not "fix" that by copying the runtime list here.
BUILD_CHECKS='
php -v | head -1
php -m | grep -qx intl || { echo "MISSING ext-intl (filament/support and ez-auth-for-laravel declare it)"; exit 1; }
php -m | grep -qx zip  || { echo "MISSING ext-zip (composer --prefer-dist, spatie/laravel-backup)"; exit 1; }
php -m | grep -qx exif || { echo "MISSING ext-exif (filament)"; exit 1; }
composer --version
node -v
npm -v
git --version
'

# The serving half. opcache is a ZEND extension: it appears under `php -m`s [Zend Modules]
# section, NOT the main list, so `grep -qx opcache` against the main list wrongly reports it
# missing. Use extension_loaded("Zend OPcache").
RUNTIME_CHECKS='
php -v | head -1
php -m | grep -qx intl      || { echo "MISSING ext-intl"; exit 1; }
php -m | grep -qx zip       || { echo "MISSING ext-zip"; exit 1; }
php -m | grep -qx exif      || { echo "MISSING ext-exif"; exit 1; }
php -m | grep -qx gd        || { echo "MISSING ext-gd"; exit 1; }
php -m | grep -qx pdo_mysql || { echo "MISSING pdo_mysql"; exit 1; }
php -m | grep -qx bcmath    || { echo "MISSING bcmath"; exit 1; }
php -m | grep -qx pcntl     || { echo "MISSING pcntl"; exit 1; }
php -m | grep -qx sockets   || { echo "MISSING sockets"; exit 1; }
php -r "exit(extension_loaded(\"Zend OPcache\") ? 0 : 1);" || { echo "MISSING opcache"; exit 1; }
php -r "\$i=gd_info(); exit(!empty(\$i[\"JPEG Support\"]) ? 0 : 1);" || { echo "gd has NO JPEG support (docker-php-ext-configure gd --with-jpeg missing?)"; exit 1; }
php -r "\$i=gd_info(); exit(!empty(\$i[\"PNG Support\"]) ? 0 : 1);"  || { echo "gd has NO PNG support"; exit 1; }
php -r "exit(function_exists(\"imagejpeg\") ? 0 : 1);" || { echo "imagejpeg() missing despite gd loaded"; exit 1; }
command -v mysqldump >/dev/null || { echo "MISSING mysqldump (spatie/laravel-backup shells out to it)"; exit 1; }
command -v nginx >/dev/null || { echo "MISSING nginx"; exit 1; }
command -v supervisord >/dev/null || { echo "MISSING supervisord"; exit 1; }
'

case "$ROLE" in
  build)   CHECKS="$BUILD_CHECKS" ;;
  runtime) CHECKS="$RUNTIME_CHECKS" ;;
  *) echo "unknown role: $ROLE (want build or runtime)" >&2; exit 2 ;;
esac

VERSION_PROBE='php -r "echo PHP_MAJOR_VERSION.\".\".PHP_MINOR_VERSION;"'

case "$ENGINE" in
  docker)
    # --entrypoint is required for the runtime image, which sets one; harmless for the build image.
    docker run --rm --entrypoint sh "$IMAGE" -eux -c "$CHECKS"
    got=$(docker run --rm --entrypoint sh "$IMAGE" -c "$VERSION_PROBE")
    ;;
  buildah)
    # `buildah from` makes a working container from the image; `buildah run` executes in it and
    # bypasses ENTRYPOINT. No daemon, no privileged mode. The container is left behind on purpose:
    # the CI job's own container is discarded seconds later.
    ctr=$(buildah from "$IMAGE")
    buildah run "$ctr" -- sh -eux -c "$CHECKS"
    got=$(buildah run "$ctr" -- sh -c "$VERSION_PROBE")
    ;;
  *) echo "unknown engine: $ENGINE (want docker or buildah)" >&2; exit 2 ;;
esac

# A typo in the build arg would otherwise silently produce images all tagged as different PHP
# versions but built from the same one.
if [ "$got" != "$WANT" ]; then
  echo "TAG MISMATCH: $IMAGE reports PHP $got, expected $WANT" >&2
  exit 1
fi

echo "OK: $IMAGE is PHP $got ($ROLE half, assertions passed)"
