# @s=有过专属状态的生物；缓存只属于显示，不参与技能。
function sweetdream:tag/custom_mask
execute if score #tag_extra zx.meta matches 0 run tag @s remove zx.icon_custom
execute if score #tag_extra zx.meta matches 1.. unless entity @s[tag=zx.tagged] run scoreboard players set @s zx.icon_ext -1
execute if score @s zx.icon_ext = #tag_extra zx.meta run return 0
scoreboard players operation @s zx.icon_ext = #tag_extra zx.meta
function sweetdream:tag/icon_refresh
