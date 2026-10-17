scoreboard players operation @s zx.fcvv_s = #now manacore.meta
scoreboard players set @s zx.fcvv_h 0
scoreboard players set @s zx.fcvv_slot 0
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["five_curses"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["five_curses"]}] run scoreboard players set @s zx.fcvv_h 1
# 消耗到回手的一刻，源手可能已空；框架的准确原槽镜像补充副手判定。
execute if entity @s[tag=test_pending_return] if score @s zx.ret_slot matches -1 run scoreboard players set @s zx.fcvv_h 1
execute if score @s zx.fcvv_h matches 0 store result score @s zx.fcvv_slot run data get entity @s SelectedItemSlot
function sweetdream:equipment/staff/five_curses/visual/dimension
scoreboard players operation @s zx.fcvv_d = #fcvv_dim zx.fcvv_f
tag @s add zx.fcvv_on
