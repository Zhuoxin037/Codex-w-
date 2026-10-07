# ============================================================
# sweetdream:equipment/axe/dream_reader/pet_tick —— “入梦体”每刻推进(执行者 = 入梦体)
# ------------------------------------------------------------
# 【谁调用它】core/tick(三维度各一行: execute in <维> as @e[distance=0..,tag=zx.dr_pet] at @s run ...)
# 【它做什么】
#   ① 安全寿命(30 秒)到 -> 自毁
#   ② 离**施法者** 10 格 -> 自毁(反查施法者, 见 lib/find_by)
#   ③ 认领"离它最近的、没被别的入梦体认领的"生物(打 zx.dr_claim)
#   ④ 朝认领目标飞(每刻 0.65 格); 进 1.4 格就结算并自毁(见 pet_hit)
# 【★ 不同入梦体不追同一个目标 ★】认领标记 zx.dr_claim 由 core/tick 每刻先清一遍,
#   然后入梦体**依次**认领 —— 先跑的那个把它最近的占掉, 后面的只能挑没被占的,
#   于是同一刻里不会有两个入梦体盯上同一只。
# 【★ 所有 @e 都带位置参数 ★】本函数挂在"每维度各跑一次"的链上(core/tick 三行
#   execute in <维>), 裸 @e 会跨维度重复处理 —— 每行都写 distance=...(顺带锁维度)。
# ============================================================

# ① 安全寿命
scoreboard players remove @s zx.dr_life 1
execute if score @s zx.dr_life matches ..0 run return run kill @s

# ② 离施法者 10 格 -> 自毁
data modify storage zx:work fb.u0 set from entity @s data.zx.u[0]
data modify storage zx:work fb.u1 set from entity @s data.zx.u[1]
data modify storage zx:work fb.u2 set from entity @s data.zx.u[2]
data modify storage zx:work fb.u3 set from entity @s data.zx.u[3]
function sweetdream:lib/find_by with storage zx:work fb
execute unless entity @a[tag=zx.mc_by,limit=1] run return run kill @s
execute unless entity @a[tag=zx.mc_by,distance=0..10,limit=1] run return run kill @s
tag @a remove zx.mc_by

# ③ 认领目标: 最近的、没被认领的生物(24 格内)
execute at @s as @e[type=!#sweetdream:no_damage,tag=!zx.dr_claim,distance=0..24,sort=nearest,limit=1] run tag @s add zx.dr_claim

# ④ 靠近认领目标; 进 1.4 格就结算
execute at @s if entity @e[type=!#sweetdream:no_damage,tag=zx.dr_claim,distance=0..24] facing entity @e[type=!#sweetdream:no_damage,tag=zx.dr_claim,distance=0..24,sort=nearest,limit=1] feet run tp @s ^ ^ ^0.65
execute at @s if entity @e[tag=zx.dr_claim,distance=..1.4,limit=1] run function sweetdream:equipment/axe/dream_reader/pet_hit

# ⑤ 表现: 一路幽紫魂光
particle minecraft:soul ~ ~ ~ 0.15 0.15 0.15 0.01 2 normal
