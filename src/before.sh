## before hook
##
## Any code here will be placed inside a `before_hook()` function and called
## before running any command (but after processing its arguments).
##
## You can safely delete this file if you do not need it.

# Strict error handling - applies to all commands
set -euo pipefail

#inspect_args

# Check Docker access instead of requiring root
if ! docker ps >/dev/null 2>&1; then
   log_error "Cannot connect to Docker daemon

This script requires access to Docker. Please ensure:
  1. Docker is installed and running
  2. Your user has permission to access Docker

To add your user to the docker group:
  sudo usermod -aG docker \$USER
  newgrp docker

Or run with sudo if you prefer:
  sudo ./ez <command>"
   exit 1
fi