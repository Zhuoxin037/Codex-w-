# ============================================================
# fallendream:equipment/armor/rebirth_veil/mm_add —— 超限·复纱：最大魔力 +20%(12 秒)
# ------------------------------------------------------------
# 【执行者】玩家
# 【账本】zx.rbv_mm = 已经加在上限上的量(×1000 定点); zx.rbv_mm_end = 到期刻
#   ★ 必须记"加了多少"而不是"加了多少百分比": 到期退还时上限的基数已经变了
#     (期间可能换过其它装备), 按百分比回算会多退或少退。
# 【★ ×20 ÷100 两步都夹 INT32 上界 ★】max_mana 的定点值本来就大(几百点 = 几十万),
#   直接 ×20 在极端加点下会溢出成负数 —— 负的"加成"会把上限砍掉。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #rbv_m zx.meta 0
execute store result score #rbv_m zx.meta run data get storage manacore:out r.value 1000
execute unless score #rbv_m zx.meta matches 1.. run return 0

scoreboard players set #rbv_20 zx.meta 20
scoreboard players set #rbv_100 zx.meta 100
scoreboard players set #rbv_cap zx.meta 2147483647
scoreboard players operation #rbv_cap zx.meta /= #rbv_20 zx.meta
scoreboard players operation #rbv_add zx.meta = #rbv_m zx.meta
execute if score #rbv_add zx.meta > #rbv_cap zx.meta run scoreboard players operation #rbv_add zx.meta = #rbv_cap zx.meta
scoreboard players operation #rbv_add zx.meta *= #rbv_20 zx.meta
scoreboard players operation #rbv_add zx.meta /= #rbv_100 zx.meta

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #rbv_add zx.meta
function manacore:api/stats/add

scoreboard players operation @s zx.rbv_mm = #rbv_add zx.meta
scoreboard players operation @s zx.rbv_mm_end = #now manacore.meta
scoreboard players add @s zx.rbv_mm_end 240
