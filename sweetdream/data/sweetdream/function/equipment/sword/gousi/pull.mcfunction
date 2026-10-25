# ============================================================
# sweetdream:equipment/sword/gousi/pull —— 拉一步（宏）
# ------------------------------------------------------------
# 【执行者】玩家；位置已在玩家脚下
# 【宏参数】sweetdream:work gs {own}
# 【四段判定，顺序不能换】
#   ① 目标没了 → miss
#   ② 已在身前 2 格内 → land
#   ③ 下一格不可替换（撞墙）→ miss
#   ④ 拉 0.5 格，步数 -1；步数用完 → miss
# 【★ 为什么"撞墙"查的是目标**将要到达**的那一格】把人拉进方块会卡住/挤出，
#   深池（deep_brine/field_tick）就是这么写的，这里照抄同一口径。
# ============================================================
$execute unless entity @e[tag=zx.gs_$(own),limit=1] run function sweetdream:equipment/sword/gousi/miss with storage zx:work gs
$execute unless entity @e[tag=zx.gs_$(own),limit=1] run return 0

$execute if entity @e[tag=zx.gs_$(own),distance=..2,limit=1] run function sweetdream:equipment/sword/gousi/land with storage zx:work gs
$execute if entity @e[tag=zx.gs_$(own),distance=..2,limit=1] run return 0

$execute at @e[tag=zx.gs_$(own),limit=1] facing entity @s feet positioned ^ ^ ^0.5 unless block ~ ~ ~ #minecraft:replaceable run function sweetdream:equipment/sword/gousi/miss with storage zx:work gs
$execute at @e[tag=zx.gs_$(own),limit=1] facing entity @s feet positioned ^ ^ ^0.5 unless block ~ ~ ~ #minecraft:replaceable run return 0

$execute at @e[tag=zx.gs_$(own),limit=1] facing entity @s feet positioned ^ ^ ^0.5 run tp @e[tag=zx.gs_$(own)] ~ ~ ~
$execute at @e[tag=zx.gs_$(own),limit=1] run particle minecraft:end_rod ~ ~0.6 ~ 0.15 0.25 0.15 0.01 4 normal
$execute at @e[tag=zx.gs_$(own),limit=1] run playsound minecraft:block.chain.step player @a ~ ~ ~ 0.35 1.5

scoreboard players remove @s zx.gs_st 1
execute if score @s zx.gs_st matches ..0 run function sweetdream:equipment/sword/gousi/miss with storage zx:work gs
