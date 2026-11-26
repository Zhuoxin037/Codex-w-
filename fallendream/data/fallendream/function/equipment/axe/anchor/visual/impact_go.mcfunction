$execute store success score #s2_moved zx.meta run execute as @e[type=minecraft:item_display,tag=zx.av_$(uuid),distance=0..,limit=1] rotated as @s rotated ~ 0 run tp @s ~ ~0.88 ~ ~ 0
execute if score #s2_moved zx.meta matches 1 at @s run function fallendream:equipment/armor/empty_cicada/moved
$data modify entity @e[type=minecraft:item_display,tag=zx.av_$(uuid),distance=0..,limit=1] item.components."minecraft:custom_data".zx_an.ground_y set from entity @e[tag=zx.an_lock,scores={zx.an_own=$(u0)},distance=0..,limit=1] Pos[1]
$scoreboard players set @e[type=minecraft:item_display,tag=zx.av_$(uuid),distance=0..,limit=1] zx.av_phase 1
$scoreboard players set @e[type=minecraft:item_display,tag=zx.av_$(uuid),distance=0..,limit=1] zx.av_t 0
$data modify entity @e[type=minecraft:item_display,tag=zx.av_$(uuid),distance=0..,limit=1] item.components."minecraft:custom_model_data".floats set value [100.0f]
