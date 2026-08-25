# Installing a private composer package at build time

The builder runs `composer install` inside a container with no SSH identity, so a package pulled
from a private repo over `ssh://` cannot be cloned. Rather than bake a key into the image, the
builder can rewrite that `ssh://` URL to authenticated HTTPS using a token.

The rewrite lives in the builder stage's git config only — it is never carried into the final
image, and the token is not part of any shipped layer.

## Setup

Add to the app's `docker/docker.env`:

```
COMPOSER_GITLAB_HOST=git.example.com
COMPOSER_GITLAB_SSH_PORT=
COMPOSER_GITLAB_TOKEN_USER=my-deploy-token-username
COMPOSER_GITLAB_TOKEN=<token>
```

Leave `COMPOSER_GITLAB_TOKEN` empty (or unset) for public apps — the rewrite is skipped entirely.

The token needs `read_repository` on the package's project. A **project or group deploy token**
carries its own username, which is what `COMPOSER_GITLAB_TOKEN_USER` is for; use `gitlab-ci-token`
only for a CI job token.

## `COMPOSER_GITLAB_SSH_PORT` must match the URL exactly

Set it **only if the `composer.json` repository URL spells out a port**, and leave it empty
otherwise:

| `composer.json` URL | `COMPOSER_GITLAB_SSH_PORT` |
|---|---|
| `ssh://git@host/group/pkg.git` | *(empty)* |
| `ssh://git@host:2224/group/pkg.git` | `2224` |

git matches `insteadOf` by literal prefix. A pattern ending `host:/` does not match a URL reading
`host/`, so a mismatch makes the rewrite **silently not fire** — the build then falls back to SSH,
finds no identity, and fails to clone. Nothing warns you; the symptom is a failed clone of the
private package while everything else builds.

## Verifying

Rehearse the match without a build:

```bash
git -c url."https://user:tok@host/".insteadOf="ssh://git@host/" \
    ls-remote --get-url ssh://git@host/group/pkg.git
```

If it prints the `https://…` form, the rewrite matches. If it echoes the `ssh://` URL back
unchanged, it does not — check the port column above.
