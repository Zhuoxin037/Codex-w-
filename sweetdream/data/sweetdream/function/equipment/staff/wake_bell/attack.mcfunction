# ============================================================
# sweetdream:equipment/staff/wake_bell/attack —— 醒梦钟: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文】
#   ✦ 普攻   魔力 60 · 伤害 最大魔力值 ×0.02
#   "每次普攻命中后若其附有「白昼梦」，则额外造成一次相当于自身最大魔力值 ×0.02 的伤害。"
# 【四要素】触发 = 普通右键(非潜行); 目标 = 法球命中的生物; 次数 1 发; 时长 —
# 【伤害口径】最大魔力值 ×0.02 -> max_mana_mul 通道。
# 【"命中带白昼梦就追一发"怎么接】法球自带命中回调 data.hit;
#   命中那一刻由 ball/hit 第 ⑥ 步回调 wake_bell/ball_hit(见那个文件)。
# 【★ 这一套是法杖普攻的固定范式 ★】(与 begonia / long_night 完全同构):
#   gate -> uuid -> 超限快照 -> skill/check -> mana/consume -> 超限 mod -> damage/calc
#   -> 装球(style + hit 回调) -> equipment/staff/attack。
# ============================================================

# ① 法杖普攻间隔: 0.5 秒(10 刻) —— 连点会被这里拦下(不扣魔力、不出球)
#   ★ 必须排在**扣魔力之前**: 拦晚了就成了"扣了蓝但没出手"。
function sweetdream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区(与同批法杖一致; 本件暂无超限石, mod 会直接返回)
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 60(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:wb_attack",mana:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #wb_need zx.meta 0
execute store result score #wb_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#wb_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 60(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#wb_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 最大魔力值 ×0.02
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.02}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去 + 命中回调(命中带「白昼梦」者 -> 追加一发)
data modify storage zx:work ball set value {dmg:0.0,style:"wake_bell",hit:"sweetdream:equipment/staff/wake_bell/ball_hit"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
