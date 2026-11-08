def evenround: floor as $base | if . - $base == 0.5 then (if $base % 2 == 0 then $base else $base + 1 end) else round end;
def property($names):
    . as $properties | first($names[] | $properties[.] | select(. != null and . != "")) // "";
def generic: ascii_downcase | IN("alsa playback", "alsa stream", "audio stream", "playback stream");
if type == "array" then map(
    . as $stream | (.properties // {}) as $properties
    | ($properties | property(["application.name"])) as $app
    | ($properties | property(["node.name"])) as $node
    | ($properties | property(["application.process.binary"])) as $binary
    | select(([ $app, $node, $binary ] | join(" ") | ascii_downcase | test("cava|quickshell|speech-dispatcher")) | not)
    | ([$app, $properties["device.description"], $node, $properties["media.name"]]
       | map(select(. != null and . != "" and (generic | not))) | first) as $name
    | ([($stream.volume // {})[] | .value_percent // "" | rtrimstr("%") | tonumber?]) as $channels
    | (if $channels | length > 0 then ($channels | add / length | evenround) else 100 end) as $volume
    | {id: .index, name: ($name // (if $binary != "" then $binary | gsub("-"; " ") | split(" ") | map(. as $word | ($word[:1] | ascii_upcase) + ($word[1:] | ascii_downcase)) | join(" ") else "Audio" end)),
       binary: (if $binary == "" then $node else $binary end),
       icon: ($properties | property(["application.icon_name", "application.icon-name"]) | if . == "" then $node else . end),
       muted: (.mute // false), volume: ($volume / 100), volume_pct: $volume}
) else [] end
