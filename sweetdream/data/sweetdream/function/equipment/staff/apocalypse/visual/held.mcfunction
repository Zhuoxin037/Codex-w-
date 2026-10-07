# 换回旧书或新拿到另一件书，都会按当前玩家状态修复其帧号与 item_model。
scoreboard players add @s zx.apvi 1
execute if score @s zx.apvi matches 100.. run scoreboard players set @s zx.apvi 0
scoreboard players set #frame zx.apv 0
execute unless entity @s[tag=zx.apv_active] if score @s zx.apvi matches 76..87 run scoreboard players operation #frame zx.apv = @s zx.apvi
execute unless entity @s[tag=zx.apv_active] if score @s zx.apvi matches 76..87 run scoreboard players remove #frame zx.apv 75
execute if entity @s[tag=zx.apv_active] run scoreboard players operation #frame zx.apv = @s zx.apv
data modify storage zx:work ap_visual set value {frame:0}
execute store result storage zx:work ap_visual.frame int 1 run scoreboard players get #frame zx.apv
function sweetdream:equipment/staff/apocalypse/visual/apply with storage zx:work ap_visual
