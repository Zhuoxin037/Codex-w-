execute store result score #cr_hp zx.meta run data get entity @s Health 1000
execute store result score #cr_max zx.meta run attribute @s minecraft:max_health get 1000
scoreboard players operation #cr_heal zx.meta = #cr_loss zx.meta
scoreboard players set #cr_two zx.meta 2
scoreboard players set #cr_ten zx.meta 10
scoreboard players operation #cr_heal zx.meta /= #cr_two zx.meta
scoreboard players operation #cr_limit zx.meta = #cr_max zx.meta
scoreboard players operation #cr_limit zx.meta /= #cr_ten zx.meta
execute if score #cr_heal zx.meta > #cr_limit zx.meta run scoreboard players operation #cr_heal zx.meta = #cr_limit zx.meta
scoreboard players operation #cr_hp zx.meta += #cr_heal zx.meta
execute if score #cr_hp zx.meta > #cr_max zx.meta run scoreboard players operation #cr_hp zx.meta = #cr_max zx.meta
execute store result entity @e[type=minecraft:villager,tag=zx.cr_body,distance=0..,limit=1] Health float .001 run scoreboard players get #cr_hp zx.meta
scoreboard players operation @s zx.j_hurt_hp = #cr_hp zx.meta
