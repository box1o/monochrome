#!/usr/bin/env python3
"""List NetworkManager Wi-Fi access points for the QML network panel."""

from __future__ import annotations

import subprocess
import sys


def run_nmcli(*arguments: str) -> list[str]:
    try:
        result = subprocess.run(
            ["nmcli", "-t", "--escape", "yes", *arguments],
            check=True,
            capture_output=True,
            text=True,
            timeout=4,
        )
        return result.stdout.splitlines()
    except (OSError, subprocess.SubprocessError):
        return []


def split_fields(line: str) -> list[str]:
    fields, field, escaped = [], [], False
    for character in line:
        if escaped:
            field.append(character)
            escaped = False
        elif character == "\\":
            escaped = True
        elif character == ":":
            fields.append("".join(field))
            field = []
        else:
            field.append(character)
    if escaped:
        field.append("\\")
    fields.append("".join(field))
    return fields


def saved_networks() -> set[str]:
    output = set()
    for line in run_nmcli("-f", "TYPE,NAME", "connection", "show"):
        fields = split_fields(line)
        if len(fields) == 2 and fields[0] == "802-11-wireless":
            output.add(fields[1])
    return output


def main() -> None:
    if len(sys.argv) != 2 or not sys.argv[1]:
        raise SystemExit("usage: wifi_networks.py INTERFACE")
    known = saved_networks()
    lines = run_nmcli(
        "-f", "IN-USE,SSID,SECURITY,SIGNAL", "device", "wifi", "list", "ifname", sys.argv[1]
    )
    networks: dict[str, tuple[str, str, str, str, str]] = {}
    for line in lines:
        fields = split_fields(line)
        if len(fields) != 4 or not fields[1]:
            continue
        active, ssid, security, signal = fields
        ssid = ssid.replace("|", "")
        security = (security or "open").lower().replace("|", "/")
        record = (
            "yes" if active == "*" else "no",
            ssid,
            security,
            signal,
            "yes" if ssid in known else "no",
        )
        previous = networks.get(ssid)
        if previous is None or record[0] == "yes" or int(signal or 0) > int(previous[3] or 0):
            networks[ssid] = record
    def ordering(item: tuple[str, str, str, str, str]) -> tuple[bool, int]:
        return item[0] == "yes", int(item[3] or 0)

    for record in sorted(networks.values(), key=ordering, reverse=True):
        print("|".join(record))


if __name__ == "__main__":
    main()
