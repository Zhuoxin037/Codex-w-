# ============================================================
# sweetdream:equipment/sword/gousi/ol_lock —— 锁 8 格内最近的三个目标(宏)
# ------------------------------------------------------------
# 【执行者】玩家(调用方已 `execute at @s`)
# 【宏参数】zx:work gs3 {own} = 玩家 UUID[0]
# 【标记】给三只目标各挂 zx.gs3_<own>; 一只都选不到就返回 fail
# 【★ 为什么 sort=nearest + limit=3 ★】文案是"选中自身 8 格内最近的三个生物"。
#   排序在**玩家脚下**算, 所以调用方必须先 `at @s`。
# 【★ 先清自己那套旧标签 ★】上一轮如果被中途打断(死亡 / 换维度), 残留的
#   zx.gs3_<own> 会让这一轮把上一轮的怪也当成"正在拉" —— 清掉比排查便宜。
# ------------------------------------------------------------
$tag @e[tag=zx.gs3_$(own),distance=0..] remove zx.gs3_$(own)
$tag @e[type=!#sweetdream:no_damage,distance=0.1..8,sort=nearest,limit=3] add zx.gs3_$(own)
$execute unless entity @e[tag=zx.gs3_$(own),limit=1] run return fail
$execute as @e[tag=zx.gs3_$(own),limit=3] at @s run particle minecraft:end_rod ~ ~0.8 ~ 0.3 0.4 0.3 0.02 16 normal
$execute as @e[tag=zx.gs3_$(own),limit=3] at @s run particle minecraft:witch ~ ~0.8 ~ 0.3 0.4 0.3 0.01 10 normal
