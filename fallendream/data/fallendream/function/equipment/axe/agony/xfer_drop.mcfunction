# ============================================================
# fallendream:equipment/axe/agony/xfer_drop —— 把"我"身上的苦痛锁摘下来（旧锁回收）
# ------------------------------------------------------------
# 【谁调用它】xfer ①（在 `as @e[tag=zx.ag_t]` 里、且 uuid 是本轮释放者的那一只）
# 【执行者】旧锁目标（生物）
# 【留下三样给 xfer 搬走】#ag_xe = 剩余到期刻；storage zx:work agid = 释放者身份整份
# ============================================================

scoreboard players operation #ag_xe zx.meta = @s zx.ag_end
data modify storage zx:work agid set from entity @s data.zx.ag
tag @s remove zx.ag_t
data remove entity @s data.zx.ag
scoreboard players reset @s zx.ag_end
