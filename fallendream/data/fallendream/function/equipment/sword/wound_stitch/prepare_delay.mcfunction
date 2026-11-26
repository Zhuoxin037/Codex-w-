scoreboard players operation #wst_delay zx.meta = #wst_wound zx.meta
scoreboard players set #wst_three zx.meta 3
scoreboard players set #wst_two zx.meta 2
scoreboard players operation #wst_delay zx.meta *= #wst_three zx.meta
scoreboard players operation #wst_delay zx.meta /= #wst_two zx.meta
execute unless score #wst_delay zx.meta matches 1.. run return 0
data modify storage zx:work wst set value {num:0.0,type:"fallendream:true_damage",uncapped:1b,u0:0,u1:0,u2:0,u3:0,t0:0,t1:0,t2:0,t3:0}
execute store result storage zx:work wst.num double 0.001 run scoreboard players get #wst_delay zx.meta
execute store result storage zx:work wst.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work wst.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work wst.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work wst.u3 int 1 run scoreboard players get @s manacore.u3
execute as @e[tag=zx.ws_landed,distance=0..] at @s run function fallendream:equipment/sword/wound_stitch/delay_new
