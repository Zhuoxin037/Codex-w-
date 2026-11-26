# ============================================================
# fallendream:equipment/staff/intone/attack —— 引声：普攻（普通右键，射一发法球）
# ------------------------------------------------------------
# 【谁调用它】cast 分流器（非潜行右键）
# 【文案】✦ 普攻   魔力 20 · 伤害 最大魔力值 ×0.01
# 【★ 范式来源 ★】与 wake_bell / begonia / long_night **完全同构**：
#   gate -> uuid -> 超限快照 -> skill/check -> mana/pay -> 超限 mod -> damage/calc
#   -> 装球(style + hit 回调) -> equipment/staff/attack
# 【命中回调】无（引声文案只有主动，没有普攻附带效果）⇒ hit 留空。
# 【魔力 20 ≠ 冷却】普攻只扣蓝、不进冷却；0.5 秒的连点间隔由 staff/gate 统一管。
# ============================================================

# ① 普攻间隔 0.5 秒（拦在扣魔力之前，免得"扣了蓝没出球"）
function fallendream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区（本件暂无超限石，mod 会直接返回）
function fallendream:overlimit/api/snap

# ② 只读检查：魔力 20
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:intone_attack",mana:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function fallendream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #in_need zx.meta 0
execute store result score #in_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#in_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 20（超限后的值）
data modify storage manacore:in arg set value {uuid:"",value:20.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害：最大魔力值 ×0.01
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.01}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去
data modify storage zx:work ball set value {dmg:0.0,style:"intone"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
data modify storage zx:work ball.s2_b_dmg set value {n:0,d:1}
data modify storage zx:work ball.s2_b_dmg set from storage manacore:out r.s2_b_damage
function fallendream:equipment/staff/attack
