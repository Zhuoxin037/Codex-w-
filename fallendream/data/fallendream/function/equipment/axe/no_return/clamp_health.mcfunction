execute store result score #nr_max zx.meta run attribute @s minecraft:max_health get 1000
scoreboard players operation #nr_delta zx.meta = @s zx.nr_hp
scoreboard players operation #nr_delta zx.meta -= #nr_max zx.meta
data modify storage zx:work nrclamp set value {amount:0.0}
execute store result storage zx:work nrclamp.amount double .001 run scoreboard players get #nr_delta zx.meta
function fallendream:equipment/axe/no_return/clamp_apply with storage zx:work nrclamp
