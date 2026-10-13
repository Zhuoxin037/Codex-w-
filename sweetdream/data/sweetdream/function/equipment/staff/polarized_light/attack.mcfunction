# ============================================================
# sweetdream:equipment/staff/polarized_light/attack —— 偏振光: 普攻(普通右键)
# ------------------------------------------------------------
# 【文案】消耗 10 魔力; 伤害 6。
# 【伤害是固定值】不走 damage/calc(没有倍率通道可乘) —— 直接把 6.0
#   装进法球。超限只影响消耗(10 → 12), 不影响这 6 点(描述没有倍率口径)。
# 【形状交给类别默认件】法杖普攻 = 射法球(equipment/staff/attack)。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区(照风行普攻的全套流程)
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 10(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:pl_attack",mana:10.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #pl_need zx.meta 0
execute store result score #pl_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#pl_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 10(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:10.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#pl_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 固定 6 点伤害装进法球, 交给法杖类默认普攻射出去
data modify storage zx:work ball set value {dmg:6.0,style:"polarized_light"}
function sweetdream:equipment/staff/attack
