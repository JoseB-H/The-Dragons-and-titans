#!/usr/bin/env bash
# Ejecutar desde cualquier directorio con Godot 4.6.3 y una pantalla X11.
set -eu -o pipefail
project=$(cd "$(dirname "$0")/../game" && pwd)
godot=${GODOT_BIN:-godot}
logs=$(mktemp -d)
export XDG_DATA_HOME="$logs/data" XDG_CONFIG_HOME="$logs/config"
mkdir -p "$XDG_DATA_HOME" "$XDG_CONFIG_HOME"
printf 'Godot %s\nRegistros: %s\n' "$("$godot" --version)" "$logs"
"$godot" --headless --path "$project" --import >"$logs/import.log" 2>&1 || { cat "$logs/import.log"; exit 1; }

run() {
    timeout 360 "$godot" --path "$project" --audio-driver Dummy "$@" --script "res://tests/$name.gd"
}
lan() {
    run_lan host >"$logs/host.log" 2>&1 &
    local host_pid=$! status=0
    sleep 1
    run_lan join >"$logs/join.log" 2>&1 || status=1
    wait "$host_pid" || status=1
    cat "$logs/host.log" "$logs/join.log"
    return "$status"
}
run_lan() {
    timeout 30 "$godot" --headless --path "$project" --script "res://tests/$name.gd" -- "$1"
}
passed=0
failed=0
for script in "$project"/tests/test_*.gd; do
    name=$(basename "$script" .gd)
    rc=0
    case "$name" in
        test_lan_duel) lan >"$logs/$name.log" 2>&1 || rc=$? ;;
        *_window|test_gallery|test_presentation|test_frontier|test_siege_arena) run --fixed-fps 60 --rendering-driver opengl3 >"$logs/$name.log" 2>&1 || rc=$? ;;
        *) run --fixed-fps 60 --headless >"$logs/$name.log" 2>&1 || rc=$? ;;
    esac
    if ((rc == 0)) && ! grep -q 'SCRIPT ERROR:' "$logs/$name.log"; then
        echo "PASA  $name"
        passed=$((passed + 1))
    else
        echo "FALLA $name (salida $rc)"
        tail -12 "$logs/$name.log"
        failed=$((failed + 1))
    fi
done
echo "Total $((passed + failed)) | Pasan $passed | Fallan $failed"
((failed == 0))
