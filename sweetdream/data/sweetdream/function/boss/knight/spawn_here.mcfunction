execute unless block ~ ~ ~ #sweetdream:boss_passable run return 0
execute unless block ~ ~4.38 ~ #sweetdream:boss_passable run return 0
function sweetdream_boss:dream_knight/summon {args:{animation:"idle"}}
execute as @e[tag=sweetdream_boss.dream_knight.root,tag=!sd.kn.rig,distance=..0.01,sort=nearest,limit=1] at @s run function sweetdream:boss/knight/bind
