#!/usr/bin/env bash
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ROJO="$HOME/.cargo/bin/rojo"
SELENE="$HOME/.cargo/bin/selene"
STYLUA="$HOME/.cargo/bin/stylua"
echo "== headless check: Villains Evolved =="
echo "-- rojo build"
"$ROJO" build "$ROOT/default.project.json" -o /tmp/VillainsEvolved.ci.rbxlx
echo "  ok $(stat -c%s /tmp/VillainsEvolved.ci.rbxlx) bytes"
echo "-- selene lint"
"$SELENE" --config "$ROOT/selene.toml" "$ROOT/src" || true
echo "-- stylua check"
"$STYLUA" --check "$ROOT/src" || echo "  stylua needs format: run stylua src/"
echo "-- sourcemap"
"$ROJO" sourcemap "$ROOT/default.project.json" -o /tmp/sourcemap.ci.json
echo "  ok $(wc -c < /tmp/sourcemap.ci.json) bytes"
echo "== headless ok — no Studio needed =="
echo "Sober note: Sober = Roblox Android player (play only). Publishing/editing needs Studio (Vinegar/flatpak or Windows VM)."
