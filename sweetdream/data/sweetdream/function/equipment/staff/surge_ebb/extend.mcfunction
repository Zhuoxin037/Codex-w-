# ============================================================
# sweetdream:equipment/staff/surge_ebb/extend —— 潮涌，潮枯：全部追随者 +1 秒
# ------------------------------------------------------------
# 【执行者】玩家（已确认术阵已满）
# 【怎么做】追随者身上存的是主人 UUID 的 4 个 int（data.u0..u3），
#   把它们当宏参数塞进选择器 —— 只动自己的，不会误续别人的追随者。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

execute store result storage zx:work se.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work se.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work se.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work se.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:equipment/staff/surge_ebb/extend_go with storage zx:work se
