# ============================================================
# fallendream:equipment/staff/surge_ebb/attack —— 潮涌，潮枯：普攻（普通右键，射一发法球）
# ------------------------------------------------------------
# 【谁调用它】cast 分流器（非潜行右键）
# 【文案】✦ 普攻   魔力 120 · 伤害 最大魔力值 ×0.03
# 【范式】同 wake_bell/attack：gate -> uuid -> 超限快照 -> skill/check -> mana/pay
#   -> 超限 mod -> damage/calc -> 装球(style + hit 回调) -> equipment/staff/attack
# 【命中回调】hit 指向本件的 hit（法球命中 → 术阵未满就召 4 秒，满则追随者 +1 秒）。
# ============================================================

# ① 普攻间隔 0.5 秒（拦在扣魔力之前）
function fallendream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区（本件暂无超限石，mod 会直接返回）
function fallendream:overlimit/api/snap

# ② 只读检查：魔力 120
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:surge_ebb_attack",mana:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function fallendream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #se_need zx.meta 0
execute store result score #se_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#se_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 120（超限后的值）
data modify storage manacore:in arg set value {uuid:"",value:120.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ④ 算伤害：最大魔力值 ×0.03
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:overlimit/api/mod
function manacore:api/damage/calc

# ⑤ 装球射出去 + 命中回调
data modify storage zx:work ball set value {dmg:0.0,style:"surge_ebb",hit:"fallendream:equipment/staff/surge_ebb/hit"}
data modify storage zx:work ball.dmg set from storage manacore:out r.damage
data modify storage zx:work ball.s2_b_dmg set value {n:0,d:1}
data modify storage zx:work ball.s2_b_dmg set from storage manacore:out r.s2_b_damage
function fallendream:equipment/staff/attack
