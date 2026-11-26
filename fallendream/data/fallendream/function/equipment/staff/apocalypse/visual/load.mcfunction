# 启示录视觉专用计分板；不改魔力、伤害及原技能秒计时。
scoreboard objectives add zx.apv dummy
scoreboard objectives add zx.apvi dummy
scoreboard objectives add zx.apvc dummy
# 重载发生在施法中时回到居中待发，保留已消耗页数；旧存档没有该计分项时补 0。
scoreboard players add @a zx.apvc 0
scoreboard players add @a zx.apvi 0
tag @a remove zx.apv_active
scoreboard players set @a zx.apv 0
execute as @a[scores={zx.ap_on=1..}] run scoreboard players set @s zx.apv 150
tag @a[scores={zx.ap_on=1..}] add zx.apv_active
