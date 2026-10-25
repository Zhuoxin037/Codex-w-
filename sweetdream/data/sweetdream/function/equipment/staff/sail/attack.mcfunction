# ============================================================
# sweetdream:equipment/staff/sail/attack —— 风帆: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文(lore 逐字)】
#   ✦ 普攻
#   魔力 80   ·   伤害 1
#   每次普攻后都会记录离自身最近的一个生物上所拥有的「渊海」、「流火」、
#   「白昼梦」、「噬心」。
# 【四要素】
#   触发 = 普通右键(非潜行); 目标范围 = 法球命中的生物; 次数 = 1 发; 时长 = —
# 【伤害】固定 1 点 -> custom_damage。
# 【"记录"不靠命中】文案是"每次普攻后", 与命中与否无关 -> 就在发射后记一次(见 record)。
#   注意口径: 是"每次普攻"(一次平A一次), 不是"每次命中" —— 右键本身就不重复触发。
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
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:sl_attack",mana:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #sl_need zx.meta 0
execute store result score #sl_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#sl_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 80(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#sl_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 固定 1 点伤害装进法球射出去
data modify storage zx:work ball set value {dmg:1.0,style:"sail"}
function sweetdream:equipment/staff/attack

# ⑤ 记录"离自身最近的一个生物"身上的四种标记
function sweetdream:equipment/staff/sail/record
