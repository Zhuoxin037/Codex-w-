# ============================================================
# sweetdream:equipment/staff/twilight/attack —— 暮光: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文(lore 逐字)】
#   ✦ 普攻
#   魔力 50   ·   伤害 自身最大魔力值 ×0.03
#   每次普攻命中后有 20% 的概率使其附加「噬心」效果。若成功附加则额外对其造成一次伤害。
# 【四要素】
#   触发 = 普通右键(非潜行); 目标范围 = 法球命中的生物; 次数 = 1 发(+ 触发时补 1 发); 时长 = —
# 【伤害口径】最大魔力 ×0.03 -> max_mana_mul 通道。
# 【20% + 补一次伤害】法球命中回调 data.hit -> twilight/ball_hit。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 50(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:tw_attack",mana:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #tw_need zx.meta 0
execute store result score #tw_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#tw_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 50(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#tw_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 最大魔力 ×0.03
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去 + 命中回调(20% 附噬心 + 补一发)
data modify storage zx:work ball set value {dmg:0.0,style:"plain",hit:"sweetdream:equipment/staff/twilight/ball_hit"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
