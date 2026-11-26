# ============================================================
# fallendream:equipment/axe/throe/hit_go —— 痛楚：两段法球兑现
# ------------------------------------------------------------
# 【执行者】玩家
# 【★ 两段都要"还有球"才发生 ★】第一段扣完变 0 就不进第二段（文案"之后若仍有法球"）。
# 【★ 易伤走伤害管线 ★】在目标身上挂 zx.pn_vul + 到期刻，由 internal/damage/one 里
#   一行钩子乘 ×1.1 结算；到期由 throe/sweep 每秒摘标签。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/axe/throe/hit_go/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
