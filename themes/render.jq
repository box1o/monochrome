def evenround: floor as $base | if . - $base == 0.5 then (if $base % 2 == 0 then $base else $base + 1 end) else round end;
def duration($key): if .motion.enabled then ([1, (.motion[$key] * .motion.scale | evenround)] | max) else 0 end;
. as $theme
| ([paths(type != "array" and type != "object") as $path | {key: ($path | map(tostring) | join(".")), value: (getpath($path) | if type == "string" and startswith("#") then ltrimstr("#") else tostring end)}] | from_entries)
+ {"duration.fast_ms":($theme|duration("fast_ms")|tostring), "duration.normal_ms":($theme|duration("normal_ms")|tostring), "duration.slow_ms":($theme|duration("slow_ms")|tostring),
   "computed.icon_scale":($theme.fonts.icon_size/16|tostring), "computed.icon_double":($theme.fonts.icon_size*2|tostring),
   "computed.reduce_motion":($theme.motion.enabled|not|tostring), "computed.roundness":([$theme.geometry.radius/4|ceil,3]|min|tostring),
   "paths.config":$config, "paths.data":$data}
