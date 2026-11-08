#!/usr/bin/env bash

# Keep the existing entry point while installer code lives under scripts/install.
exec bash "$(dirname -- "${BASH_SOURCE[0]}")/scripts/install/install.sh" "$@"
