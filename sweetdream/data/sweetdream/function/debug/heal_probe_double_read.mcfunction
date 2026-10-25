# ============================================================
# sweetdream:debug/heal_probe_double_read —— 重入自检 · 读结果那一步
# ------------------------------------------------------------
# 【谁调用它】debug/heal_probe_double 里的 `schedule … 2t`（不带执行者，靠标签找人）
# 【两刻够不够】instant_health 在"下一拍实体 tick 的 tickEffects()"里生效，
#   core/tick 撤天花板还要再一拍 —— 两刻后读到的**正是**目标血量。
# 【★ 别和 debug/heal_probe_read 合并】两者的标签(zx.hp_probe / zx.hp_probe2)与
#   期望值算法不同（这里是 2×点数），合并会让"跑单次却看到被覆盖的数字"。
# ============================================================

scoreboard players set #hp_after2 zx.meta 0
execute as @a[tag=zx.hp_probe2] store result score #hp_after2 zx.meta run data get entity @s Health 1000

execute as @a[tag=zx.hp_probe2] run tellraw @s [{"text":" [后] ","color":"gray"},{"score":{"name":"#hp_after2","objective":"zx.meta"},"color":"aqua"},{"text":" (×1000)    应 ≈ 前 + 2×点数","color":"dark_gray"}]
execute as @a[tag=zx.hp_probe2] run tellraw @s [{"text":" 上限 ","color":"gray"},{"score":{"name":"#hp_max2","objective":"zx.meta"},"color":"aqua"},{"text":" 点     若 [后] 直接等于上限 = 重入又变成满血；若 ≈ 前+点数 = 只算了一次。两种都请把 [内部] 那行发我。","color":"dark_gray"}]

tag @a remove zx.hp_probe2
