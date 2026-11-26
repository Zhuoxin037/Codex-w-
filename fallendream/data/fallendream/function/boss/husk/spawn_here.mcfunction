execute unless block ~ ~ ~ #fallendream:boss_passable run return 0
execute unless block ~ ~4.39 ~ #fallendream:boss_passable run return 0
function fallendream_boss:husk/summon {args:{animation:"combat_idle"}}
execute as @e[tag=fallendream_boss.husk.root,tag=!sd.hk.rig,distance=..0.01,sort=nearest,limit=1] at @s run function fallendream:boss/husk/bind
