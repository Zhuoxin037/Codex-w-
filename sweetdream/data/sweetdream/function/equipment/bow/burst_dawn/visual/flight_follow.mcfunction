$execute unless entity @e[type=#sweetdream:cc_arrow,nbt={UUID:[I;$(a0),$(a1),$(a2),$(a3)]},distance=0..,limit=1] run kill @s
$execute unless entity @e[type=#sweetdream:cc_arrow,nbt={UUID:[I;$(a0),$(a1),$(a2),$(a3)]},distance=0..,limit=1] run return 0
$execute at @e[type=#sweetdream:cc_arrow,nbt={UUID:[I;$(a0),$(a1),$(a2),$(a3)]},distance=0..,limit=1] rotated ~180 ~ run tp @s ~ ~ ~ ~ ~
scoreboard players operation #bv_pose zx.meta = #now manacore.meta
scoreboard players set #bv_eight zx.meta 8
scoreboard players operation #bv_pose zx.meta %= #bv_eight zx.meta
execute store result entity @s item.components."minecraft:custom_model_data".floats[0] float 1 run scoreboard players get #bv_pose zx.meta
$execute if entity @e[type=#sweetdream:cc_arrow,nbt={UUID:[I;$(a0),$(a1),$(a2),$(a3)]},distance=0..,limit=1,nbt={inGround:1b},tag=!zx.bv_impacted] at @e[type=#sweetdream:cc_arrow,nbt={UUID:[I;$(a0),$(a1),$(a2),$(a3)]},distance=0..,limit=1] run function sweetdream:equipment/bow/burst_dawn/visual/impact
$execute if entity @e[type=#sweetdream:cc_arrow,nbt={UUID:[I;$(a0),$(a1),$(a2),$(a3)]},distance=0..,limit=1,nbt={inGround:1b}] run kill @s
