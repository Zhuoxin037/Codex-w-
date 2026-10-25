# ============================================================
# sweetdream:equipment/staff/gu_poison/attack —— 蛊毒: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文(lore 逐字)】
#   ✦ 普攻
#   魔力 80   ·   伤害 自身当前魔力 ×0.04
#   每次普攻命中后都会使其获得「噬心」效果和 3 秒的缓慢Ⅱ。
# 【四要素】
#   触发 = 普通右键(非潜行); 目标范围 = 法球命中的生物; 次数 = 1 发; 时长 = 缓慢Ⅱ 3 秒
# 【伤害口径】当前魔力 ×0.04 -> other_mul 通道(基数 = 当前魔力)。
# 【「噬心」+ 缓慢Ⅱ 怎么接】法球命中回调 data.hit -> gu_poison/ball_hit。
# ============================================================

# ① 拿 uuid
# ★ 法杖普攻间隔: 0.5 秒(10 刻) —— 连点会被这里拦下(不扣魔力、不出球)。
#   ★ 必须排在**扣魔力之前**: 拦晚了就成了"扣了蓝但没出手"。
function sweetdream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 80(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:gp_attack",mana:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #gp_need zx.meta 0
execute store result score #gp_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#gp_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 80(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#gp_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 当前魔力 ×0.04
data modify storage manacore:in arg set value {uuid:"",other_mul:0.04}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去 + 命中回调(噬心 + 缓慢Ⅱ)
data modify storage zx:work ball set value {dmg:0.0,style:"gu_poison",hit:"sweetdream:equipment/staff/gu_poison/ball_hit"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
