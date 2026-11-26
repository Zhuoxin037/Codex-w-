scoreboard players add #attack_chain zx.meta 1
execute store result storage zx:combat events[-1].event.chain int 1 run scoreboard players get #attack_chain zx.meta
data modify storage zx:combat events[-1].event.owns_chain set value 1b
scoreboard players set @s zx.mi_armed 0
function fallendream:internal/attack/chain_seed with storage zx:combat events[-1].event
