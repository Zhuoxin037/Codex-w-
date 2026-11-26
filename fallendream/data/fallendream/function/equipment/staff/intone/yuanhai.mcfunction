# ============================================================
# fallendream:equipment/staff/intone/yuanhai —— 引声·超限：把这一轮打到过的人附加「渊海」
# ------------------------------------------------------------
# 【执行者】施法者(玩家)
# 【名单来源】profession/singer/pulse 在清 zx.j_follow_v **之前**抄了一份到 zx.in_vic
#   (见那里的一行注释)。抄的是"这一轮真正投递过伤害的目标", 不是"3 格内所有生物"。
# 【谁会调用它】skill ⑥(第一轮之后) 与 again(1 秒后那一轮之后) —— 两轮各算一次"本次"。
# ============================================================

execute unless entity @e[tag=zx.in_vic,distance=0..,limit=1] run return 0
data modify storage zx:work ic set value {target:"@e[tag=zx.in_vic,distance=0..]",mark:"yuanhai"}
function fallendream:tag/mark with storage zx:work ic
tag @e[tag=zx.in_vic,distance=0..] remove zx.in_vic
