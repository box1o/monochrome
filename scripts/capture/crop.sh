#!/usr/bin/env bash
# jq/awk expressions are intentionally not shell-expanded.
# shellcheck disable=SC2016

set -euo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse_command "$@"
if args::has help; then
    script::usage 'SOURCE "X,Y WxH" DESTINATION'
    exit 0
fi
script::require_count 3 3
proc::require magick jq hyprctl
source_file=$(path::absolute "${SCRIPT_ARGS[0]}")
geometry=${SCRIPT_ARGS[1]}
destination=$(path::absolute "${SCRIPT_ARGS[2]}")
fs::require_file screenshot "$source_file"
[[ $geometry =~ ^(-?[0-9]+),(-?[0-9]+)[[:space:]]([0-9]+)x([0-9]+)$ ]] || log::fatal --code 2 'Invalid crop geometry'
gx=${BASH_REMATCH[1]}
gy=${BASH_REMATCH[2]}
gw=${BASH_REMATCH[3]}
gh=${BASH_REMATCH[4]}
((gw > 0 && gh > 0)) || log::fatal --code 2 'Crop size must be positive'
read -r width height < <(exec::query magick identify -format '%w %h\n' "$source_file")
monitors=$(exec::query hyprctl monitors -j 2>/dev/null || printf '[]')
crop=$(exec::query jq -nr --argjson monitors "$monitors" --argjson width "$width" --argjson height "$height" --argjson x "$gx" --argjson y "$gy" --argjson w "$gw" --argjson h "$gh" '
    ($monitors | map(.x) | min // 0) as $left
    | ($monitors | map(.y) | min // 0) as $top
    | ($monitors | map(.x + .width / .scale) | max // $width) as $right
    | (if $right > $left then $width / ($right - $left) else 1 end) as $scale
    | (($x - $left) * $scale | round) as $px | (($y - $top) * $scale | round) as $py
    | ([0,$px] | max) as $x0 | ([0,$py] | max) as $y0
    | ([$width,$px + ($w*$scale|round)] | min) as $x1 | ([$height,$py + ($h*$scale|round)] | min) as $y1
    | if $x1 <= $x0 or $y1 <= $y0 then error("Selection is outside the image")
      else "\($x1-$x0)x\($y1-$y0)+\($x0)+\($y0)" end')
fs::mkdir_parent "$destination"
exec::run --quiet -- magick "$source_file" -crop "$crop" +repage "PNG:$destination"
