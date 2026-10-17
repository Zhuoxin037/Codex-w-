# ============================================================
# sweetdream:equipment/staff/bent_ray/chain —— 折径主动的一段(递归)
# ------------------------------------------------------------
# 【执行者】施法者(玩家)   【入参】#br_n = 当前段号(0 = 首段), zx.br_cur = 当前目标
# 【每一段做五件事】
#   ① 取本段独立乘区 1.2^n
#   ② 本体伤害 = 最大魔力值 ×0.04 × 乘区
#   ③ 加上固定 8 —— **不进乘区**(原文"不包含固定伤害")
#   ④ 打当前目标
#   ⑤ 段号到 6 就收; 否则找下一只(当前目标 5 格内最近的、带「折光」且未过期的、
#      链上没用过的) -> 消耗它的「折光」-> 换目标 -> 段号 +1 -> 递归
# 【★ 固定 8 怎么做到"不进乘区" ★】damage/calc 的公式是 (各项 + 固定 + …) × 乘区,
#   固定项天生在乘区**里**。所以分两次算:
#     第一次: max_mana_mul:0.04, independent_multiplier:1.2^n  -> d1(已含乘区)
#     第二次: other_base:d1, other_mul:1.0, custom_damage:8.0  -> d1 + 8(乘区 1.0)
#   第二次把"上一次的结果"当成 other_base 传进去, 是包内唯一能做 double 加法的路子。
# 【★ 为什么递归 ★】7 段结构完全一样; 展开写会撞 check.py 的「同文件相邻完全重复」。
#   递归深度最多 7, 远低于函数调用上限(同 anchor/ray 的射线递归)。
# 【★ 用过的怎么排除 ★】链上每一只都打 zx.br_used; 选下一只时用 tag=!zx.br_used。
#   这样 A->B->A 的来回不会发生(否则会在两只之间来回跳 6 次)。
# ============================================================

# ① 当前目标必须还在
execute unless entity @e[tag=zx.br_cur,distance=0..,limit=1] run return 0

# ② 本段乘区
function sweetdream:equipment/staff/bent_ray/pick_mul

# ③ 本体伤害 = 最大魔力值 ×0.04 × 乘区
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.04,independent_multiplier:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.independent_multiplier set from storage zx:work brm.mul
function manacore:api/damage/calc
data modify storage zx:work br.d1 set from storage manacore:out r.damage

# ④ 再加固定 8(乘区 1.0 -> 8 不被乘)
data modify storage manacore:in arg set value {uuid:"",other_base:0.0,other_mul:1.0,custom_damage:8.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.other_base set from storage zx:work br.d1
function manacore:api/damage/calc
data modify storage zx:work br.dmg set from storage manacore:out r.damage

# ⑤ 打当前目标(执行者仍是玩家 -> 击杀归属正确)
data modify storage zx:in arg set value {target:"@e[tag=zx.br_cur,distance=0..,limit=1]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work br.dmg
execute at @e[tag=zx.br_cur,distance=0..,limit=1] run function sweetdream:api/damage

# ⑥ 表现: 打到的这一下
execute at @e[tag=zx.br_cur,distance=0..,limit=1] run particle minecraft:end_rod ~ ~1 ~ 0.2 0.2 0.2 0.08 16 normal
execute at @e[tag=zx.br_cur,distance=0..,limit=1] run particle minecraft:enchanted_hit ~ ~1 ~ 0.3 0.3 0.3 0.12 12 normal

# ⑦ 首段 + 6 次连锁 = 段号 0..6; 到 6 就收
execute if score #br_n zx.meta matches 6.. run return 0

# ⑧ 找下一只: 当前目标 5 格内最近的、带折光、链上没用过
tag @e[tag=zx.br_next,distance=0..] remove zx.br_next
execute at @e[tag=zx.br_cur,distance=0..,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=0.01..5,tag=zx.br_g,tag=!zx.br_used,sort=nearest,limit=1] add zx.br_next
#   ★ 折光过期(到期刻 <= #now)的不算: 标签可能还留着, 但已经失效
execute as @e[tag=zx.br_next,distance=0..] unless score @s zx.br_gl > #now manacore.meta run tag @s remove zx.br_next
execute unless entity @e[tag=zx.br_next,distance=0..,limit=1] run return 0

# ⑨ 消除它的「折光」(原文"并消除其「折光」")
execute as @e[tag=zx.br_next,distance=0..,limit=1] at @s run function sweetdream:equipment/staff/bent_ray/take_zg

# ⑩ 换目标、记"已用过"、段号 +1、递归
tag @e[tag=zx.br_cur,distance=0..] remove zx.br_cur
tag @e[tag=zx.br_next,distance=0..] add zx.br_cur
tag @e[tag=zx.br_next,distance=0..] add zx.br_used
tag @e[tag=zx.br_next,distance=0..] remove zx.br_next
scoreboard players add #br_n zx.meta 1
function sweetdream:equipment/staff/bent_ray/chain
