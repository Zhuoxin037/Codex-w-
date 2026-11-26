# ============================================================
# fallendream:equipment/armor/breath_hold/regen_ol —— 超限: 每个空闲位回 0.5% 上限
# ------------------------------------------------------------
# 【执行者】玩家   【入参】#bh_free = 空闲术阵位数(≥1)
# 【出参】#bh_re = 本秒回魔量(单位 1/1000 点, 与 second ③ 同一量纲)
# 【公式】re = (max_mana ×1000) × 空闲位 × 5 ÷ 1000   ← 0.5% = 5/1000
# 【★ R05】读进来的 max 已经是 ×1000 定点, 再乘之前夹一次 int32 上限。
# ============================================================
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get

scoreboard players set #bh_max zx.meta 0
execute store result score #bh_max zx.meta run data get storage manacore:out r.value 1000

# 乘数 = 空闲位 × 5
scoreboard players operation #bh_k zx.meta = #bh_free zx.meta
scoreboard players operation #bh_k zx.meta *= #5 zx.meta

scoreboard players set #bh_cap zx.meta 2147483647
execute if score #bh_k zx.meta matches 1.. run scoreboard players operation #bh_cap zx.meta /= #bh_k zx.meta
execute if score #bh_max zx.meta > #bh_cap zx.meta run scoreboard players operation #bh_max zx.meta = #bh_cap zx.meta

scoreboard players operation #bh_re zx.meta = #bh_max zx.meta
scoreboard players operation #bh_re zx.meta *= #bh_k zx.meta
scoreboard players operation #bh_re zx.meta /= #1000 zx.meta
