# ============================================================
# fallendream:equipment/armor/breath_hold/apply_pct —— 把上限差值补进面板
# ------------------------------------------------------------
# 【执行者】玩家   【入参】#bh_want = 目标加成(×1000)；@s zx.bh_addm = 已加(×1000)
# 【为什么每次都要跑(哪怕没穿)】#bh_want 在没穿 / 基础版 / 全满 时是 0 ⇒ 这一趟
#   正好把账本余额退回去。"只在穿着时维护"就是"穿过一次永久 +X"。
# ============================================================
scoreboard players operation #bh_diff zx.meta = #bh_want zx.meta
scoreboard players operation #bh_diff zx.meta -= @s zx.bh_addm
execute if score #bh_diff zx.meta matches 0 run return 0

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #bh_diff zx.meta
function manacore:api/stats/add
scoreboard players operation @s zx.bh_addm += #bh_diff zx.meta
