# 仅由本武器普攻实际扣费、发球成功后的末尾调用；技能展示有更高优先级。
execute if entity @s[tag=zx.fcvv_on] if score @s zx.fcvv_m matches 2 run return 0
execute if entity @s[tag=zx.fcvv_on] run function sweetdream:equipment/staff/five_curses/visual/end
scoreboard players set @s zx.fcvv_m 1
function sweetdream:equipment/staff/five_curses/visual/start
