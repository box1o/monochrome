def require($valid; $message): if $valid then . else error($message) end;
def exact($names): type == "object" and (keys | sort) == ($names | sort);
def number($low; $high; $integer):
    type == "number" and isfinite and . >= $low and . <= $high and (if $integer then . == floor else true end);
def color: type == "string" and test("^#[0-9a-fA-F]{6}$");
def text: type == "string" and test("^[A-Za-z0-9 ._-]{1,100}$");
def hex:
    ascii_downcase | explode | reduce .[] as $c (0; . * 16 + (if $c <= 57 then $c - 48 else $c - 87 end));
def luminance:
    [.[1:3], .[3:5], .[5:7]] | map(hex / 255 | if . <= 0.04045 then . / 12.92 else pow((. + 0.055) / 1.055; 2.4) end)
    | .[0] * 0.2126 + .[1] * 0.7152 + .[2] * 0.0722;
def contrast($a; $b): [($a | luminance), ($b | luminance)] | (max + 0.05) / (min + 0.05);
def schema: {
    notch: "compact_width compact_height expanded_width expanded_height compact_radius expanded_radius shoulder close_delay background foreground clock_spacing clock_dot_spacing clock_row_spacing clock_weight clock_size_offset activity_color",
    colors: "background surface surface_bright foreground muted border accent on_accent red green yellow blue magenta cyan white black",
    fonts: "family mono_family size terminal_size shell_size icon_size",
    geometry: "radius radius_small border_width gap_inner gap_outer padding",
    motion: "enabled scale fast_ms normal_ms slow_ms curve",
    appearance: "wallpaper icons cursor cursor_size gtk_theme opacity blur shadow"
};
require(exact(["version", "name"] + (schema | keys)); "Unexpected theme sections")
| require(.version == 1 and .name == "mono"; "Expected version: 1 and name: mono")
| . as $t
| reduce (schema | to_entries[]) as $section (.;
    require($t[$section.key] | exact($section.value | split(" ")); "Unexpected keys in " + $section.key))
| require(all(.colors[]; color); "Colors must be quoted #RRGGBB values")
| require(all(.notch | .background, .foreground, .activity_color; color); "Invalid notch colors")
| require(all(.notch | .compact_width, .compact_height, .expanded_width, .expanded_height; number(16;4096;true)); "Invalid notch dimensions")
| require(all(.notch | .compact_radius, .expanded_radius, .shoulder, .clock_size_offset; number(0;64;true)); "Invalid notch radii")
| require(.notch.close_delay | number(0;2000;true); "Invalid close delay")
| require(all(.notch | .clock_spacing, .clock_dot_spacing, .clock_row_spacing; number(0;8;false)); "Invalid dot spacing")
| require(.notch.clock_weight | number(0.5;2;false); "Invalid clock weight")
| require(.notch.expanded_width >= .notch.compact_width and .notch.expanded_height >= .notch.compact_height; "Expanded notch must not be smaller than compact notch")
| require(.notch.compact_radius <= ([.notch.compact_width,.notch.compact_height] | min) / 2
          and .notch.expanded_radius <= ([.notch.expanded_width,.notch.expanded_height] | min) / 2; "Notch radius exceeds half the body size")
| require(contrast(.notch.foreground;.notch.background) >= 4.5; "Insufficient notch contrast")
| require(all(.fonts | .family,.mono_family; text) and all(.appearance | .icons,.cursor,.gtk_theme; text); "Unsupported font or theme name")
| require(all(.fonts | .size,.terminal_size,.shell_size,.icon_size; number(6;48;true)); "Invalid font size")
| require(all(.geometry[]; number(0;64;true)) and (.geometry.border_width | number(0;3;true)); "Invalid geometry")
| require(all(.motion.enabled,.appearance.blur,.appearance.shadow; type == "boolean"); "Motion, blur and shadow must be booleans")
| require(.appearance.cursor_size | number(8;128;true); "Invalid cursor size")
| require(.appearance.wallpaper | type == "string" and test("^[A-Za-z0-9][A-Za-z0-9._-]*$"); "Wallpaper must be a filename inside assets/bg")
| require(.appearance.opacity | number(0.8;1;false); "Invalid opacity")
| require(.motion.scale | number(0.1;5;false); "Invalid motion scale")
| require(all(.motion | .fast_ms,.normal_ms,.slow_ms; number(1;2000;true)); "Invalid motion duration")
| require(.motion.curve | type == "array" and length == 4 and all(.[]; number(0;1;false)); "Motion curve requires four coordinates in 0..1")
| . as $theme
| reduce (["foreground","muted","accent","red","green","yellow","blue","magenta","cyan"][] as $fg
          | ["background","surface","surface_bright"][] as $bg | {fg:$fg,bg:$bg}) as $pair (.;
    require(contrast($theme.colors[$pair.fg];$theme.colors[$pair.bg]) >= 4.5; "Insufficient contrast: " + $pair.fg + " on " + $pair.bg))
| require(contrast(.colors.on_accent;.colors.accent) >= 4.5 and contrast(.colors.border;.colors.surface_bright) >= 3; "Insufficient accent or border contrast")
