execute store result score @s zx.atk_ok run data get storage zx:combat events[-1].event.old_charge
execute if data storage zx:combat events[-1].event{owns_chain:1b} run function fallendream:internal/attack/chain_close with storage zx:combat events[-1].event
data remove storage zx:combat events[-1]
