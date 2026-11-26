$execute unless entity $(vx_uuid) run return 0

# ④ 我的 UUID[0](与 wedge_one 写进 zx.twg_own 的值同一来源)
scoreboard players set #twg_me zx.meta 0
execute store result score #twg_me zx.meta run data get entity @s UUID[0]

# ⑤ 以"命中位置"为基准, 找范围里属于我的雷楔 -> 由它落雷
#   ★ 先 `at @e[tag=zx.victim]` 再 `as @e[tag=zx.twg_wedge,distance=..8]`: at 定位置、
#     as 换身份, distance 才是"从被击者算 8 格"; 顺序反了会变成"从玩家算 8 格"。
#   ★ strike 里的 `~ ~ ~` 就是这里 at 出去的命中位置, 所以落雷点必然正确。
#   【两行: 原版 8 格 / 超限 12 格】选择器没法读 marker 上的半径, 只能按标签分两路。
#     两路必须**互斥**(一个判 unless、一个判 if 同一个标签), 否则超限那只在 8 格内
#     会被落两次雷。
$execute at $(vx_uuid) as @e[type=marker,tag=zx.twg_wedge,distance=..8] if score @s zx.twg_own = #twg_me zx.meta unless entity @s[tag=zx.twg_ol] run function fallendream:equipment/sword/thunder_wedge/strike
$execute at $(vx_uuid) as @e[type=marker,tag=zx.twg_wedge,distance=..12] if score @s zx.twg_own = #twg_me zx.meta if entity @s[tag=zx.twg_ol] run function fallendream:equipment/sword/thunder_wedge/strike

# ⑥ 摘掉临时标签
$tag $(vx_uuid) remove zx.victim
