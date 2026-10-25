# ============================================================
# sweetdream:equipment/staff/bent_ray/ol_end —— 超限·折径: 光束结束后的收尾一击
# ------------------------------------------------------------
# 【谁调用它】skill ⑦.5(`if score @s zx.br_ol matches 1`, 此时 zx.br_used 还在)
# 【执行者】施法者(玩家)
# 【文案】"结束后对锁定的生物和在光束路径上的生物造成一次相当于自身最大魔力值
#   ×0.08 的伤害, 且本次伤害受到**本技能的最终增伤**。"
# 【★ "光束路径上的生物" = zx.br_used ★】链上每一段的目标都会被记进 zx.br_used
#   (首段 + 后续每一段), 正好就是"光束走过的那一串" —— 不用另建集合。
# 【★ "最终增伤" = 链跑完时的 1.2^n ★】#br_n 在 chain 里逐段 +1, 链结束后它停在
#   最后一段的段号 ⇒ pick_mul 直接读它, 拿到的就是"最后那一段用过的乘区"。
#   ★ 不要再 +1: 收尾这一击不是"新的一段", 它是**贴着最后一段**的追加。
# 【★ 只有 ×0.08, 不带固定值 ★】文案写的是"相当于最大魔力值 ×0.08 的伤害",
#   没提固定值(固定 18 只属于"每段本体"), 所以这里不 fixed_add。
# ============================================================

# ① 取最终乘区(读 #br_n —— chain 已把它停在最后一段)
function sweetdream:equipment/staff/bent_ray/pick_mul

# ② 伤害 = 最大魔力 ×0.08 × 最终乘区
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08,independent_multiplier:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.independent_multiplier set from storage zx:work brm.mul
function manacore:api/damage/calc

# ③ 打给"锁定的 + 路径上的"全体(zx.br_used 必然与施法者同维度)
data modify storage zx:in arg set value {target:"@e[tag=zx.br_used,distance=0..]",damage:0.0,type:"minecraft:player_attack"}
execute if data storage zx:config damage_type run data modify storage zx:in arg.type set from storage zx:config damage_type
data modify storage zx:in arg.damage set from storage manacore:out r.damage
data modify storage zx:in arg.num set from storage manacore:out r.damage
function sweetdream:lib/num/plain
function sweetdream:api/damage

# ④ 表现: 整条光路一起亮一下
execute as @e[tag=zx.br_used,distance=0..] at @s run particle minecraft:end_rod ~ ~1 ~ 0.25 0.4 0.25 0.06 14 normal
playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.6 1.8
