# 每个玩家只推进一次；双持不会加速，玩家执行上下文自动覆盖当前所在维度。
execute as @a[tag=zx.fcvv_on] at @s run function sweetdream:equipment/staff/five_curses/visual/advance
execute as @a[tag=!test_pending_return] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["five_curses"]}] at @s run function sweetdream:equipment/staff/five_curses/visual/held
execute as @a[tag=!test_pending_return] unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["five_curses"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["five_curses"]}] at @s run function sweetdream:equipment/staff/five_curses/visual/held
