# ============================================================
# sweetdream:equipment/staff/fate_thread/watch_end —— 收掉一条连丝(玩家侧)
# ------------------------------------------------------------
# 【谁调用它】watch ②(7 秒到点) / ③(主目标没了) / ④(失去「噬心」)
# 【执行者】**施法者本人**   【位置】玩家所在
# 【做什么】把**本实例**(同 zx.ft_n)的主目标/相连者标记全摘掉, 清掉玩家身上的三样状态,
#   再播一次断线表现。
#
# 【★ 为什么按实例号摘, 而不是全摘 ★】同时可能有别的玩家的连丝在场, 一刀切会剪断别人的。
# 【★ 为什么玩家侧也要收场 ★】marker 可能没生成、也可能被别的机制提前清掉;
#   玩家身上的 zx.ft_end 是"一定会到期"的那份保险, 不留永久标记。
# 【★ 幂等 ★】field_end(marker 侧每秒计时)也会摘一遍同样的标记; 重复摘 = 空操作。
# ============================================================

# 本实例号(0 说明本来就没有, 直接清状态走人)
scoreboard players add @s zx.ft_mine 0
execute if score @s zx.ft_mine matches 0 run return 0
scoreboard players operation #ft_iid zx.meta = @s zx.ft_mine

# 摘本实例的标记(主目标 + 相连者 + 本刻临时标签)
execute as @e[tag=zx.ft_main] if score @s zx.ft_n = #ft_iid zx.meta run tag @s remove zx.ft_main
execute as @e[tag=zx.ft_lk] if score @s zx.ft_n = #ft_iid zx.meta run tag @s remove zx.ft_lk
tag @e[tag=zx.ft_wt] remove zx.ft_wt
tag @e[tag=zx.ft_hit2] remove zx.ft_hit2

# 清玩家身上的三样状态 + 入口标签
#   (zx.ft_scan / zx.ft_max 两个排查期诊断量已于 2026-10-17 删除)
scoreboard players set @s zx.ft_mine 0
scoreboard players set @s zx.ft_got 0
scoreboard players reset @s zx.ft_end
tag @s remove zx.ft_link

# 表现: 丝线断落
particle minecraft:dust{color:[0.75,0.1,0.2],scale:1.0} ~ ~1 ~ 0.6 0.6 0.6 0.01 20 normal
playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.7 1.3
