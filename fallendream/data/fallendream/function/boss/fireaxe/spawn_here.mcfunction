# Synchronous summon/bind; no global nearest-entity ownership after this transaction.
execute unless block ~ ~ ~ #fallendream:boss_passable run return 0
execute unless block ~ ~2 ~ #fallendream:boss_passable run return 0
function fallendream_boss:reconstruction/summon {args:{animation:"idle"}}
execute as @e[tag=fallendream_boss.reconstruction.root,tag=!sd.fb.rig,distance=..0.01,limit=1,sort=nearest] at @s run function fallendream:boss/fireaxe/bind
