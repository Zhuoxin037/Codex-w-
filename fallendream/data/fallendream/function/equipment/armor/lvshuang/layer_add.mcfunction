# ============================================================
# fallendream:equipment/armor/lvshuang/layer_add —— 站在霜上：给"脚下那一片"加档
# ------------------------------------------------------------
# 【执行者】玩家（由 lvshuang/tick 的每 10 刻节拍送进来）
# 【原文】"自身停留在霜上时每 0.5 秒可以增加当前位置的霜的层数，最高 3 层且增加的
#   层数不会占用霜上限。"
# 【★ 为什么按"最近的 marker"认 ★】玩家脚下那一片，就是距离他 1 格内最近的那片霜；
#   hover 在 0.05 格高度差内不会有歧义。`sort=nearest,limit=1` 一次选定。
# 【★ 不占上限 ★】只改 zx.lsh_lv（同一片霜内部的加码），不 summon 新 marker，
#   所以"最多 24 片"永远不会被档位顶掉。
# ============================================================

execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["lvshuang"],ol:"lvshuang"}] run return 0
execute unless entity @e[type=marker,tag=zx.lsh_frost,distance=..1,sort=nearest,limit=1] run return 0
execute as @e[type=marker,tag=zx.lsh_frost,distance=..1,sort=nearest,limit=1] at @s run function fallendream:equipment/armor/lvshuang/layer_up
