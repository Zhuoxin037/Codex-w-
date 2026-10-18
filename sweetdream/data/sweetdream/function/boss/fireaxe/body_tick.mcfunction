execute unless entity @s[tag=sd.fb.carrier_ui_v1] run function sweetdream:boss/fireaxe/visual/carrier_label
tag @s add sd.fb.current_body
execute store result score @s sdbf.hp run data get entity @s Health 1
execute store result storage sweetdream:fireaxe args.id int 1 run scoreboard players get @s sdbf.id
function sweetdream:boss/fireaxe/bar_update with storage sweetdream:fireaxe args
execute if entity @s[tag=zx.stop] run tag @e[tag=sd.fb.current_rig,limit=1,distance=0..] add sd.fb.frozen
execute if entity @s[tag=zx.stop] run return run tag @s remove sd.fb.current_body
data modify entity @s NoAI set value 1b
execute unless data entity @s active_effects[{id:"minecraft:invisibility"}] run effect give @s minecraft:invisibility infinite 0 true
execute if score @s sdbf.rest matches 1.. run scoreboard players remove @s sdbf.rest 1
execute if score @s sdbf.dashcd matches 1.. run scoreboard players remove @s sdbf.dashcd 1
execute if score @s sdbf.jumpcd matches 1.. run scoreboard players remove @s sdbf.jumpcd 1
execute if score @s sdbf.shortcd matches 1.. run scoreboard players remove @s sdbf.shortcd 1
execute at @s run function sweetdream:boss/fireaxe/ground/tick
execute at @s run function sweetdream:boss/fireaxe/target/tick
execute at @s run function sweetdream:boss/fireaxe/phase/check
execute unless score @s sdbf.armorphase = @s sdbf.phase run function sweetdream:boss/fireaxe/mechanics/armor
execute if score @s sdbf.state matches 2.. at @s run function sweetdream:boss/fireaxe/action_tick
execute if score @s sdbf.state matches ..1 unless score @s sdbf.fall matches 1.. at @s run function sweetdream:boss/fireaxe/decide
execute at @s rotated ~ 0 run tp @e[tag=sd.fb.current_rig,limit=1,distance=0..] ~ ~ ~ ~ 0
tag @e[tag=sd.fb.target,distance=0..] remove sd.fb.target
tag @s remove sd.fb.current_body
