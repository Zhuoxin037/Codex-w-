# @s = 准确死者, 已由致死回调/真正的击杀进度确认死亡。无需 @e 查尸体。
# 一只死者一具遗骸, 同刻多杀与相邻死亡互不吞并; 多入口重入仍只生成一次。
execute if entity @s[type=#sweetdream:no_damage] run return 0
execute if entity @s[tag=zx.sr_done] run return 0
execute unless data entity @s {Health:0.0f} run return 0
tag @s add zx.sr_done
tag @e[type=minecraft:marker,tag=zx.sr_new,distance=0..] remove zx.sr_new
summon minecraft:marker ~ ~ ~ {Tags:["zx.sr_relic","zx.sr_new"],data:{zx:{hp:20.0}}}
# 属性 get 默认整数返回; 用千分刻度保留最大生命的小数。
execute store result entity @e[type=minecraft:marker,tag=zx.sr_new,distance=0..,limit=1] data.zx.hp double 0.001 run attribute @s minecraft:max_health get 1000
execute if entity @s[tag=zx.status.liuhuo] run data modify entity @e[type=minecraft:marker,tag=zx.sr_new,distance=0..,limit=1] data.zx.lh set value 1b
execute if entity @s[tag=zx.status.yehuo] run data modify entity @e[type=minecraft:marker,tag=zx.sr_new,distance=0..,limit=1] data.zx.ye set value 1b
execute if entity @s[tag=zx.status.shixin] run data modify entity @e[type=minecraft:marker,tag=zx.sr_new,distance=0..,limit=1] data.zx.sx set value 1b
execute if entity @s[tag=zx.status.dream] run data modify entity @e[type=minecraft:marker,tag=zx.sr_new,distance=0..,limit=1] data.zx.dm set value 1b
execute if entity @s[tag=zx.status.yuanhai] run data modify entity @e[type=minecraft:marker,tag=zx.sr_new,distance=0..,limit=1] data.zx.yh set value 1b
# 12 秒 = 240 刻, 到期时刻与秒心跳相位无关。
scoreboard players operation @e[type=minecraft:marker,tag=zx.sr_new,distance=0..,limit=1] zx.sr_ft = #now manacore.meta
scoreboard players add @e[type=minecraft:marker,tag=zx.sr_new,distance=0..,limit=1] zx.sr_ft 240
execute at @e[type=minecraft:marker,tag=zx.sr_new,distance=0..,limit=1] run particle minecraft:dust{color:[0.86,0.86,0.78],scale:1.2} ~ ~0.4 ~ 0.5 0.5 0.5 0 18 normal
tag @e[type=minecraft:marker,tag=zx.sr_new,distance=0..] remove zx.sr_new
scoreboard players add #sr_ok zx.meta 1
