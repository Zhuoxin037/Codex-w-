execute store result score #cr_hp zx.meta run data get entity @s Health 1000
execute store result score #cr_max zx.meta run attribute @s minecraft:max_health get 1000
execute if entity @s[tag=zx.heal_p] if score #cr_max zx.meta > #cr_hp zx.meta run scoreboard players operation #cr_hp zx.meta = #cr_max zx.meta
execute if entity @s[tag=zx.heal_on] if score #cr_max zx.meta > #cr_hp zx.meta run scoreboard players operation #cr_hp zx.meta = #cr_max zx.meta
execute if entity @s[tag=zx.heal_p] run attribute @s minecraft:max_health modifier remove fallendream:heal_cap
execute if entity @s[tag=zx.heal_on] run attribute @s minecraft:max_health modifier remove fallendream:heal_cap
tag @s remove zx.heal_p
tag @s remove zx.heal_on
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
scoreboard players operation #cr_hp zx.meta -= #cr_max zx.meta
data modify storage zx:work hp set value {d:0.0}
execute store result storage zx:work hp.d double .001 run scoreboard players get #cr_hp zx.meta
function fallendream:lib/heal_up with storage zx:work hp
