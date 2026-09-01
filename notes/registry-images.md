# Image mode — build in CI, run from a registry

By default `ez laravel deploy` checks the app out on this host and builds it here
(`DEPLOY_MODE=build`, the original behaviour, unchanged). **Image mode** instead runs an image
that CI already built and pushed.

## Why

Building on the production host has three costs that image mode removes:

- **The artifact was never tested.** CI builds and tests one checkout; the host then builds a
  *different* one. What runs in production never went through the pipeline.
- **Production needs credentials it should not have.** `composer install` on the host means the
  host needs its own long-lived token for any private package — plaintext in `docker.env`,
  never rotated. In CI the same install runs under a short-lived job token.
- **Rollback means rebuilding** and hoping the result matches. With an immutable tag it is
  re-running a known artifact.

## The base image pair

`template/base-build.Dockerfile` and `template/base-runtime.Dockerfile` are published once per PHP
version; an app's own Dockerfile is then ~20 lines instead of ~200:

```dockerfile
ARG BASE=registry.example.com/group
ARG PHP_VERSION=8.3

FROM ${BASE}/ez-laravel-build:${PHP_VERSION} AS builder
WORKDIR /var/www
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN composer dump-autoload --optimize --no-dev && npm run build

FROM ${BASE}/ez-laravel-runtime:${PHP_VERSION}
COPY --from=builder --chown=www-data:www-data /var/www /var/www
```

**CI publishes them** (`.gitlab-ci.yml`): every push to the default branch builds the matrix,
asserts both halves with `ci/assert-base-images.sh`, and pushes a floating `:<php>` tag plus an
immutable `:<php>-<short-sha>`. Merge requests build and assert without publishing, so the floating
tag every app builds FROM never moves for an unmerged branch.

`scripts/publish-base-images.sh` remains as a local escape hatch and runs the same assertions:

```bash
docker login registry.example.com
scripts/publish-base-images.sh registry.example.com/group 8.5
```

Publishing by hand was the original arrangement and is deliberately no longer the default — see
`fardadev/ci-images`, which was migrated off exactly that for the same reasons.

A runtime fix then reaches every app on its next build, rather than being re-pasted into each
app's Dockerfile.

## `.env` is mounted, never baked

Build mode copies `env/generated/<env>.env` into the image. That is survivable while the image
never leaves the host — but a published image would carry `APP_KEY`, the database password and
every API key to anyone who can pull it.

So image mode bind-mounts the file read-only at `/var/www/.env`, and `entrypoint.sh` caches
config at **run** time rather than build time. Caching earlier would freeze whatever environment
existed in CI.

## Setting an app up

In `apps/<app>/env/app.env`:

```
DEPLOY_MODE=image
APP_IMAGE=registry.example.com/group/app:<tag>
```

In `docker/docker.env` at the ez-docker root — it is shared by every app on the host
(omit these for an anonymous pull from a public registry):

```
REGISTRY_HOST=registry.example.com
REGISTRY_USER=<deploy token username>
REGISTRY_TOKEN=<deploy token with read_registry>
```

These are stripped out of the app's generated `.env`: they configure ez, not the application.

`read_registry` is the whole scope needed — the host pulls images and nothing else. It never reads
source and never resolves packages.

Then deploy as usual:

```bash
sudo ./ez laravel deploy <app> production
```

The deploy pulls the tag, then starts it. Pull happens first, so a wrong tag or an expired token
fails before the running container is touched.

## Storage ownership

The published runtime keeps `www-data` at its distribution uid (33). Build mode instead remaps it
to `OWNER_USER_ID` at build time, which a base image shared by every host cannot do.

So in image mode the deploy chowns `apps/<app>/storage-<env>` to **33:33** before starting the
container, rather than to the host owner. Handing those directories to the host user — which is
correct for build mode — would leave Laravel unable to write logs or caches, and the failure
surfaces as 500s rather than as anything about permissions.

Override with `IMAGE_USER_ID` / `IMAGE_GROUP_ID` if a custom runtime uses different ids. The host
user can still read the logs by joining group 33.

## Migrations and the backup gate

In `production`, the entrypoint backs the database up before migrating. It detects the backup tool
with `php artisan list | grep backup:run` — **not** `composer show`, which cannot work: composer is
a build-time tool and is absent from the runtime image, so that test failed regardless of whether
the package was installed, and every production deploy quietly took the "skip migrations" branch.

If no backup tool is available the deploy now **fails** instead of skipping. Skipping starts new
code against an old schema: the app looks healthy and misbehaves only on the paths that needed the
migration, which is harder to diagnose than a container that refuses to start.

To migrate when you have taken a dump by other means, set `MIGRATE_WITHOUT_BACKUP=true` for that
deploy.

## Notes

- `dev` and `test` reject image mode: dev mounts live source to edit, and test builds the tree it
  is about to test. Neither wants a fixed artifact.
- Prefer an immutable tag (a commit SHA) over a moving one. A moving tag makes "what is actually
  running" unanswerable and makes rollback guesswork.
- Existing apps are untouched: `DEPLOY_MODE` defaults to `build`.
