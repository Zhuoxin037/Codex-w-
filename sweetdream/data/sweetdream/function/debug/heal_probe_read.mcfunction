# ============================================================
# sweetdream:debug/heal_probe_read —— lib/heal 自检 · 读结果那一步
# ------------------------------------------------------------
# 【谁调用它】debug/heal_probe 里的 `schedule … 2t`（**没有执行者**，靠标签找人）
# 【为什么单独一个文件】schedule 不带上下文，函数体里必须自己把"刚才测的那个人"
#   找回来 —— 用 debug/heal_probe 留下的 zx.hp_probe 标签。
# 【两刻够不够】instant_health 在"下一拍实体 tick 的 tickEffects()"里生效，
#   而 core/tick 撤天花板还要再一拍 —— 所以两刻后读到的**正是**目标血量。
# ============================================================

scoreboard players set #hp_after zx.meta 0
execute as @a[tag=zx.hp_probe] store result score #hp_after zx.meta run data get entity @s Health 1000

execute as @a[tag=zx.hp_probe] run tellraw @s [{"text":" [后] ","color":"gray"},{"score":{"name":"#hp_after","objective":"zx.meta"},"color":"aqua"},{"text":" (×1000)    （应 ≈ 前 + 要求点数×1000）","color":"dark_gray"}]
execute as @a[tag=zx.hp_probe] run tellraw @s [{"text":" 累计跑过 ","color":"dark_gray"},{"score":{"name":"#hp_runs","objective":"zx.meta"},"color":"dark_gray"},{"text":" 次     若 [后] 直接等于上限 = 又回到\"一键满血\"了，把 [内部] 那行发我。","color":"dark_gray"}]

tag @a remove zx.hp_probe
