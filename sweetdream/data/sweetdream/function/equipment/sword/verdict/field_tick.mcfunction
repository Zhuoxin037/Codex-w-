# ============================================================
# sweetdream:equipment/sword/verdict/field_tick —— 领域每秒一跳(执行者=领域 marker)
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute as @e[tag=zx.vd_field] at @s run function ...
# 【每秒干什么】① 对领域内(半径 2 格)的全部生物打一次"施放者基础攻击力 ×3"
#   ② 计时 -1, 归零 kill 自己。
# 【伤害值从哪来】marker NBT 的 data.zx.dmg(施放那刻算好的); 归属用 data.zx.u 四个整数。
#   这里直接走 internal/damage/with_from 那套(带 num_str/target/type/u0..u3)。
# 【为什么每秒不是每刻】技能原文"每秒受到一次" —— 每秒一结算。
# ============================================================

# 伤害值 -> num_str
data modify storage zx:work a.num set value 0.0
data modify storage zx:work a.num set from entity @s data.zx.dmg
function sweetdream:lib/num/plain

# 目标: 领域(2 格)内的全部生物。distance=..2 既给选择器位置基准(锁维度)也是范围。
data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,distance=..2]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type

# 归属: 施放者 UUID 四个整数
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]

function sweetdream:internal/damage/with_from with storage zx:work a

# 表现: 领域里一圈缓缓上升的圣辉
particle minecraft:end_rod ~ ~0.2 ~ 1.4 0.2 1.4 0.02 16 normal
particle minecraft:enchant ~ ~0.6 ~ 1.2 0.3 1.2 0.05 10 normal

# 计时 -1, 归零收掉
scoreboard players remove @s zx.vd_ft 1
execute if score @s zx.vd_ft matches ..0 run kill @s
