# ============================================================
# sweetdream:equipment/armor/stellar_elegy/regen_pct —— 超限版: 每秒回 2% 魔力值
# ------------------------------------------------------------
# 【执行者】玩家(zx:data self.uuid 已由调用方 regen 备好)
# 【口径】"每秒恢复 2% 魔力值" —— 按**魔力值上限**算(和本包"X% 魔力值"的既有口径
#   一致, 见 dusk_dawn 的低魔力回蓝那条), 不按当前值(否则越缺蓝回得越少, 反直觉)。
# 【怎么算】mana/get 一次拿回 value(当前) 与 max(上限), 取 max ×2 /100。
#   整数除法会向下取整 —— 上限 350 时 = 7 点/秒, 5 秒共 35 点(原版是 50)。
#   这是刻意的: 文案给的是百分比, 不是"补足差额"。
# ============================================================

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get

scoreboard players set #se_mx zx.meta 0
execute store result score #se_mx zx.meta run data get storage manacore:out r.max
scoreboard players operation #se_mx zx.meta *= #2 zx.meta
scoreboard players operation #se_mx zx.meta /= #100 zx.meta
execute unless score #se_mx zx.meta matches 1.. run return 0

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #se_mx zx.meta
function manacore:api/mana/add

# 记进"装备额外回魔"账本(见 core/load 的注释)
scoreboard players operation @s zx.regen_extra += #se_mx zx.meta
