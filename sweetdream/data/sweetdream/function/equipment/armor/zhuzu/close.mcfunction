# ============================================================
# sweetdream:equipment/armor/zhuzu/close —— 收领域（移动时 / 手动清场）
# ------------------------------------------------------------
# 【执行者】玩家
# 【做什么】把属于自己的 zx.zz_field marker 全部 kill，并清 zx.zz_on
# 【为什么三维度各写一遍】marker 只能按维度找；三个维度都扫一遍最省事
#   （领域数量极少，不会成为每刻负担 —— 本函数只在"刚动起来"的那一瞬跑）。
# ============================================================
scoreboard players set @s zx.zz_on 0
scoreboard players set #zz_me zx.meta 0
execute store result score #zz_me zx.meta run data get entity @s UUID[0]

execute in minecraft:overworld as @e[type=marker,tag=zx.zz_field,distance=0..] if score @s zx.zz_own = #zz_me zx.meta run kill @s
execute in minecraft:the_nether as @e[type=marker,tag=zx.zz_field,distance=0..] if score @s zx.zz_own = #zz_me zx.meta run kill @s
execute in minecraft:the_end as @e[type=marker,tag=zx.zz_field,distance=0..] if score @s zx.zz_own = #zz_me zx.meta run kill @s

execute at @s run particle minecraft:smoke ~ ~0.1 ~ 1.8 0.1 1.8 0.01 20 normal
execute at @s run playsound minecraft:block.stone.break player @a ~ ~ ~ 0.6 0.7
