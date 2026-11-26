# ============================================================
# fallendream:equipment/armor/mottle_vein/b_liuhuo —— 杂纹: 本轮消费过「流火」
# ------------------------------------------------------------
# 【谁调用它】reward ③ / ol_dup（叠加第二次时的"重复触发"）
# 【执行者】玩家
# 【技能原文(基础)】"若消耗了「流火」则额外恢复 30 点魔力值。"
# 【技能原文(超限)】"若消耗了「流火」则额外恢复 30点魔力值并恢复 1% 魔力值。"
# 【★ 与基础那 20/80 点是两笔 ★】文案是"额外" ⇒ 基础版一共 50(20+30)、
#   超限版一共 110(80+30) 再另外加 1% —— 不是"改成 30"。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:30.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# ★ 超限: 再恢复 1% 魔力值（按面板最大魔力算, 只做除法不溢出）
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"],ol:"mottle_vein"}] run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #mv_mm zx.meta 0
execute store result score #mv_mm zx.meta run data get storage manacore:out r.value 1000
scoreboard players set #mv_p1 zx.meta 0
scoreboard players operation #mv_p1 zx.meta = #mv_mm zx.meta
scoreboard players operation #mv_p1 zx.meta /= #100 zx.meta
execute if score #mv_p1 zx.meta matches ..0 run return 0
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #mv_p1 zx.meta
function manacore:api/mana/add
