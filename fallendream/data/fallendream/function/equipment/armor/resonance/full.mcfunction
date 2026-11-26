# ============================================================
# fallendream:equipment/armor/resonance/full —— 超限·共振：术阵位全满的每秒效果
# ------------------------------------------------------------
# 【执行者】玩家（由 resonance/passive 每秒送进来，只对穿超限共振的人跑）
# 【文案】术阵位全满时，自身每秒恢复 8 魔力值，且自身释放技能所需魔耗及技能冷却
#   时间 -15%。
# 【★ "全满"用接口自带的上限 ★】api/formation/count 同时给 count 和 limit
#   (limit 是玩家的 formation_limit, 默认 3) —— 不要写死 3: 术阵上限是会变的。
# 【三条效果各自的落点】
#   · 每秒 8 魔力 → api/mana/add（本文件 ①）
#   · 魔耗 -15%   → stats.mana_cost_multiplier = 0.85（本文件 ②，账本 zx.rs_mcm）
#   · 冷却 -15%   → **不在这里**：见 resonance/on_cast
#     ★★ stats.cooldown_reduction 被 upgrade/api/cd_stat 独占（它每次结算整体覆盖），
#        写进去会被抹掉还会连带改别人武器的冷却。与 bearing/on_cast 同一结论 ——
#        只能挂 #manacore:event/cooldown_start 对"刚进冷却的那一个技能"减时长。
# ★ 魔耗倍率用"差值"更新: 每秒重算目标值、和账本比、变了才写 ——
#   术阵掉一个、摘甲、换普通共振三条路都能自动退回去。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/formation/count
scoreboard players set #rs_c zx.meta 0
scoreboard players set #rs_l zx.meta 0
execute store result score #rs_c zx.meta run data get storage manacore:out r.count
execute store result score #rs_l zx.meta run data get storage manacore:out r.limit
scoreboard players set #rs_full zx.meta 0
execute if score #rs_l zx.meta matches 1.. if score #rs_c zx.meta >= #rs_l zx.meta run scoreboard players set #rs_full zx.meta 1

# ---- ① 每秒回 8 魔力 ----
execute if score #rs_full zx.meta matches 1 run function fallendream:equipment/armor/resonance/mana8

# ---- ② 魔耗倍率 0.85(850) / 1.0(1000) ----
scoreboard players set #rs_wmcm zx.meta 1000
execute if score #rs_full zx.meta matches 1 run scoreboard players set #rs_wmcm zx.meta 850
scoreboard players add @s zx.rs_mcm 0
scoreboard players operation #rs_d zx.meta = #rs_wmcm zx.meta
scoreboard players operation #rs_d zx.meta -= @s zx.rs_mcm
execute unless score #rs_d zx.meta matches 0 run function fallendream:equipment/armor/resonance/apply_mcm
