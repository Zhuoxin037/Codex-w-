# ============================================================
# fallendream:equipment/armor/bearing/ol_end —— 超限·承: 术阵结束时恢复 1% 魔力值
# ------------------------------------------------------------
# 【谁调用它】bearing/second ⑤.5（条件已判: 超限 + 本秒术阵刚归零）
# 【执行者】玩家（@s）
# 【文案(lore 逐字)】…术阵结束时自身恢复 1% 魔力值…
# 【口径】1% 按**面板最大魔力**算（读 manacore stats.max_mana ×1000 再 ÷100 = 1%），
#   不是按"当前缺多少"算。只做除法, 不会溢出, 不需要 R05 上界。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get

scoreboard players set #brx_mm zx.meta 0
execute store result score #brx_mm zx.meta run data get storage manacore:out r.value 1000
scoreboard players set #brx_p zx.meta 0
scoreboard players operation #brx_p zx.meta = #brx_mm zx.meta
scoreboard players operation #brx_p zx.meta /= #100 zx.meta
execute if score #brx_p zx.meta matches ..0 run return 0

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #brx_p zx.meta
function manacore:api/mana/add

tellraw @s [{"text":"术阵结束","color":"aqua"},{"text":"  恢复 1% 魔力值","color":"gray"}]
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.5 0.4 0.5 0.03 12 normal
