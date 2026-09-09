#!/usr/bin/env bash
set -uo pipefail

read -r _ a b c prev_idle rest < /proc/stat
prev_total=$((a + b + c + prev_idle))
for x in $rest; do prev_total=$((prev_total + x)); done

sleep 0.3

read -r _ a b c idle rest < /proc/stat
total=$((a + b + c + idle))
for x in $rest; do total=$((total + x)); done

dt=$((total - prev_total))
di=$((idle - prev_idle))
cpu=""
[ "$dt" -gt 0 ] && cpu=$(( (dt - di) * 100 / dt ))

mem=$(awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2}
           END{ if (t > 0) printf "%d", (t - a) * 100 / t }' /proc/meminfo)

tcpu=""
for h in /sys/class/hwmon/hwmon*; do
    case "$(cat "$h/name" 2>/dev/null)" in
        k10temp|coretemp|zenpower|cpu_thermal|acpitz_cpu)
            v=$(cat "$h/temp1_input" 2>/dev/null)
            [ -n "$v" ] && tcpu=$((v / 1000))
            break
            ;;
    esac
done

gpu=""
tgpu=""
for d in /sys/class/drm/card*/device; do
    [ -r "$d/gpu_busy_percent" ] || continue
    gpu=$(cat "$d/gpu_busy_percent" 2>/dev/null)
    break
done
for h in /sys/class/hwmon/hwmon*; do
    case "$(cat "$h/name" 2>/dev/null)" in
        amdgpu|nouveau|radeon|i915|nvidia)
            v=$(cat "$h/temp1_input" 2>/dev/null)
            [ -n "$v" ] && tgpu=$((v / 1000))
            break
            ;;
    esac
done

if [ -z "$gpu" ] || [ -z "$tgpu" ]; then
    if command -v nvidia-smi >/dev/null 2>&1; then
        line=$(timeout --signal=KILL 2 nvidia-smi --query-gpu=utilization.gpu,temperature.gpu \
                          --format=csv,noheader,nounits 2>/dev/null | head -1)
        if [ -n "$line" ]; then
            [ -z "$gpu" ]  && gpu=$(echo "$line"  | cut -d, -f1 | tr -d ' ')
            [ -z "$tgpu" ] && tgpu=$(echo "$line" | cut -d, -f2 | tr -d ' ')
        fi
    fi
fi

printf '%s|%s|%s|%s|%s\n' "$cpu" "$mem" "$gpu" "$tcpu" "$tgpu"
