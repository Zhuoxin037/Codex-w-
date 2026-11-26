tag @e[tag=sd.bs.target,distance=0..] remove sd.bs.target
execute if entity @s[tag=zx.j_eroded] run return run function fallendream:profession/twin/boss_forget
execute store result storage fallendream:b_staff args.id int 1 run scoreboard players get @s bs.id
function fallendream:boss/b_staff/target/load with storage fallendream:b_staff args
execute unless entity @e[tag=sd.bs.target,distance=0..] as @a[gamemode=!creative,gamemode=!spectator,distance=..24,sort=nearest,limit=1,nbt=!{Health:0.0f}] at @s run function fallendream:boss/b_staff/target/accept
