# Synchronous summon/bind; no global nearest-entity ownership after this transaction.
execute unless block ~ ~ ~ #sweetdream:boss_passable run return 0
execute unless block ~ ~2 ~ #sweetdream:boss_passable run return 0
function sweetdream_boss:reconstruction/summon {args:{animation:"idle"}}
execute as @e[tag=sweetdream_boss.reconstruction.root,tag=!sd.fb.rig,distance=..0.01,limit=1,sort=nearest] at @s run function sweetdream:boss/fireaxe/bind
