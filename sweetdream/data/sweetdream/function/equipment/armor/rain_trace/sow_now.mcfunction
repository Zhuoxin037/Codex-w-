# ============================================================
# sweetdream:equipment/armor/rain_trace/sow_now —— 在**执行位置**立刻撒一个水迹点
# ------------------------------------------------------------
# 【谁调用它】① sow ⑤（主点，执行位置 = 玩家脚下）
#             ② sow ⑥（补点，执行位置 = 被 positioned 摆到两点连线上）
#             ③ step_moved（施法起点那一摊，执行位置 = 锚点 marker）
# 【执行者】玩家   【执行位置】= 水迹点要出现的位置（**不一定是玩家所在**）★
# 【和 sow 的分工】sow 管"什么时候撒、撒在哪几个位置"；本函数只管"就地撒一个"，
#   顺手算出伤害值（施法者基础攻击力 ×2）与所有者 UUID。
#
# 【★ 为什么这里绝不能写 `at @s` ★】
#   2026-10-18 修。上一版 dot_spawn 是 `execute at @s run summon ...` —— 当时
#   所有点都撒在玩家脚下，看不出问题。但现在补点要靠 `positioned ^ ^ ^1.3` 把
#   执行位置摆到连线上，一旦再套 `at @s`，点立刻飞回玩家身上 ⇒ 补点全堆在一处，
#   路径中间照样是空的（正是用户报的"没铺满"）。
#   所以生成一律用 `~ ~ ~`（当前执行位置）；执行者是谁不影响坐标。
#
# 【伤害为什么每个点各算一次】文案是"相当于释放者基础攻击力 ×2"，按"踩到它的
#   那一刻"的释放者属性结算更符合直觉；每个点都是独立的一摊水。
#   `attribute ... get 100` 取的是 ×100 的整数，落 storage 时再 ×0.01 变 double。
# ============================================================

# ① 门控：踏灰玩家也会走到这里（step_moved 是两双鞋共用的），没穿雨迹就不撒
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["rain_trace"]}] run return 0

# ② 伤害 = 释放者基础攻击力 ×2（×100 整数运算）
execute store result score #rt_dmg zx.meta run attribute @s minecraft:attack_damage get 100
scoreboard players set #rt_x2 zx.meta 2
scoreboard players operation #rt_dmg zx.meta *= #rt_x2 zx.meta

# ③ 宏参数：伤害 + 所有者 UUID（四个整数）
data modify storage zx:rain dot set value {dmg:0.0d,u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:rain dot.dmg double 0.01 run scoreboard players get #rt_dmg zx.meta
data modify storage zx:rain dot.u0 set from entity @s UUID[0]
data modify storage zx:rain dot.u1 set from entity @s UUID[1]
data modify storage zx:rain dot.u2 set from entity @s UUID[2]
data modify storage zx:rain dot.u3 set from entity @s UUID[3]

# ④ 在当前执行位置生成
function sweetdream:equipment/armor/rain_trace/dot_spawn with storage zx:rain dot
