# ============================================================
# sweetdream:equipment/axe/charge/ol_bolt_bonus —— 第二形态: 每次召唤闪电的落点追加伤害
# ------------------------------------------------------------
# 【原文】"…且自身每次召唤闪电时都会对落点处的生物造成相当于自身基础攻击力 ×3 的伤害。"
# 【谁调用它】lib/on_lightning(每一道"自己召唤的雷"落地时)
# 【执行者】召唤那道雷的玩家   【位置】**落点**
# 【范围】落点 2 格内全部生物(想改半径就改下面那一行)
# ★★ 【位置 = 调用方给的落点, 本文件里不许再 `at @s`】★ 2026-10-13 修: 原来 ②
#   写成 `execute at @s run tag @e[…distance=..2]` ⇒ 范围变成"玩家周围 2 格"。
#   与 equipment/axe/anion/ol_bonus 同一条位置契约。
# 【归属】以玩家身份发起 + u0..u3 走 with_from -> 击杀算在玩家头上
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ② 圈落点 2 格内的生物(位置就是落点, **不加 at @s**)
tag @e[tag=zx.chg_ex,distance=0..] remove zx.chg_ex
tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.chg_ex
execute unless entity @e[tag=zx.chg_ex,distance=0..] run return 0

# ③ 伤害 = 自身基础攻击力 ×3
data modify storage manacore:in arg set value {uuid:"",attack_mul:3.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.chg_ex,distance=0..]",damage:0.0,read:"manacore"}
function sweetdream:api/damage

# ④ 表现 + 清标记(在**落点**, 不加 at @s)
particle minecraft:electric_spark ~ ~1 ~ 1.0 0.6 1.0 0.06 20 normal
tag @e[tag=zx.chg_ex,distance=0..] remove zx.chg_ex
