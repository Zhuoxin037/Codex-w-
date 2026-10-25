# 身上主体仅手持时显示；技能黑片与烟带另属背后，不占肩部。
$execute if score @s zx.hp_c matches ..0 run kill @e[tag=zx.bv_sh,tag=zx.bv_$(uuid),distance=0..,limit=1]
$execute if score @s zx.hp_c matches ..0 run kill @e[tag=zx.bv_backfx,tag=zx.bv_$(uuid),distance=0..,limit=1]
execute if score @s zx.hp_c matches ..0 run scoreboard players set @s zx.bv_back 0
execute if score @s zx.hp_c matches ..0 run return 0
$execute unless score #bv_held zx.meta matches 1 run kill @e[tag=zx.bv_sh,tag=zx.bv_$(uuid),distance=0..,limit=1]
execute unless score #bv_held zx.meta matches 1 run tag @s remove zx.bv_wearing
execute if score #bv_held zx.meta matches 1 run function sweetdream:equipment/bow/burst_dawn/visual/hand_pose
$execute if score #bv_held zx.meta matches 1 unless entity @e[tag=zx.bv_sh,tag=zx.bv_$(uuid),distance=0..,limit=1] run function sweetdream:equipment/bow/burst_dawn/visual/shoulder_spawn with storage zx:work bvk
$execute if score #bv_held zx.meta matches 1 at @s rotated ~180 0 run tp @e[tag=zx.bv_sh,tag=zx.bv_$(uuid),distance=0..,limit=1] ~ ~ ~ ~ ~
$execute if score #bv_held zx.meta matches 1 run execute store result entity @e[tag=zx.bv_sh,tag=zx.bv_$(uuid),distance=0..,limit=1] item.components."minecraft:custom_model_data".floats[0] float 1 run scoreboard players get #bv_pose zx.meta
execute if score #bv_held zx.meta matches 1 run tag @s add zx.bv_wearing
scoreboard players add @s zx.bv_back 0
execute if score @s zx.bd_on matches 1 unless score @s zx.bv_back matches 1 run scoreboard players set @s zx.bv_age 0
execute if score @s zx.bd_on matches 1 run scoreboard players set @s zx.bv_back 1
execute unless score @s zx.bd_on matches 1 if score @s zx.bv_back matches 1 run scoreboard players set @s zx.bv_age 0
execute unless score @s zx.bd_on matches 1 if score @s zx.bv_back matches 1 run scoreboard players set @s zx.bv_back 2
$execute if score @s zx.bv_back matches 1.. unless entity @e[tag=zx.bv_backfx,tag=zx.bv_$(uuid),distance=0..,limit=1] run function sweetdream:equipment/bow/burst_dawn/visual/back_spawn with storage zx:work bvk
execute if score @s zx.bv_back matches 1.. run function sweetdream:equipment/bow/burst_dawn/visual/back_pose
# 背效采用玩家原水平朝向；额外转180度会将原生背后挂点翻到身前。
$execute if score @s zx.bv_back matches 1.. at @s rotated ~ 0 run tp @e[tag=zx.bv_backfx,tag=zx.bv_$(uuid),distance=0..,limit=1] ~ ~ ~ ~ ~
$execute if score @s zx.bv_back matches 1.. run execute store result entity @e[tag=zx.bv_backfx,tag=zx.bv_$(uuid),distance=0..,limit=1] item.components."minecraft:custom_model_data".floats[0] float 1 run scoreboard players get #bv_pose zx.meta
$execute if score @s zx.bv_back matches 2 if score @s zx.bv_age matches 14.. run kill @e[tag=zx.bv_backfx,tag=zx.bv_$(uuid),distance=0..,limit=1]
execute if score @s zx.bv_back matches 2 if score @s zx.bv_age matches 14.. run scoreboard players set @s zx.bv_back 0
