#!/usr/bin/env bash
set -u
case "${1:-status}" in
  status)
    nmcli -t -f GENERAL.STATE,GENERAL.CONNECTION,IP4.ADDRESS device show 2>/dev/null | sed -n 's/^GENERAL.STATE:\([0-9]*\).*/state=\1/p; s/^GENERAL.CONNECTION:\(.*\)/name=\1/p; s/^IP4.ADDRESS\[[0-9]*\]:\([^/]*\).*/ip=\1/p' | head -3
    ;;
  reconnect) nmcli networking off 2>/dev/null; sleep 1; nmcli networking on 2>/dev/null ;;
  *) printf 'usage: %s status|reconnect\n' "${0##*/}" >&2; exit 2 ;;
esac
