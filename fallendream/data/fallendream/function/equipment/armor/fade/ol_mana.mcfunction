# ============================================================
# fallendream:equipment/armor/fade/ol_mana —— 超限·息影: 恢复 5% 最大魔力值
# ------------------------------------------------------------
# 【执行者】玩家（go 已取好 lib/uuid）
# 【文案】"自身恢复 5% 魔力值"（超限原文是 5% 最大值，基础版是固定 50）
# 【算法】max_mana(api/stats/get, ×1000 定点) ×5 ÷100 → api/mana/add（value 是 double，÷1000 还原）
#   ★ ×5 前夹 INT32 上界（R05）：max_mana 定点值在极端加点下会回绕成负数。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #fd_m zx.meta 0
execute store result score #fd_m zx.meta run data get storage manacore:out r.value 1000
execute unless score #fd_m zx.meta matches 1.. run return 0

scoreboard players set #fd_5 zx.meta 5
scoreboard players set #fd_100 zx.meta 100
scoreboard players set #fd_cap zx.meta 2147483647
scoreboard players operation #fd_cap zx.meta /= #fd_5 zx.meta
scoreboard players operation #fd_add zx.meta = #fd_m zx.meta
execute if score #fd_add zx.meta > #fd_cap zx.meta run scoreboard players operation #fd_add zx.meta = #fd_cap zx.meta
scoreboard players operation #fd_add zx.meta *= #fd_5 zx.meta
scoreboard players operation #fd_add zx.meta /= #fd_100 zx.meta

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #fd_add zx.meta
function manacore:api/mana/add
