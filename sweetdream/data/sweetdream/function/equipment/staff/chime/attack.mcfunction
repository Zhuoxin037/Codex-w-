# ============================================================
# sweetdream:equipment/staff/chime/attack —— 共鸣: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文(lore 逐字)】
#   ✦ 普攻
#   魔力 12   ·   伤害 7
# 【四要素】
#   触发 = 普通右键(非潜行); 目标范围 = 法球命中的生物; 次数 = 1 发; 时长 = —
# 【伤害】固定 7 点(不走三条倍率通道) -> custom_damage。
#   发射那一刻算好塞进法球, 命中之前换装/吃药都不改这一颗球。
# 【普攻形态】法杖类默认 = 向前射出一颗法球(sweetdream:equipment/staff/attack)。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区(这一发用的就是此刻手里这把武器的超限状态)
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 12(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:chime_attack",mana:12.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #ch_need zx.meta 0
execute store result score #ch_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#ch_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 12(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:12.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#ch_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 固定 7 点
data modify storage manacore:in arg set value {uuid:"",custom_damage:7.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ⑤ 装球射出去
data modify storage zx:work ball set value {dmg:0.0,style:"chime"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
