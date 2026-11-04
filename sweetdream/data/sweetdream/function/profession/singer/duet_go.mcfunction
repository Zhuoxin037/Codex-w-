scoreboard players add @s zx.j_duet_n 1
scoreboard players operation @s zx.j_duet_last = #now manacore.meta
tag @e[tag=zx.j_duet_v,distance=0..16] remove zx.j_duet_v
tag @e[type=!#sweetdream:no_damage,distance=..3] add zx.j_duet_v
execute as @a[tag=zx.ub,scores={zx.job=3,zx.j_aw=1},limit=1] positioned ~ ~ ~ run function sweetdream:profession/singer/duet_damage
tag @e[tag=zx.j_duet_v,distance=0..16] remove zx.j_duet_v
