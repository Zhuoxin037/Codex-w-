# 结算技能之前先兑现未处理的原版损失，保存外层伤害参数。
data modify storage zx:work pn_inputs append from storage zx:work a
scoreboard players operation #pn_sid zx.meta = @s zx.sid
execute as @e[type=minecraft:marker,tag=zx.pn_watch,distance=0..] if score @s zx.sid = #pn_sid zx.meta at @s run function sweetdream:equipment/axe/throe/watch with entity @s data
data modify storage zx:work a set from storage zx:work pn_inputs[-1]
data remove storage zx:work pn_inputs[-1]
