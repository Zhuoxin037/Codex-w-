execute unless block ~ ~ ~ #sweetdream:boss_passable run return 0
execute unless block ~ ~2.95 ~ #sweetdream:boss_passable run return 0
function sweetdream_boss:husk/summon {args:{animation:"combat_idle"}}
execute as @e[tag=sweetdream_boss.husk.root,tag=!sd.hk.rig,distance=..0.01,sort=nearest,limit=1] at @s run function sweetdream:boss/husk/bind
