# 4秒待机=20个姿态×4刻；只修改floats[0]，保留其他CMD通道及所有物品数据。
scoreboard players add @s zx.fcvv_i 1
execute if score @s zx.fcvv_i matches 80.. run scoreboard players set @s zx.fcvv_i 0
scoreboard players operation #fcvv_frame zx.fcvv_f = @s zx.fcvv_i
scoreboard players operation #fcvv_frame zx.fcvv_f /= #fcvv_four zx.fcvv_f
execute if entity @s[tag=zx.fcvv_on] run function sweetdream:equipment/staff/five_curses/visual/cast_frame
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["five_curses"]}] run function sweetdream:equipment/staff/five_curses/visual/mainhand
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["five_curses"]}] run function sweetdream:equipment/staff/five_curses/visual/offhand
