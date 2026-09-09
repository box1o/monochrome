#!/usr/bin/env bash
set -euo pipefail

source "${MONO_LIB_DIR:-${HOME}/.local/lib/mono}/legacy.sh"
load_config scaffold

name="${1:-}"
base="${2:-${SCAFFOLD_BASE:-src/features}}"
[[ -n "${name}" ]] || die "usage: $0 <feature-name> [base-path]"

feature="${base}/${name}"
cap="${name^}"
upper="${name^^}"

mkdir -p "${feature}"/{components,hooks/api,services,store,types,constants,utils}

cat >"${feature}/index.ts" <<EOF
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

: >"${feature}/components/index.ts"
cat >"${feature}/hooks/index.ts" <<EOF
export { default as use${cap} } from "./use-${name}";
export * from "./api";
EOF
printf 'export { default as %sApi } from "./%s.api";\n' "${name}" "${name}" >"${feature}/hooks/api/index.ts"
printf 'export { default as %sService } from "./%s.service";\n' "${name}" "${name}" >"${feature}/services/index.ts"
printf 'export { default as use%sStore } from "./%s.store";\n' "${cap}" "${name}" >"${feature}/store/index.ts"
printf 'export type { %s } from "./%s.types";\n' "${cap}" "${name}" >"${feature}/types/index.ts"
printf 'export { %s_CONSTANTS } from "./%s.constants";\n' "${upper}" "${name}" >"${feature}/constants/index.ts"
printf 'export { %sUtils } from "./%s.utils";\n' "${name}" "${name}" >"${feature}/utils/index.ts"

touch \
    "${feature}/types/${name}.types.ts" \
    "${feature}/constants/${name}.constants.ts" \
    "${feature}/hooks/api/${name}.api.ts" \
    "${feature}/services/${name}.service.ts" \
    "${feature}/store/${name}.store.ts" \
    "${feature}/hooks/use-${name}.ts" \
    "${feature}/utils/${name}.utils.ts"

cat >"${feature}/main.tsx" <<EOF
const Main = () => <div><h1>${cap} Feature Main</h1></div>;

export default Main;
EOF

cat >"${feature}/${name}.page.tsx" <<EOF
import Main from "./main";

const ${cap}Page = () => <Main />;

export const Component = ${cap}Page;
EOF

ok "created: ${feature}"
