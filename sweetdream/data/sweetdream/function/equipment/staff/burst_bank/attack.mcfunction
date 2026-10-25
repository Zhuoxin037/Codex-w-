# ============================================================
# sweetdream:equipment/staff/burst_bank/attack —— 决堤: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文(必须和这里对上)】✦ 普攻   魔力 80 · 伤害 自身当前魔力值 ×0.03
# ★ 2026-10-21 定价口径（用户定：按整体主动技能消耗对齐）★
#   本件主动 = 当前魔力 50%（上限 1070 时约 535），同档先例（主动 400~550）
#   的普攻是 60~80（late_court 60 / apocalypse 60 / wind 80 / other_shore 80）
#   ⇒ 取 80，占主动约 15%，与全包 22 件的中位比例（12~16%）一致。
# 【★ 伤害走 other 通道 ★】"当前魔力值 ×N" = other_mul —— other 通道的基数
#   默认就是**当前剩余魔力**(见 manacore:api/damage/calc 字段表), 不用传 other_base。
#   与"最大魔力值 ×N"(mm 通道)不是一回事。
# 【★ 法杖普攻的固定范式 ★】(与 other_shore / late_court / apocalypse 同构):
#   gate -> uuid -> 超限快照 -> skill/check -> mana/consume -> 超限 mod
#   -> damage/calc -> 装球 -> equipment/staff/attack
# 【本件无命中回调】普攻命中后不做附加判断, 所以装球不写 hit。
# ============================================================

# ① 法杖普攻间隔: 0.5 秒(10 刻) —— 连点会被这里拦下(不扣魔力、不出球)
#   ★ 必须排在**扣魔力之前**: 拦晚了就成了"扣了蓝但没出手"。
function sweetdream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 60(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:bb_attack",mana:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #bb_need zx.meta 0
execute store result score #bb_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#bb_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 60(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#bb_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 当前魔力值 ×0.03(other 通道, 基数 = 当前剩余魔力)
data modify storage manacore:in arg set value {uuid:"",other_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去
data modify storage zx:work ball set value {dmg:0.0,style:"burst_bank"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
