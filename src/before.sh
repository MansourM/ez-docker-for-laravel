## before hook
##
## Any code here will be placed inside a `before_hook()` function and called
## before running any command (but after processing its arguments).
##
## You can safely delete this file if you do not need it.

# Strict error handling - applies to all commands
set -euo pipefail

#inspect_args

if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root"
   exit 1
fi