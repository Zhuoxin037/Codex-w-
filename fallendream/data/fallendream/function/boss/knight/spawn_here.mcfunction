execute unless block ~ ~ ~ #fallendream:boss_passable run return 0
execute unless block ~ ~4.38 ~ #fallendream:boss_passable run return 0
function fallendream_boss:dream_knight/summon {args:{animation:"idle"}}
execute as @e[tag=fallendream_boss.dream_knight.root,tag=!sd.kn.rig,distance=..0.01,sort=nearest,limit=1] at @s run function fallendream:boss/knight/bind
