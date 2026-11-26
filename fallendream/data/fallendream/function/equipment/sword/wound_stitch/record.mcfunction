execute store result score #wst_after zx.meta run data get entity @s Health 1000
scoreboard players operation #wst_add zx.meta = @s zx.ws_pre
scoreboard players operation #wst_add zx.meta -= #wst_after zx.meta
execute unless score #wst_add zx.meta matches 1.. run return 0
execute unless score @s zx.ws_until > #now manacore.meta run scoreboard players set @s zx.ws_wound 0
scoreboard players add @s zx.ws_wound 0
scoreboard players operation @s zx.ws_wound += #wst_add zx.meta
execute store result score #wst_cap zx.meta run attribute @s minecraft:max_health get 1000
execute if entity @s[tag=zx.nr_clamp] run function fallendream:lib/max_health_score
execute if entity @s[tag=zx.nr_clamp] run scoreboard players operation #wst_cap zx.meta = #max_hp zx.meta
scoreboard players set #wst_sixty zx.meta 60
scoreboard players set #wst_hundred zx.meta 100
scoreboard players operation #wst_cap zx.meta *= #wst_sixty zx.meta
scoreboard players operation #wst_cap zx.meta /= #wst_hundred zx.meta
execute if score @s zx.ws_wound > #wst_cap zx.meta run scoreboard players operation @s zx.ws_wound = #wst_cap zx.meta
scoreboard players operation @s zx.ws_until = #now manacore.meta
scoreboard players add @s zx.ws_until 200
function fallendream:equipment/sword/wound_stitch/view
