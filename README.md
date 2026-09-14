# Villains Evolved — +1 Superhero Evolution spinoff (Villains)

Rojo 7.4.4 project. Incremental simulator: click Infamy → Heist dungeon (bank Heists) → buy Villains/Henchmen → World gates → Rebirth.

## Quick start
```sh
# install rojo (via aftman or cargo)
cargo install rojo --locked  # or aftman install
rojo serve                    # sync to Studio (Rojo plugin)
rojo build -o build.rbxlx     # build place
```
Open `build.rbxlx` in Roblox Studio → Publish to Roblox.

## Structure
- `src/shared/Config.lua` — all balancing (65 villains, henchmen, worlds)
- `src/shared/Morphs.lua` — ponytail morph builder (single rig + palette)
- `src/server/*` — Data/Power/Dungeon/Shop/Raids
- `src/client/*` — Click/UI/Morph

See `src/shared/Config.lua` for world/villain tables.
