# 取消视觉并复位原格，绝不替换或删除玩家物品。
scoreboard players set #fcvv_frame zx.fcvv_f 0
data modify storage zx:fcvv reset set value {slot:0}
execute if score @s zx.fcvv_slot matches 0..8 store result storage zx:fcvv reset.slot int 1 run scoreboard players get @s zx.fcvv_slot
execute if score @s zx.fcvv_h matches 0 run function sweetdream:equipment/staff/five_curses/visual/reset_slot with storage zx:fcvv reset
execute if score @s zx.fcvv_h matches 1 if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["five_curses"]}] run item modify entity @s weapon.offhand sweetdream:five_curses_visual/frame
tag @s remove zx.fcvv_on
scoreboard players set @s zx.fcvv_m 0
scoreboard players set @s zx.fcvv_s 0
