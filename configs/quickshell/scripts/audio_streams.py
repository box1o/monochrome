#!/usr/bin/env python3
"""Emit compact JSON for active PulseAudio sink inputs."""

from __future__ import annotations

import json
import os
import subprocess


IGNORED_CLIENTS = ("cava", "quickshell", "speech-dispatcher")
GENERIC_NAMES = {"alsa playback", "alsa stream", "audio stream", "playback stream"}


def query_inputs() -> list[dict]:
    environment = os.environ.copy()
    environment["LC_ALL"] = "C"
    try:
        result = subprocess.run(
            ["pactl", "--format=json", "list", "sink-inputs"],
            check=True,
            capture_output=True,
            env=environment,
            text=True,
            timeout=3,
        )
        value = json.loads(result.stdout)
        return value if isinstance(value, list) else []
    except (json.JSONDecodeError, OSError, subprocess.SubprocessError):
        return []


def text_property(properties: dict, *names: str) -> str:
    return next((str(properties[name]) for name in names if properties.get(name)), "")


def volume_percent(item: dict) -> int:
    channels = item.get("volume", {})
    if not isinstance(channels, dict) or not channels:
        return 100
    values = []
    for channel in channels.values():
        try:
            values.append(int(str(channel["value_percent"]).rstrip("%")))
        except (KeyError, TypeError, ValueError):
            continue
    return round(sum(values) / len(values)) if values else 100


def main() -> None:
    output = []
    for item in query_inputs():
        properties = item.get("properties", {})
        app = text_property(properties, "application.name")
        node = text_property(properties, "node.name")
        binary = text_property(properties, "application.process.binary")
        if any(name in f"{app} {node} {binary}".lower() for name in IGNORED_CLIENTS):
            continue

        candidates = (
            app,
            text_property(properties, "device.description"),
            node,
            text_property(properties, "media.name"),
        )
        name = next((value for value in candidates if value and value.lower() not in GENERIC_NAMES), "")
        percent = volume_percent(item)
        output.append({
            "id": item.get("index"),
            "name": name or binary.replace("-", " ").title() or "Audio",
            "binary": binary or node,
            "icon": text_property(properties, "application.icon_name", "application.icon-name") or node,
            "muted": bool(item.get("mute", False)),
            "volume": percent / 100,
            "volume_pct": percent,
        })
    print(json.dumps(output, separators=(",", ":")))


if __name__ == "__main__":
    main()
