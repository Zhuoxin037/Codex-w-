# ============================================================
# sweetdream:equipment/axe/chenyuan/hit_go —— 被动主体: 冷却 -1 秒 + 渊海分支
# ------------------------------------------------------------
# 【执行者】动手的玩家
# 【执行顺序】① 钉死刚打中的那只 ② 判它带不带缓慢 ③ 冷却 -1 秒 ④ 魔力 > 300 的额外分支
# ============================================================

function sweetdream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function sweetdream:equipment/axe/chenyuan/hit_go/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
