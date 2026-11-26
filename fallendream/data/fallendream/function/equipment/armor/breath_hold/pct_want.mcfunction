# ============================================================
# fallendream:equipment/armor/breath_hold/pct_want —— 超限: 算出"该加多少上限"
# ------------------------------------------------------------
# 【执行者】玩家   【入参】#bh_free = 空闲术阵位数(≥1)
# 【出参】#bh_want = 目标加成(×1000 定点, 单位 = 魔力值)
# 【公式】want = (当前 max_mana ×1000 − 账本) × (2 × 空闲位) ÷ 100
#   基准要减掉账本自己已经加上的那部分 —— 否则第二秒开始就会 2% 套 2% 滚上去。
# 【★ R05】定点数再乘之前夹一次 int32 上限, 越界会回绕成负数且不报错。
# ============================================================
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get

scoreboard players set #bh_m zx.meta 0
execute store result score #bh_m zx.meta run data get storage manacore:out r.value 1000
scoreboard players operation #bh_m zx.meta -= @s zx.bh_addm

# 乘数 = 2 × 空闲位
scoreboard players operation #bh_k zx.meta = #bh_free zx.meta
scoreboard players operation #bh_k zx.meta *= #2 zx.meta

# R05: 动态上限 = INT32_MAX ÷ 乘数
scoreboard players set #bh_cap zx.meta 2147483647
execute if score #bh_k zx.meta matches 1.. run scoreboard players operation #bh_cap zx.meta /= #bh_k zx.meta
execute if score #bh_m zx.meta > #bh_cap zx.meta run scoreboard players operation #bh_m zx.meta = #bh_cap zx.meta

scoreboard players operation #bh_want zx.meta = #bh_m zx.meta
scoreboard players operation #bh_want zx.meta *= #bh_k zx.meta
scoreboard players operation #bh_want zx.meta /= #100 zx.meta
