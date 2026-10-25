# ============================================================
# sweetdream:equipment/staff/stop_needle/attack —— 停针: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文(必须和这里对上)】✦ 普攻   魔力 60 · 伤害 自身最大魔力值 ×0.02
# 【伤害口径】最大魔力值 ×0.02 -> max_mana_mul 通道(基数 = 面板最大魔力)。
# 【★ 法杖普攻的固定范式 ★】(与 late_court / other_shore / apocalypse 同构):
#   gate -> uuid -> 超限快照 -> skill/check -> mana/consume -> 超限 mod
#   -> damage/calc -> 装球 -> equipment/staff/attack
# 【本件普攻无命中回调】时停只由主动技能施加, 普攻不挂。
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
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sn_attack",mana:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #sn_need zx.meta 0
execute store result score #sn_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#sn_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 60(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#sn_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 最大魔力值 ×0.02
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.02}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去
data modify storage zx:work ball set value {dmg:0.0,style:"stop_needle"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
