scoreboard players operation #jvess zx.meta = @s zx.j_ess
scoreboard players operation #jtaken zx.meta += #jvess zx.meta
scoreboard players set @s zx.j_ess 0
tag @s add zx.j_ess_v
execute store result storage zx:work jt_consume.layers int 1 run scoreboard players get #jvess zx.meta
execute as @a[tag=zx.ub,limit=1] positioned ~ ~ ~ run function sweetdream:profession/twin/consume_damage
tag @s remove zx.j_ess_v
