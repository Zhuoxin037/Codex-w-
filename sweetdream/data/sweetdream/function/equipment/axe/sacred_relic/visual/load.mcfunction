# 圣骸外观专用；重载只复位视觉，不修改技能计时、伤害或遗骸。
execute unless data storage zx:config obj_srv_i run scoreboard objectives add zx.srv_i dummy
data modify storage zx:config obj_srv_i set value 1b
execute unless data storage zx:config obj_srv_start run scoreboard objectives add zx.srv_start dummy
data modify storage zx:config obj_srv_start set value 1b
execute unless data storage zx:config obj_srv_frame run scoreboard objectives add zx.srv_frame dummy
data modify storage zx:config obj_srv_frame set value 1b
execute unless data storage zx:config obj_srv_pulse run scoreboard objectives add zx.srv_pulse dummy
data modify storage zx:config obj_srv_pulse set value 1b
scoreboard players add @a zx.srv_i 0
scoreboard players set @a zx.srv_pulse -1
tag @a remove zx.srv_cast
