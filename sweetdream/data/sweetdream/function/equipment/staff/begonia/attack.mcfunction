# ============================================================
# sweetdream:equipment/staff/begonia/attack —— 海棠: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文(lore 逐字)】
#   ✦ 普攻
#   魔力 30   ·   伤害 自身当前魔力 ×0.02
#   每次普攻命中后都会使其轻微吸引一次其 1 格内的至多 3 个生物。
# 【四要素】
#   触发 = 普通右键(非潜行); 目标范围 = 法球命中的生物; 次数 = 1 发; 时长 = —
# 【伤害口径】当前魔力 ×0.02 -> other_mul 通道(基数 = 当前魔力, 框架自动取)。
# 【"轻微吸引"怎么接】法球自带命中回调 data.hit; 命中那一刻由 ball/hit 第 ⑥ 步
#   回调 begonia/ball_hit(见那个文件)。
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

# ② 只读检查: 魔力 30(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:bg_attack",mana:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #bg_need zx.meta 0
execute store result score #bg_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#bg_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 30(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:30.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#bg_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 当前魔力 ×0.02
data modify storage manacore:in arg set value {uuid:"",other_mul:0.02}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去 + 命中回调(轻微吸引)
data modify storage zx:work ball set value {dmg:0.0,style:"begonia",hit:"sweetdream:equipment/staff/begonia/ball_hit"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
