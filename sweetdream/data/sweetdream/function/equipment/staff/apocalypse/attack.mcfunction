# ============================================================
# sweetdream:equipment/staff/apocalypse/attack —— 启示录: 普攻(普通右键)
# ------------------------------------------------------------
# 【文案】消耗 60 魔力; 伤害 = 自身最大魔力值 ×0.03。
# 【口径】最大魔力值 → max_mana_mul 通道(基数 = 面板最大魔力, 框架自动取)。
# 【伤害在发射那一瞬间算好、塞进法球带着飞】(和风行普攻同一套)。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 60(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:ap_attack",mana:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #ap_need zx.meta 0
execute store result score #ap_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#ap_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 60(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#ap_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 最大魔力 ×0.03(超限的伤害乘区在 calc 前由 mod 乘进通道)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球
data modify storage zx:work ball set value {dmg:0.0,style:"plain"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
