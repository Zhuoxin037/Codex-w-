# ============================================================
# fallendream:equipment/sword/oath_victory/field —— 生成领域 marker（宏 {uuid,u0..u3}）
# ------------------------------------------------------------
# 【执行位置】施法者停留处（cast 里 `at @s` 送进来）
# 【领域是什么】marker，NBT 存施法者 UUID（uu 文本 + u 四个整数）。
#   · u 四个整数给 lib/u_by 反查玩家（零 NBT，卡顿坑 1）；
#   · uu 文本只用于排查，不参与判定。
# 【计时】zx.ov_ft = 6 秒，lib/second 每秒 -1，归零 kill。
# 【代码】"半径 3" 不在 NBT 里 —— 判定写在 field_tick 的选择器上，改半径只需改那一处。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.ov_field","zx.ov_new"],data:{zx:{uu:"$(uuid)",u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

execute as @e[tag=zx.ov_new,distance=..2,limit=1] run scoreboard players set @s zx.ov_ft 6
tag @e[tag=zx.ov_new,distance=..2] remove zx.ov_new
