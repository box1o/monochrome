#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/.init.sh" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage 'FEATURE [BASE-PATH]'
    exit 0
fi

script::require_count 1 2 || exit $?

set -- "${SCRIPT_ARGS[@]}"

config::load_shell scaffold

name="${1:-}"
base="${2:-${SCAFFOLD_BASE:-src/features}}"

[[ -n "${name}" ]] || log::fatal "usage: $0 [--dry-run] <feature-name> [base-path]"
[[ "$name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]] || log::fatal "feature name must be a TypeScript identifier"

feature="${base}/${name}"
cap="${name^}"
upper="${name^^}"

for directory in components hooks/api services store types constants utils; do
    fs::mkdir "${feature}/${directory}"
done

fs::write "${feature}/index.ts" << EOF
export * from "./components";
export * from "./constants";
export * from "./hooks";
export * from "./services";
export * from "./store";
export * from "./types";
export * from "./utils";
export { Component as ${cap}Page } from "./${name}.page";
export { default as ${cap}Main } from "./main";
EOF

fs::write "${feature}/components/index.ts" ""
fs::write "${feature}/hooks/index.ts" << EOF
export { default as use${cap} } from "./use-${name}";
export * from "./api";
EOF

printf 'export { default as %sApi } from "./%s.api";\n' "${name}" "${name}" | fs::write "${feature}/hooks/api/index.ts"
printf 'export { default as %sService } from "./%s.service";\n' "${name}" "${name}" | fs::write "${feature}/services/index.ts"
printf 'export { default as use%sStore } from "./%s.store";\n' "${cap}" "${name}" | fs::write "${feature}/store/index.ts"
printf 'export type { %s } from "./%s.types";\n' "${cap}" "${name}" | fs::write "${feature}/types/index.ts"
printf 'export { %s_CONSTANTS } from "./%s.constants";\n' "${upper}" "${name}" | fs::write "${feature}/constants/index.ts"
printf 'export { %sUtils } from "./%s.utils";\n' "${name}" "${name}" | fs::write "${feature}/utils/index.ts"

for file in \
    "${feature}/types/${name}.types.ts" \
    "${feature}/constants/${name}.constants.ts" \
    "${feature}/hooks/api/${name}.api.ts" \
    "${feature}/services/${name}.service.ts" \
    "${feature}/store/${name}.store.ts" \
    "${feature}/hooks/use-${name}.ts" \
    "${feature}/utils/${name}.utils.ts"; do
    fs::touch "$file"
done

fs::write "${feature}/main.tsx" << EOF
const Main = () => <div><h1>${cap} Feature Main</h1></div>;

export default Main;
EOF

fs::write "${feature}/${name}.page.tsx" << EOF
import Main from "./main";

const ${cap}Page = () => <Main />;

export const Component = ${cap}Page;
EOF

if [[ ${SHELL_LIB_DRY_RUN:-false} != true ]]; then
    log::info "created: ${feature}"
fi
