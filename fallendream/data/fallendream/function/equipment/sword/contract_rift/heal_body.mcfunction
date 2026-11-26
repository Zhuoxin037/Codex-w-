execute store result score #cr_hp zx.meta run data get entity @s Health 1000
execute store result score #cr_max zx.meta run attribute @s minecraft:max_health get 1000
scoreboard players operation #cr_heal zx.meta = #cr_max zx.meta
scoreboard players set #cr_six zx.meta 6
scoreboard players set #cr_hundred zx.meta 100
scoreboard players operation #cr_heal zx.meta *= #cr_six zx.meta
scoreboard players operation #cr_heal zx.meta /= #cr_hundred zx.meta
scoreboard players operation #cr_hp zx.meta += #cr_heal zx.meta
execute if score #cr_hp zx.meta > #cr_max zx.meta run scoreboard players operation #cr_hp zx.meta = #cr_max zx.meta
tag @s add zx.cr_body_write
execute store result entity @e[type=minecraft:villager,tag=zx.cr_body_write,distance=0..,limit=1] Health float .001 run scoreboard players get #cr_hp zx.meta
tag @s remove zx.cr_body_write
scoreboard players operation @s zx.j_hurt_hp = #cr_hp zx.meta
