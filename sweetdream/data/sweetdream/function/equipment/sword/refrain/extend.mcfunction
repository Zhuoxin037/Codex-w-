# ============================================================
# sweetdream:equipment/sword/refrain/extend —— 续唱：全部追随者 +4 秒
# ------------------------------------------------------------
# 【执行者】玩家   【样板】equipment/staff/surge_ebb/extend.mcfunction
# 【怎么做】追随者 marker 上 data.u0..u3 存主人 UUID 的 4 个 int，
#   把它们当宏参数塞进选择器 —— 只动自己的，不会误续别人的追随者。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

execute store result storage zx:work rfr.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work rfr.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work rfr.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work rfr.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:equipment/sword/refrain/extend_go with storage zx:work rfr
