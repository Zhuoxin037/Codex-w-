# ============================================================
# sweetdream:lib/timestop_one —— 时停到点(执行者 = 被时停的那只)
# 【做三件事】按**原本的样子**还原 NoAI / 摘 zx.stop / 清自己的计时(zx.ts_end)
# 【为什么不用管冷冻】计时已经拆开, 互不干扰(建议清单第 4 条)。
# ============================================================

execute if score @s zx.noai_bak matches 1 run data modify entity @s NoAI set value 1b
execute unless score @s zx.noai_bak matches 1 run data modify entity @s NoAI set value 0b
scoreboard players reset @s zx.noai_bak
tag @s remove zx.stop
scoreboard players reset @s zx.ts_end