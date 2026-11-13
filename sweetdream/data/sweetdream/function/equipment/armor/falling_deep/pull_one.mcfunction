# ============================================================
# sweetdream:equipment/armor/falling_deep/pull_one —— 落溟：单只生物拉向中心
# ------------------------------------------------------------
# 【谁调用它】field_tick ③（execute at @s as @e[...] at @s run function ...）
# 【执行者】领域内的一只非玩家生物
# 【写法】照 tide_buckle/pull_step：距离不足 0.25 格就停（不越过圆心再向外），
#   朝圆心走 0.25 格，脚部/头部两格都可替换才 tp，遇障即停。
# ============================================================

execute at @e[tag=zx.fd_center,distance=0..,limit=1] unless entity @s[distance=0.25..] run return 0
execute at @s facing entity @e[tag=zx.fd_center,distance=0..,limit=1,sort=nearest] feet positioned ^ ^ ^0.25 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~
