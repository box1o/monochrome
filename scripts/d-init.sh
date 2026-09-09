#!/usr/bin/env bash

# Keep the original command name available for existing workflows.
exec "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/d-init" "$@"
