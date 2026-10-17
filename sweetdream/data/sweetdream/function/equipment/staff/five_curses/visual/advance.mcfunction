execute unless score @s zx.fcvv_m matches 1..2 run return run function sweetdream:equipment/staff/five_curses/visual/end
execute if entity @s[nbt={Health:0.0f}] run return run function sweetdream:equipment/staff/five_curses/visual/end
scoreboard players operation #fcvv_age zx.fcvv_f = #now manacore.meta
scoreboard players operation #fcvv_age zx.fcvv_f -= @s zx.fcvv_s
execute if score #fcvv_age zx.fcvv_f matches ..-1 run return run function sweetdream:equipment/staff/five_curses/visual/end
execute if score @s zx.fcvv_m matches 1 if score #fcvv_age zx.fcvv_f matches 11.. run return run function sweetdream:equipment/staff/five_curses/visual/end
execute if score @s zx.fcvv_m matches 2 if score #fcvv_age zx.fcvv_f matches 29.. run return run function sweetdream:equipment/staff/five_curses/visual/end
function sweetdream:equipment/staff/five_curses/visual/dimension
execute unless score @s zx.fcvv_d = #fcvv_dim zx.fcvv_f run return run function sweetdream:equipment/staff/five_curses/visual/end
# 回手时不写空槽或别的物品；真实时间照常流逝。
execute if entity @s[tag=test_pending_return] run return 0
scoreboard players set #fcvv_slot zx.fcvv_f -1
execute if score @s zx.fcvv_h matches 0 store result score #fcvv_slot zx.fcvv_f run data get entity @s SelectedItemSlot
execute if score @s zx.fcvv_h matches 0 unless score @s zx.fcvv_slot = #fcvv_slot zx.fcvv_f run return run function sweetdream:equipment/staff/five_curses/visual/end
execute if score @s zx.fcvv_h matches 0 unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["five_curses"]}] run return run function sweetdream:equipment/staff/five_curses/visual/end
execute if score @s zx.fcvv_h matches 1 unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["five_curses"]}] run return run function sweetdream:equipment/staff/five_curses/visual/end
