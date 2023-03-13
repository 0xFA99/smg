#!/bin/bash

declare -a cpu_stats=()
declare -a ram_stats=()

update_cpu_stats() {
    local stats=($(grep -E '^cpu[ ]+' /proc/stat))

    cpu_stats=("${stats[@]:1}")
}

update_ram_stats() {
    local stats=($(grep -E '^(MemTotal|MemFree|Buffers|Cached):' /proc/meminfo | awk '{print $2}'))
    local used=$((stats[0] - stats[1] - stats[2] - stats[3]))

    ram_stats=("$used" "${stats[0]}")
}

get_cpu_usage() {
    local prev_stats=("${cpu_stats[@]}")
    update_cpu_stats
    local curr_stats=("${cpu_stats[@]}")

    local prev_total=($(IFS=+; echo "$((${prev_stats[*]}))"))
    local curr_total=($(IFS=+; echo "$((${curr_stats[*]}))"))

    local prev_idle=${prev_stats[3]}
    local curr_idle=${curr_stats[3]}

    local total=$((curr_total - prev_total))
    local idle=$((curr_idle - prev_idle))
    local usage=$((100 * (total - idle) / total))

    printf 'CPU: %d%%\n' "$usage"
}

get_ram_usage() {
    local prev_stats=("${ram_stats[@]}")
    update_ram_stats
    local curr_stats=("${ram_stats[@]}")

    local usage=$((100 * curr_stats[0] / curr_stats[1]))

    printf "RAM: %d%%\n" "$usage"
}

while true; do
    cpu_usage=$(get_cpu_usage)
    ram_usage=$(get_ram_usage)

    xsetroot -name " $cpu_usage | $ram_usage"

    sleep 1
done
