# ============================================================
# fallendream:equipment/staff/lucid_illusion/attack —— 清醒与幻觉：普攻（普通右键）
# ------------------------------------------------------------
# 【谁调用它】cast 分流器（非潜行右键）
# 【文案】✦ 普攻   魔力 200 · 伤害 1
# 【★ "伤害 1"是固定点数，不是倍率 ★】所以不调 damage/calc，直接把 1.0 塞进 ball.dmg。
#   damage/calc 那条路是给"最大魔力值 ×N"这种倍率用的，固定伤害硬套会引入乘区。
# 【范式】同 wake_bell/attack：gate -> uuid -> 超限快照 -> skill/check -> mana/pay
#   -> 装球(style + hit 回调) -> equipment/staff/attack
# 【命中回调】hit 指向本件的 hit（法球命中 → 生成一个法球，到上限转 10 秒额外球）。
# ============================================================

# ① 普攻间隔 0.5 秒（拦在扣魔力之前）
function fallendream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区（本件暂无超限石，mod 会直接返回）
function fallendream:overlimit/api/snap

# ② 只读检查：魔力 200
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:lucid_illusion_attack",mana:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function fallendream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #li_need zx.meta 0
execute store result score #li_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#li_need","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 200（超限后的值）
data modify storage manacore:in arg set value {uuid:"",value:200.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ④ 装球射出去（固定 1 点伤害）
data modify storage zx:work ball set value {dmg:1.0,style:"lucid_illusion",hit:"fallendream:equipment/staff/lucid_illusion/hit"}
data modify storage zx:work ball.s2_b_dmg set value {n:0,d:1}
function fallendream:equipment/staff/attack
