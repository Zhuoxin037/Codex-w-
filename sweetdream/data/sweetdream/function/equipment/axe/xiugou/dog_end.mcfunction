# ============================================================
# sweetdream:equipment/axe/xiugou/dog_end —— 锈犬到点收工
# ------------------------------------------------------------
# 【执行者】marker
# ============================================================
execute at @s run particle minecraft:smoke ~ ~0.2 ~ 0.4 0.3 0.4 0.02 18 normal
execute at @s run particle minecraft:poof ~ ~0.2 ~ 0.3 0.2 0.3 0.02 10 normal
execute at @s run playsound minecraft:entity.wolf.death player @a ~ ~ ~ 0.6 1.2
kill @s
