# ============================================================
# sweetdream:equipment/axe/deep_brine/field_tick —— 「领域」每秒一跳(执行者 = 领域 marker)
# ------------------------------------------------------------
# 【谁调用它】lib/second: 三维度各一行 as @e[tag=zx.db_field,distance=0..] at @s run ...
# 【每秒干什么】
#   ① 对领域内(半径 3 格)的**全部生物**打一次 施法者最大魔力值 ×0.03
#   ② 把领域内的生物**朝中心拉**一段(每次 0.5 格, 离中心 1 格以上才拉)
#   ③ 表现  ④ 计时 -1, 归零 kill 自己。
# 【伤害值从哪来】marker NBT 的 data.zx.dmg(施放那刻算好的);
#   归属用 data.zx.u 四个整数 —— 直接走 internal/damage/with_from 那套(抄神裁 field_tick)。
# 【为什么每秒不是每刻】技能原文"每秒受到一次" —— 每秒一结算。
# 【★ "持续被拉向中心"怎么落地(照海棠漩涡 vortex_tick) ★】
#   · 只拉"离中心还有 1 格以上"的(distance=1.01..3): 否则贴脸那只距离≈0、朝向退化,
#     会被顶得原地乱跳; 而且文案要的是"被拉向中心", 不是"瞬间吸进中心"。
#   · 每次挪 0.5 格; 目标格不是可替换方块就不动(= 遇到障碍即停, 与沉锚/海棠一致)。
#   · 圆心用临时标签 zx.db_center 钉住**本 marker**, 收尾立刻摘掉, 不留残余。
# ============================================================

# 伤害值 -> num_str
data modify storage zx:work a.num set value 0.0
data modify storage zx:work a.num set from entity @s data.zx.dmg
function sweetdream:lib/num/plain

# 目标: 领域(半径 3)内的全部生物。distance=..3 既给选择器位置基准(锁维度)也是范围。
data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,distance=..3]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type

# 归属: 施法者 UUID 四个整数
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]

function sweetdream:internal/damage/with_from with storage zx:work a

# ② 朝中心拉一段(圆心 = 本 marker)
tag @e[tag=zx.db_center,distance=0..] remove zx.db_center
tag @s add zx.db_center
tag @e[tag=zx.db_pull,distance=0..] remove zx.db_pull
tag @e[type=!#sweetdream:no_damage,distance=1.01..3] add zx.db_pull
execute as @e[tag=zx.db_pull,distance=0..] at @s facing entity @e[tag=zx.db_center,distance=0..,limit=1] feet positioned ^ ^ ^0.5 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~
tag @e[tag=zx.db_pull,distance=0..] remove zx.db_pull
tag @e[tag=zx.db_center,distance=0..] remove zx.db_center

# ③ 表现: 一圈向内收拢的海水
particle minecraft:bubble ~ ~0.3 ~ 2.6 0.4 2.6 0.0 16 normal
particle minecraft:splash ~ ~0.1 ~ 2.2 0.2 2.2 0.02 10 normal
playsound minecraft:entity.player.swim player @a ~ ~ ~ 0.35 0.9

# ④ 计时 -1, 归零收掉
scoreboard players remove @s zx.db_ft 1
execute if score @s zx.db_ft matches ..0 run kill @s
