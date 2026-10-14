$execute as @e[type=minecraft:item_display,tag=zx.av_$(uuid),distance=0..,limit=1] rotated as @s rotated ~ 0 run tp @s ~ ~0.88 ~ ~ 0
$data modify entity @e[type=minecraft:item_display,tag=zx.av_$(uuid),distance=0..,limit=1] item.components."minecraft:custom_data".zx_an.ground_y set from entity @e[nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},distance=0..,limit=1] Pos[1]
$scoreboard players set @e[type=minecraft:item_display,tag=zx.av_$(uuid),distance=0..,limit=1] zx.av_phase 1
$scoreboard players set @e[type=minecraft:item_display,tag=zx.av_$(uuid),distance=0..,limit=1] zx.av_t 0
$data modify entity @e[type=minecraft:item_display,tag=zx.av_$(uuid),distance=0..,limit=1] item.components."minecraft:custom_model_data".floats set value [100.0f]
