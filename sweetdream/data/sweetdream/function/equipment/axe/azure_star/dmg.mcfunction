# ============================================================
# sweetdream:equipment/axe/azure_star/dmg —— 苍蓝星 · 主动第 1 段结算
# ------------------------------------------------------------
# 【谁调用它】azure_star/cast(⑦)
# 【执行者/位置】施法者
# 【技能原文】"对离自身最近的一个生物造成 最大魔力值 ×0.5 的伤害，之后对其 2 格内的
#   生物造成 最大魔力值 ×0.1 的伤害。"
# 【★ 2026-10-07 用户改口径: 两段之间隔 0.35 秒, 不再同刻打完 ★】
#   同刻两段会被生物的受伤无敌帧吃掉一段(0.1 那一段基本白打)。所以:
#     本文件 = **只打第 1 段**, 打完给玩家排 zx.as_d = 7(7 刻 = 0.35 秒);
#     core/tick 到点驱动 tick_step -> dmg2 打第 2 段(以"那一只"为圆心)。
#   ★ 锚点用标签 zx.as_t 钉在**那一只生物身上**(不是 marker): 段② 要"对其 2 格内",
#     "其"就是这只生物 —— 它活着就还在原处 / 被击退后的新位置。它要是被第 1 段打死了,
#     标签随之消失, 段② 就什么都不做(目标没了, 这是合理的)。
# 【"最近的 1 只"取 8 格内】文案没给距离, 按全包"最近的一个生物"惯例取 8 格
#   (苦痛 agony/cast、惑梦 delusion/skill 同款)。cast ③ 已经预检过 8 格内有没有生物。
# 【归属】with_from 用施法者 UUID 四整数拼 by —— 第 2 段挂在别处执行也算施法者的。
# 【数值改哪】倍率 0.5 = recalc; 0.1 = recalc2; 2 格 = dmg2 的选择器;
#   间隔 = 本文件 ④ 的 `set @s zx.as_d 7` 与 core/tick 的 `zx.as_d=1..`(7 刻 = 0.35 秒)。
# ============================================================

# ⓪ 圈出"离自身最近的 1 个生物"
#   ★ 这里清的是同名全局标签; cast 开头已经清过一次, 这里兜底再清一次
tag @e[tag=zx.as_t,distance=0..] remove zx.as_t
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..8,sort=nearest,limit=1] add zx.as_t
execute unless entity @e[tag=zx.as_t,distance=0..,limit=1] run return 0

# ① 算第 1 段的伤害(顺便消费"被动翻倍"并留下存根 zx.as_db)
function sweetdream:equipment/axe/azure_star/recalc

# ② 打第 1 段: 对那一只造成 最大魔力值 ×0.5
data modify storage zx:work a.num set from storage zx:work asz.dmg1
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[tag=zx.as_t,distance=0..]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 表现(第 1 段)
execute at @e[tag=zx.as_t,distance=0..,limit=1] run particle minecraft:dust{color:[0.2,0.5,1.0],scale:1.2} ~ ~1 ~ 0.6 0.6 0.6 0.05 24 normal
execute at @e[tag=zx.as_t,distance=0..,limit=1] run particle minecraft:end_rod ~ ~1 ~ 0.4 0.4 0.4 0.1 16 normal

# ④ 排第 2 段: 0.35 秒(7 刻)后以"那一只"为圆心打 2 格 —— 由 core/tick 驱动 tick_step
scoreboard players set @s zx.as_d 7
