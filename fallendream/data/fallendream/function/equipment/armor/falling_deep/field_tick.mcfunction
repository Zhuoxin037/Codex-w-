# ============================================================
# fallendream:equipment/armor/falling_deep/field_tick —— 落溟领域每秒一跳
# ------------------------------------------------------------
# 【谁调用它】lib/second 三维度（需主对话加三行）：
#   execute in minecraft:overworld   as @e[type=minecraft:marker,tag=zx.fd_field,distance=0..] at @s run function fallendream:equipment/armor/falling_deep/field_tick
#   execute in minecraft:the_nether  as @e[type=minecraft:marker,tag=zx.fd_field,distance=0..] at @s run function fallendream:equipment/armor/falling_deep/field_tick
#   execute in minecraft:the_end     as @e[type=minecraft:marker,tag=zx.fd_field,distance=0..] at @s run function fallendream:equipment/armor/falling_deep/field_tick
# 【执行者】领域 marker   【频率】每秒
# 【每秒】① 到期判定（绝对刻 zx.fd_end = 生成刻 +100 = 5 秒）；② 领域内半径
#   3 格的非玩家生物获得 1 秒缓慢 Ⅱ；③ 被小力拉向领域中心（0.25 格，遇障即停）
# ============================================================

# ① 到期：marker 自己收掉（术阵位由 formation/create 的 5 秒自动到期释放，不额外清）
execute if score @s zx.fd_end <= #now manacore.meta run return run function fallendream:equipment/armor/falling_deep/field_end

# ② 1 秒缓慢 Ⅱ（amplifier 1 = Ⅱ；每秒刷新一次，在领域内就一直有）
execute at @s run effect give @e[type=!#fallendream:no_damage,distance=..3] minecraft:slowness 1 1 true

# ③ 每秒被小力拉向领域中心（0.25 格，遇障即停，照 tide_buckle/pull_step）
tag @e[tag=zx.fd_center,distance=0..] remove zx.fd_center
tag @s add zx.fd_center
execute at @s as @e[type=!#fallendream:no_damage,distance=..3] at @s run function fallendream:equipment/armor/falling_deep/pull_one
tag @s remove zx.fd_center

# ④ 表现
particle minecraft:snowflake ~ ~0.2 ~ 2.6 0.1 2.6 0.02 10 normal
