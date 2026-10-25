# ============================================================
# sweetdream:equipment/staff/bent_ray/ol_side —— 超限·折径: 一道「分光束」
# ------------------------------------------------------------
# 【谁调用它】ol_side_n(每层一次)   【执行者】施法者(玩家)
# 【上下文】zx.br_cur = 当前这段的主目标(分光束**从它这儿**拐出去)
#          zx.br_next = 主光束锁定的下一棒(分光束**不打**它)
# 【做什么】以当前目标为圆心, 找"除下一棒以外最近的一只", 对它造成一次
#   本体伤害(最大魔力 ×0.05 × 本段乘区) + 固定 18(固定值不进乘区, 与 chain 同一口径)。
# 【★ 为什么分光束要"独立计算" ★】文案写死了"多层折光额外射出的光束伤害独立计算"
#   ⇒ 每道各跑一次 calc, 不是"算一次 ×N"。这样魔力/乘区在这几道之间发生变化
#   (理论上)也能各自反映。
# 【★ 为什么用 zx.br_side 临时标签 ★】选择器要同时满足"离当前目标最近 / 不是下一棒 /
#   不是当前目标自己", 一层 tag 拼不出来 ⇒ 先圈出来再打(与全仓"选择器不能判分,
#   先打临时标签"同一套路)。用完即摘。
# ============================================================

# ① 圈出"除主光束锁定的下一棒之外、离当前目标最近的一只"
tag @e[tag=zx.br_side,distance=0..] remove zx.br_side
execute at @e[tag=zx.br_cur,distance=0..,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=0.01..8,tag=!zx.br_next,tag=!zx.br_cur,sort=nearest,limit=1] add zx.br_side
execute unless entity @e[tag=zx.br_side,distance=0..,limit=1] run return 0

# ② 本体伤害 = 最大魔力 ×0.05 × 本段乘区(乘区由 chain ③ 之前的 pick_mul 定好, 还在 brm.mul)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.05,independent_multiplier:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.independent_multiplier set from storage zx:work brm.mul
function manacore:api/damage/calc

# ③ 打出去(固定 18 走 fixed_add, 在乘区**之后**相加, 与 chain ④ 同口径)
data modify storage zx:in arg set value {target:"@e[tag=zx.br_side,distance=0..,limit=1]",damage:0.0,fixed_add:18.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @e[tag=zx.br_side,distance=0..,limit=1] run function sweetdream:api/damage

# ④ 表现 + 摘临时标签
execute at @e[tag=zx.br_side,distance=0..,limit=1] run particle minecraft:end_rod ~ ~1 ~ 0.2 0.2 0.2 0.06 10 normal
tag @e[tag=zx.br_side,distance=0..] remove zx.br_side
