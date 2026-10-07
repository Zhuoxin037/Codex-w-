# ============================================================
# sweetdream:lib/anim_step —— 通用逐帧动画: 推一帧(每刻跑, 见 core/tick)
# ------------------------------------------------------------
# 【谁调用它】core/tick 里的一行:
#     execute as @e[tag=zx.anim] run function sweetdream:lib/anim_step with entity @s data.zx.anim
# 【参数从哪来】实体**自己的** data.zx.anim(不是 storage), 四个键:
#   · field = "translation" / "scale"  要动的 transformation 字段
#   · track = "rise_y" / "sink_y" / "spread" / "shrink"  取哪条轨道
#             (轨道表在 core/load 里写进 storage zx:anim, 见那里的注释)
#   · key   = 帧号计分项名(如 "zx.gw_anim") —— 召唤时 set 14, 这里每刻 -1
#   · dir   = "in" / "out"; "out" = 退场, 走完最后一帧要把自己 kill 掉
# ★ 带 zx.anim 标签的实体**必须**有完整的这四个键, 缺一个宏参数就绑不上、
#   整个函数一条命令都不跑(而且几乎是静默的) —— 所以标签只在 data 写好后才加。
# 【为什么逐帧、不用 interpolation_duration】见 RULES「display 实体入场动画」一节:
#   客户端补间在 1.21.5 实测不可靠(MC-259926 插值非确定 / MC-260874 相邻两刻
#   chained desync), 关键帧由服务端每刻下发、interpolation_duration 保持 0 才稳。
# 【帧号 → 数组下标】下标 0..13 对应第 1..14 帧, 帧号从 14 掉到 0,
#   所以 下标 = 13 - 帧号(帧号 13 → [0]; 帧号 0 → [13] 终态)。
# ★ 帧值从 storage 的 float 数组取, 不在这里硬编码浮点 ——
#   以后加新召唤物只写一行轨道表 + 4 个字段, 13 条 if 一行都不用抄。
# ============================================================

# ① 帧号 -1; ② 按帧号取这一帧的值; ③ 帧号走完 → 摘标签(+ 退场的收掉自己)
$scoreboard players remove @s $(key) 1

$execute if score @s $(key) matches 13 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[0]
$execute if score @s $(key) matches 12 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[1]
$execute if score @s $(key) matches 11 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[2]
$execute if score @s $(key) matches 10 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[3]
$execute if score @s $(key) matches 9 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[4]
$execute if score @s $(key) matches 8 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[5]
$execute if score @s $(key) matches 7 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[6]
$execute if score @s $(key) matches 6 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[7]
$execute if score @s $(key) matches 5 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[8]
$execute if score @s $(key) matches 4 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[9]
$execute if score @s $(key) matches 3 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[10]
$execute if score @s $(key) matches 2 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[11]
$execute if score @s $(key) matches 1 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[12]
$execute if score @s $(key) matches ..0 run data modify entity @s transformation.$(field) set from storage zx:anim $(track)[13]

$execute if score @s $(key) matches ..0 run tag @s remove zx.anim
$execute if score @s $(key) matches ..0 if data entity @s data.zx.anim{dir:"out"} run kill @s
