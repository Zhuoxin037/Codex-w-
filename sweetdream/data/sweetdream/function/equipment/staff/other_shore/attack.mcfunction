# ============================================================
# sweetdream:equipment/staff/other_shore/attack —— 彼岸: 普攻(普通右键)
# ------------------------------------------------------------
# 【技能原文】✦ 普攻   魔力 80 · 伤害 当前魔力值 ×0.02
# 【★ 伤害走 other 通道 ★】"当前魔力值 ×0.02" = other_mul:0.02 ——
#   other 通道的基数默认就是**当前剩余魔力**(见 manacore:api/damage/calc 的字段表),
#   不需要自己传 other_base。★ 与"最大魔力值 ×N"那类(mm 通道)不是一回事。
# 【★ 这一套是法杖普攻的固定范式 ★】(与 begonia / long_night / bent_ray 同构):
#   gate -> uuid -> 超限快照 -> skill/check -> mana/consume -> 超限 mod -> damage/calc
#   -> 装球(style + hit 回调) -> equipment/staff/attack。
# 【"命中后附加状态"怎么接】法球自带命中回调 data.hit -> ball/hit 第 ⑥ 步
#   回调 other_shore/ball_hit(见那个文件)。
# ============================================================

# ① 法杖普攻间隔: 0.5 秒(10 刻) —— 连点会被这里拦下(不扣魔力、不出球)
function sweetdream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区(与同批法杖一致; 本件暂无超限石, mod 会直接返回)
function sweetdream:overlimit/api/snap

# ② 只读检查: 魔力 80(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:os_attack",mana:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #os_need zx.meta 0
execute store result score #os_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#os_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 80(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#os_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害: 当前魔力值 ×0.02(other 通道, 基数 = 当前剩余魔力)
data modify storage manacore:in arg set value {uuid:"",other_mul:0.02}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去 + 命中回调(命中后做附加判断)
data modify storage zx:work ball set value {dmg:0.0,style:"other_shore",hit:"sweetdream:equipment/staff/other_shore/ball_hit"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
function sweetdream:equipment/staff/attack
