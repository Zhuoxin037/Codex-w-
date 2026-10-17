# ============================================================
# sweetdream:equipment/staff/other_shore/classify —— 给一只生物打上"状态分类"临时标签
# ------------------------------------------------------------
# 【执行者】被选中的生物   【位置】它自己
# 【产出】(四种互斥的临时标签, 每种最多一个)
#     zx.os_both  = 同时有「渊海」和「噬心」
#     zx.os_y     = **只有**「渊海」
#     zx.os_s     = **只有**「噬心」
#     zx.os_none  = 两个都没有
# 【★★ 为什么必须先分类、再动手 ★★】
#   普攻那一段的三条判断是"按**命中那一刻**的状态决定做什么"。如果一边判一边改
#   (先给"两个都没有"的附上「渊海」, 再在后面判"只有渊海 -> 25% 附噬心"),
#   刚附上的那批会被自己的第二条判据再抽一次 25% —— 变成"一发普攻白送两个状态"。
#   所以先拍快照标签, 后续**一律按快照**执行(同坑 123 的教训: 改状态后再按该状态选人)。
# 【为什么四种标签不合并成计分项】它们只在**同一次技能调用内**有效, 用完即弃;
#   标签比计分项更自然(不需要在 player_reset / rearm 里多登记两个账本)。
# ============================================================

tag @s remove zx.os_both
tag @s remove zx.os_y
tag @s remove zx.os_s
tag @s remove zx.os_none

execute unless entity @s[tag=zx.status.yuanhai] unless entity @s[tag=zx.status.shixin] run tag @s add zx.os_none
execute if entity @s[tag=zx.status.yuanhai,tag=zx.status.shixin] run tag @s add zx.os_both
execute if entity @s[tag=zx.status.yuanhai] unless entity @s[tag=zx.status.shixin] run tag @s add zx.os_y
execute if entity @s[tag=zx.status.shixin] unless entity @s[tag=zx.status.yuanhai] run tag @s add zx.os_s
