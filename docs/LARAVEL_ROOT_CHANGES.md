# LARAVEL_ROOT Support

## What Changed
Added support for Laravel in subdirectories (e.g., `apps/backend`).

## How It Works
- `LARAVEL_ROOT` stores path to Laravel within repo
- Empty string = Laravel at root
- Non-empty = path with trailing slash (e.g., `apps/backend/`)
- Trailing slash added automatically during setup

## Files Modified

### Setup
- `src/laravel_new_command.sh` - Prompts for LARAVEL_ROOT, adds trailing slash

### Deployment
- `src/laravel_deploy_command.sh` - Uses `${LARAVEL_ROOT}.env`
- `src/laravel_start_command.sh` - Uses `${LARAVEL_ROOT}.env`
- `src/laravel_restart_command.sh` - Uses `${LARAVEL_ROOT}.env`
- `src/lib/update_source_code.sh` - Validates Laravel at `${source_code_dir}/${LARAVEL_ROOT}`

### Docker
- `template/common-laravel.yml` - Passes LARAVEL_ROOT as build arg
- `template/compose-laravel.yml` - Dev mounts `./src-dev/${LARAVEL_ROOT}:/var/www`
- `template/laravel.Dockerfile` - Uses `${LARAVEL_ROOT}` in COPY commands
- `template/laravel-test.Dockerfile` - Uses `${LARAVEL_ROOT}` in COPY commands
- `template/laravel-dev.Dockerfile` - No LARAVEL_ROOT needed (direct mount)

## Examples

### Laravel at Root
```bash
LARAVEL_ROOT=""
# Dev mount: ./src-dev/:/var/www
# Build COPY: ./src-test/composer.json
```

### Laravel in Subdirectory
```bash
LARAVEL_ROOT="apps/backend/"
# Dev mount: ./src-dev/apps/backend/:/var/www
# Build COPY: ./src-test/apps/backend/composer.json
```

## Usage

### New Projects
```bash
./ez laravel new
# Prompt: Enter the path to Laravel root within the repository []: 
# Leave empty for root, or enter: apps/backend
```

### Existing Projects
Edit `apps/{APP_NAME}/env/app.env`:
```bash
LARAVEL_ROOT=apps/backend/
```