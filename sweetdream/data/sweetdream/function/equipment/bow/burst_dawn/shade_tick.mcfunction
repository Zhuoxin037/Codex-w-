# ============================================================
# sweetdream:equipment/bow/burst_dawn/shade_tick —— 「魂灵之影」每秒推进
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute in <维度> as @e[distance=0..,tag=zx.bd_shade] at @s run ...
# 【执行者】魂灵之影(铁傀儡)
# 【本函数在"每维度各跑一次"的链上】不要出现裸 @e(本文件里一条都没有)。
# 【每秒做什么】
#   ① 魂火(它本体是隐身的, 主人靠这圈火 + 发光轮廓认位置)
#   ② 攻击倒计时 -1: 归零就打一下(shade_strike)并复位成 3 —— 即"每 3 秒"
#      ★ 倒计时必须写在**驱动方**(这里 = 每秒)而不是被驱动的那一次攻击里
#        (坑 120: 干活频率 ≠ 持续时间)。
#   ③ 「若生物索敌为自身, 则会转移索敌至魂灵之影」—— 见 taunt
#   ④ 寿命 -1: 20 -> 0, 到点消失
# ============================================================

# ① 表现
particle minecraft:soul ~ ~1.0 ~ 0.35 0.5 0.35 0.02 10 normal

# ② 每 3 秒打一次
scoreboard players remove @s zx.bd_cd 1
execute if score @s zx.bd_cd matches 0 run function sweetdream:equipment/bow/burst_dawn/shade_strike
execute if score @s zx.bd_cd matches 0 run scoreboard players set @s zx.bd_cd 3

# ③ 索敌转移: 把"正在追我主人"的生物的仇恨拉到自己身上
data modify storage zx:work bdt.u0 set from entity @s data.zx.bd.u0
data modify storage zx:work bdt.u1 set from entity @s data.zx.bd.u1
data modify storage zx:work bdt.u2 set from entity @s data.zx.bd.u2
data modify storage zx:work bdt.u3 set from entity @s data.zx.bd.u3
execute if score @s sdbf.so0 = @s sdbf.so0 store result storage zx:work bdt.u0 int 1 run scoreboard players get @s sdbf.so0
execute if score @s sdbf.so1 = @s sdbf.so1 store result storage zx:work bdt.u1 int 1 run scoreboard players get @s sdbf.so1
execute if score @s sdbf.so2 = @s sdbf.so2 store result storage zx:work bdt.u2 int 1 run scoreboard players get @s sdbf.so2
execute if score @s sdbf.so3 = @s sdbf.so3 store result storage zx:work bdt.u3 int 1 run scoreboard players get @s sdbf.so3
function sweetdream:equipment/bow/burst_dawn/taunt with storage zx:work bdt

# ④ 寿命: 20 秒 -> 0
scoreboard players remove @s zx.bd_ft 1
execute if score @s zx.bd_ft matches 1.. run return 0
particle minecraft:soul ~ ~1.0 ~ 0.4 0.6 0.4 0.05 24 normal
kill @s
