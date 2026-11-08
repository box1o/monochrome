# Monochrome

Arch desktop configuration, shared scripts, and one editable theme. Backups of
previous project versions are under `/home/woki/tmp/backup`.

```sh
# Preview a full installation, including AUR dependencies.
bash scripts/install/install.sh full --aur --dry-run

# Deploy the shared runtime and selected configurations.
bash scripts/install/install.sh scripts
bash scripts/install/install.sh configs --configs hypr,tmux
```

The root `install.sh` remains a compatibility launcher. Implementation modules
live together in `scripts/install/`. Full installation validates the source first,
then installs packages, scripts, and configurations in that order. Replacement
files are prepared before deployment, with rollback if the final move fails.

Edit `themes/mono.yaml` for colors, fonts, icons, cursor, wallpaper, rounding,
spacing, opacity and motion. The current UI uses Adwaita Sans and Candy icons;
terminal text uses JetBrains Mono. `fonts.family` can also select Iosevka or
JetBrainsMono Nerd Font Mono. `fonts.mono_family` controls fixed-width text.

```sh
bash scripts/tools/theme.sh --dry-run  # Validate without writes.
bash scripts/tools/theme.sh            # Regenerate native adapters in this checkout.
```

The installer assembles editable configs and native adapters in `generated/`
before deploying. This build folder is ignored by Git and should not be edited.
`configs/` contains editable input only. The installed theme helper requires
`--root /home/woki/monochrome`. `mono-session appearance` applies generated desktop
appearance preferences; `--dry-run` previews them.

Timing is in milliseconds; `motion.scale: 0.5` makes transitions twice as fast.
`motion.enabled: false` disables supported motion. Functional timers retain their
normal timing. Colors are validated against configured text/focus contrast pairs;
this is not an accessibility audit of every app view. GTK, Qt Fusion and Hypr
apps expose different geometry/motion controls, so not every setting maps exactly.

`configs/hypr/hyprland.lua` loads the Lua settings, shortcuts, monitors, workspace
policy and generated theme. `settings/monitors.lua` anchors the external display above the
laptop using its detected logical height. The layout targets one external screen
and the built-in display, with no fixed HDMI resolution offset.

`settings/workspaces.lua` binds workspaces 1–5 to a connected HDMI display and 6–10 to the
laptop; key 0 selects workspace 10. With HDMI disconnected, all ten belong to the
laptop. Native monitor-change events move existing workspaces immediately, without
polling or a helper daemon. Change `first_laptop_workspace` to adjust the boundary.
Existing deployed monitor choices are preserved during configuration upgrades.

`assets/bg` contains only reviewed wallpapers from Documents, Downloads and the
original wallpaper collection; screenshots and unrelated project images are excluded. `assets/catalog.json`
records original sources, hashes, resolution and duplicate grouping. Highest pixel
count wins; uncertain matches are kept separately. `assets/sounds` holds the four
QuickShell sounds. Assets deploy to `~/.local/share/mono/{bg,sounds}`. Choose a
background by setting `appearance.wallpaper` to its filename in `assets/bg`.

Tmux's canonical config is `configs/tmux/tmux.conf`, with colors generated into
`generated/tmux/theme.conf`. A small `.tmux.conf` compatibility entry loads the XDG config. Existing
keybindings and optional persistence settings are retained; missing plugins are
skipped. The watcher supports theme changes as well as config/asset changes.

QuickShell uses small feature folders with separate UI, state and geometry:

- `shell/`: Wayland surface and monitor selection.
- `features/notch/`: composition, visual components, state and geometry model.
- `features/clock/` and `services/`: clock view and shared system clock.
- `activities/`: activity lifecycle contracts and compact-selection policy.
- `components/text/`: reusable dotted text, glyphs and drawing utilities.
- Generated tokens and notch styling live in `generated/quickshell/`.

The compact UI shows the clock, with transient power feedback. Right-click closes the notch and selects clock
presentation. Future services own tasks independently of pages and register/remove
activity objects explicitly; the service must unregister an object before destroying
it. Actions are requests, not acknowledgments. Recording, timer and external-provider
features are not implemented yet.

Local verification under `tests/` is ignored by Git.
Deploy with `./install.sh configs --configs quickshell`. For an isolated development
launch, regenerate first and use `qs --path generated/quickshell`.

`mono-session` centralizes startup, locking, logout and suspend. Hyprpaper,
hypridle, clipboard watchers and removable-media helpers use user services;
QuickShell owns the normal desktop UI. Qt6's `hyprqt6engine` is an AUR dependency;
Qt5 apps can use `mono-session qt5 APPLICATION`. The optional `yaml::*` library
requires Mike Farah yq v4, supplied by Arch's `go-yq` package. Theme validation
and rendering use Bash, yq and jq with native templates.

Power connection/disconnection briefly replaces the compact clock with status,
battery percentage and the original two-wave effect. Width fits the contents;
compact height remains unchanged. Startup/reload establishes a silent baseline.

`lib/` contains only shared Bash abstractions. Project helpers in `scripts/` are
grouped into audio, capture, desktop, network, tools, FreeCAD and build support.
System helpers use Bash; FreeCAD retains its application-specific Python code.
The generator is `themes/theme.sh`.

Hyprland-specific helpers are in `configs/hypr/scripts/`. Editable monitor,
workspace, shortcut and compositor settings are in `configs/hypr/settings/`.
The entry point remains `configs/hypr/hyprland.lua`. The deployed monitor file is
`~/.config/hypr/settings/monitors.lua`; existing monitor choices migrate on deployment.
Native app configurations and theme adapters are assembled under `generated/hypr/`.
Locking uses independent Hyprlock, not the notch. Bindings for unimplemented old
QuickShell menus are omitted until those features return.

`MONO_HELPER_DIR` resolves project helpers separately from the Bash-only
`MONO_LIB_DIR`, for both checkout and installed commands. The watcher observes
editable configs, theme inputs and assets, excluding its generated output.

The open notch has a large clock that morphs from the compact clock. Click its date
header for the month calendar; month navigation, Today and keyboard arrows are
supported. The calendar enters from the right. Leaving an open calendar briefly
shows today's date and a pink ring showing the current day of the month, then returns
to time. Right-click dismisses the activity. The ring color is `notch.activity_color`.
