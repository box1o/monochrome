#!/usr/bin/env bash

set -uo pipefail

# shellcheck source=/dev/null
source "${BASH_SOURCE[0]%/*}/../.init.sh" || exit $?

script::init
script::parse "$@" || exit $?

if args::has help; then
    script::usage ''
    exit 0
fi

script::require_count 0 0 || exit $?

set -- "${SCRIPT_ARGS[@]}"

read -r _ a b c prev_idle rest < /proc/stat

prev_total=$((a + b + c + prev_idle))

for x in $rest; do prev_total=$((prev_total + x)); done

exec::query sleep 0.3

read -r _ a b c idle rest < /proc/stat

total=$((a + b + c + idle))

for x in $rest; do total=$((total + x)); done

dt=$((total - prev_total))
di=$((idle - prev_idle))
cpu=""

[ "$dt" -gt 0 ] && cpu=$(((dt - di) * 100 / dt))

mem=$(exec::query awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2}
           END{ if (t > 0) printf "%d", (t - a) * 100 / t }' /proc/meminfo)

tcpu=""

for h in /sys/class/hwmon/hwmon*; do
    case "$(exec::query cat "$h/name" 2> /dev/null)" in
        k10temp | coretemp | zenpower | cpu_thermal | acpitz_cpu)
            v=$(exec::query cat "$h/temp1_input" 2> /dev/null)

            [ -n "$v" ] && tcpu=$((v / 1000))
            break
            ;;
    esac
done

gpu=""
tgpu=""

for d in /sys/class/drm/card*/device; do
    [ -r "$d/gpu_busy_percent" ] || continue

    gpu=$(exec::query cat "$d/gpu_busy_percent" 2> /dev/null)
    break
done

for h in /sys/class/hwmon/hwmon*; do
    case "$(exec::query cat "$h/name" 2> /dev/null)" in
        amdgpu | nouveau | radeon | i915 | nvidia)
            v=$(exec::query cat "$h/temp1_input" 2> /dev/null)

            [ -n "$v" ] && tgpu=$((v / 1000))
            break
            ;;
    esac
done

if [ -z "$gpu" ] || [ -z "$tgpu" ]; then
    if proc::exists nvidia-smi; then
        line=$(exec::query timeout --signal=KILL 2 nvidia-smi --query-gpu=utilization.gpu,temperature.gpu \
            --format=csv,noheader,nounits 2> /dev/null | exec::query head -1)

        if [ -n "$line" ]; then
            [ -z "$gpu" ] && gpu=$(echo "$line" | exec::query cut -d, -f1 | exec::query tr -d ' ')
            [ -z "$tgpu" ] && tgpu=$(echo "$line" | exec::query cut -d, -f2 | exec::query tr -d ' ')
        fi
    fi
fi

printf '%s|%s|%s|%s|%s\n' "$cpu" "$mem" "$gpu" "$tcpu" "$tgpu"
