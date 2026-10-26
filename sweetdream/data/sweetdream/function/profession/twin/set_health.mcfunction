execute if score #jhpnew zx.meta matches ..0 run kill @s
execute if score #jhpnew zx.meta matches ..0 run return 0
execute if entity @s[tag=zx.heal_p] run attribute @s minecraft:max_health modifier remove sweetdream:heal_cap
execute if entity @s[tag=zx.heal_on] run attribute @s minecraft:max_health modifier remove sweetdream:heal_cap
tag @s remove zx.heal_p
tag @s remove zx.heal_on
execute store result score #jfull zx.meta run attribute @s minecraft:max_health get 1000
execute if score #jhpnew zx.meta > #jfull zx.meta run scoreboard players operation #jhpnew zx.meta = #jfull zx.meta
scoreboard players operation #jhealthcap zx.meta = #jhpnew zx.meta
scoreboard players operation #jhealthcap zx.meta -= #jfull zx.meta
execute store result storage zx:work hp.d double 0.001 run scoreboard players get #jhealthcap zx.meta
function sweetdream:lib/heal_up with storage zx:work hp
