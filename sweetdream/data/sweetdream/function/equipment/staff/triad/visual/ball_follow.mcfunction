# 只跟随自己的 UUID 指针；不修改法球、目标和伤害。
scoreboard players set #tv_owner_alive zx.meta 0
$execute as $(uuid) if entity @s[type=minecraft:player] run function sweetdream:equipment/staff/triad/visual/owner_alive
execute unless score #tv_owner_alive zx.meta matches 1 run return run function sweetdream:equipment/staff/triad/visual/ball_end
$execute unless entity @e[type=minecraft:item_display,tag=zx.tv_missile,nbt={UUID:[I;$(tv_v0),$(tv_v1),$(tv_v2),$(tv_v3)]},distance=0..,limit=1] run return 0
$execute rotated $(yaw) $(pitch) run tp @e[type=minecraft:item_display,tag=zx.tv_missile,nbt={UUID:[I;$(tv_v0),$(tv_v1),$(tv_v2),$(tv_v3)]},distance=0..,limit=1] ~ ~ ~ ~ ~
$execute if score #ball_target_live zx.meta matches 1 facing entity $(target_uuid) eyes run tp @e[type=minecraft:item_display,tag=zx.tv_missile,nbt={UUID:[I;$(tv_v0),$(tv_v1),$(tv_v2),$(tv_v3)]},distance=0..,limit=1] ~ ~ ~ ~ ~
$data modify entity @e[type=minecraft:item_display,tag=zx.tv_missile,nbt={UUID:[I;$(tv_v0),$(tv_v1),$(tv_v2),$(tv_v3)]},distance=0..,limit=1] transformation.scale set value [1.0f,1.0f,1.0f]
$scoreboard players set @e[type=minecraft:item_display,tag=zx.tv_missile,nbt={UUID:[I;$(tv_v0),$(tv_v1),$(tv_v2),$(tv_v3)]},distance=0..,limit=1] zx.tv_life 3
$execute if data entity @s data{tri_form:0} run data modify entity @e[type=minecraft:item_display,tag=zx.tv_missile,nbt={UUID:[I;$(tv_v0),$(tv_v1),$(tv_v2),$(tv_v3)]},distance=0..,limit=1] item.components."minecraft:custom_model_data".floats[0] set from storage zx:triad_visual frame.value
