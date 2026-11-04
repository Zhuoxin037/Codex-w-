# ============================================================
# sweetdream:equipment/sword/oath_victory/field_tick —— 领域每秒一跳（执行者 = marker）
# ------------------------------------------------------------
# 【谁调用它】lib/second（三个维度各扫一遍 zx.ov_field）
# 【每秒】① 按 marker 里存的 UUID 反查施法者 ② 施法者在 3 格内 ⇒ field_heal
#   ③ 计时 -1，归零 kill。
# 【★ 为什么"反查"而不是"给玩家挂计时" ★】领域在地上，施法者走开就不该再吃回复。
#   把状态挂在玩家身上等于假设"人一直在圈里"，那是错的（神裁/凝壳同款口径）。
# ============================================================

data modify storage zx:work ub.u0 set from entity @s data.zx.u[0]
data modify storage zx:work ub.u1 set from entity @s data.zx.u[1]
data modify storage zx:work ub.u2 set from entity @s data.zx.u[2]
data modify storage zx:work ub.u3 set from entity @s data.zx.u[3]
function sweetdream:lib/u_by

# 施法者本人站在圈里才给（radius 3，改这里就改领域半径）
execute as @a[tag=zx.ub,distance=..3,limit=1] at @s run function sweetdream:equipment/sword/oath_victory/field_heal

# 表现：领域里一圈缓缓上升的光
particle minecraft:end_rod ~ ~0.2 ~ 1.6 0.15 1.6 0.01 6 normal

scoreboard players remove @s zx.ov_ft 1
execute if score @s zx.ov_ft matches ..0 run kill @s
