# ============================================================
# fallendream:equipment/axe/detach/hit_go —— 脱离：本次攻击追加 最大生命值 伤害
# ------------------------------------------------------------
# 【执行者】玩家（动手的）
# 【伤害投递】a.num → lib/num/plain → internal/damage/with_from（deal 唯一出口）
#   数值 = zx.dt_hp（毫点）×0.001 = 最大生命值本身。
# ============================================================

function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/axe/detach/hit_go/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
