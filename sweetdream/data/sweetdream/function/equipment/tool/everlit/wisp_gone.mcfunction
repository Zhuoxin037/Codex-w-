# 精确删除这只 marker 的显示载体，不按距离误删别人的灯。
execute on vehicle if entity @s[type=minecraft:item_display,tag=zx.el_visual] run kill @s
particle minecraft:smoke ~ ~ ~ 0.12 0.15 0.12 0.005 4 normal
playsound minecraft:block.candle.extinguish player @a ~ ~ ~ 0.25 1.6
scoreboard players reset @s zx.el_cd
scoreboard players reset @s zx.el_clock
scoreboard players reset @s zx.el_state
scoreboard players reset @s zx.el_time
scoreboard players reset @s zx.el_attack
scoreboard players reset @s zx.el_mana
scoreboard players reset @s zx.el_last
scoreboard players reset @s zx.el_dim
kill @s
