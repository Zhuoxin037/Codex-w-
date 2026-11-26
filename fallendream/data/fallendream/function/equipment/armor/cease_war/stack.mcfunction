# ============================================================
# fallendream:equipment/armor/cease_war/stack —— 止战(超限·转化态)：自身基础攻击力 +5% ×3 层
# ------------------------------------------------------------
# 【执行者】动手的那个玩家   【谁调它】cease_war/ol_hit ④
# 【文案(逐字)】"…且自身基础攻击力 +5%，可以叠加三次，持续至余勇效果结束。"
# 【★ 为什么记 b0 ★】每层都是"**基础**攻击力的 5%" ⇒ 需要一个固定基准。
#   若每层都按当时的（已经加过的）面板值算，三层会叠成 15.76% 而不是 15%。
#   所以第一层时把面板基础攻击力拍成 zx.cw_b0（×1000），之后每层都用它。
# 【★ 只写面板 base_attack ★】与涤火 +30% 同口径（api/stats/get base_attack 读到的就是它）。
# 【★ 差值制 ★】账本 zx.cw_badd = 已经加在面板上的量，每次都按"目标量 − 已加量"补差，
#   到期在 cease_war/end 里一次性取负退还。
# ============================================================

# ① 层数：最多 3 层（已经 3 层就只刷新存在感，不再加）
execute if score @s zx.cw_st matches 3.. run return 0
scoreboard players add @s zx.cw_st 0
scoreboard players add @s zx.cw_st 1

# ② 第一层：记下基准基础攻击力（×1000）
execute if score @s zx.cw_st matches 1 run function fallendream:lib/uuid
execute if score @s zx.cw_st matches 1 run data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
execute if score @s zx.cw_st matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.cw_st matches 1 run function manacore:api/stats/get
execute if score @s zx.cw_st matches 1 run scoreboard players set @s zx.cw_b0 0
execute if score @s zx.cw_st matches 1 store result score @s zx.cw_b0 run data get storage manacore:out r.value 1000

# ③ 目标加成（×1000）= b0 × (层数 × 5) ÷ 100
scoreboard players operation #cw_p zx.meta = @s zx.cw_st
scoreboard players set #cw_5 zx.meta 5
scoreboard players operation #cw_p zx.meta *= #cw_5 zx.meta
scoreboard players operation #cw_w zx.meta = @s zx.cw_b0
#   ★ R05 上界: b0 是 ×1000 定点, ×(≤15) 之前先夹到 INT32_MAX ÷ 乘数
scoreboard players set #cw_cap zx.meta 2147483647
scoreboard players operation #cw_cap zx.meta /= #cw_p zx.meta
execute if score #cw_w zx.meta > #cw_cap zx.meta run scoreboard players operation #cw_w zx.meta = #cw_cap zx.meta
scoreboard players operation #cw_w zx.meta *= #cw_p zx.meta
scoreboard players set #cw_100 zx.meta 100
scoreboard players operation #cw_w zx.meta /= #cw_100 zx.meta

# ④ 差值 -> 面板
scoreboard players operation #cw_d zx.meta = #cw_w zx.meta
scoreboard players operation #cw_d zx.meta -= @s zx.cw_badd
execute if score #cw_d zx.meta matches 0 run return 0
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #cw_d zx.meta
function manacore:api/stats/add
scoreboard players operation @s zx.cw_badd = #cw_w zx.meta
