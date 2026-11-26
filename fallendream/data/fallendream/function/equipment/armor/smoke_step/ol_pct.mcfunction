# ============================================================
# fallendream:equipment/armor/smoke_step/ol_pct —— 超限·烟履: 额外恢复 1% 上限魔力
# ------------------------------------------------------------
# 【谁调用它】smoke_step/hit/victim_body ⑦（条件已判: 穿着超限烟履）
# 【执行者】玩家（@s）
# 【文案(lore 逐字)】…为自身恢复 15 点魔力值及 1% 魔力值…
# 【口径】1% 按**面板最大魔力**算（api/stats/get 的 max_mana ×1000 再 ÷100）。
#   只做除法, 不涉及乘法溢出, 不需要 R05 上界保护。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #ss_mm zx.meta 0
execute store result score #ss_mm zx.meta run data get storage manacore:out r.value 1000
scoreboard players set #ss_p1 zx.meta 0
scoreboard players operation #ss_p1 zx.meta = #ss_mm zx.meta
scoreboard players operation #ss_p1 zx.meta /= #100 zx.meta
execute if score #ss_p1 zx.meta matches ..0 run return 0
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #ss_p1 zx.meta
function manacore:api/mana/add
