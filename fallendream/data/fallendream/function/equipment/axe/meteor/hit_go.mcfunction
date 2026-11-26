# ============================================================
# fallendream:equipment/axe/meteor/hit_go —— 被动主体: 掷概率 -> 降陨石
# ------------------------------------------------------------
# 【执行者】动手的玩家
# 【概率怎么算】平时 10%: `#rnd %10 == 0`(1/10)。
#   熔星形态开着(zx.mt_on >= 1)时 50%: `#rnd %10 < #5`(0..4 共 5 个 = 一半)。
#   随机源统一走 lib/rnd(出参 0..32767), 和全包其余概率判定同一套。
# 【为什么要先钉 victim】lib/victim 把"刚才这一下打中的那只"冻成 zx.victim 标签。
# ============================================================

function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/axe/meteor/hit_go/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
