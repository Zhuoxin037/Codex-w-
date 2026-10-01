# ============================================================
# sweetdream:equipment/axe/charge/passive —— 被动(以玩家身份, 每秒跑一次)
# ------------------------------------------------------------
# 【文案】主手持时, 自身获得迅捷 I。
# 【为什么给 3 秒、每秒刷】松手/换手之后最多 3 秒它自己就没了, 不用调
#   effect clear —— clear 在"本来就没有这个效果"时会失败, 那种失败会截断函数。
# 【会不会把技能给的迅捷 II 顶掉】不会: 原版只认"更强 or 更久"的那一个,
#   拿 I(amplifier 0)去盖已经有 II(amplifier 1)的玩家, 会被直接忽略。
# ============================================================

execute if items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["charge"]}] run effect give @s minecraft:speed 3 0 true
