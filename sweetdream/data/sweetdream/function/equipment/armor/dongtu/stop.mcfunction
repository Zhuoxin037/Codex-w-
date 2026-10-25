# ============================================================
# sweetdream:equipment/armor/dongtu/stop —— 中断 / 到期
# ------------------------------------------------------------
# 【执行者】玩家
# 【冷却】从中断那一瞬起 20 秒（400 刻），不是从"开始"算 ——
#   站着硬扛完 6 秒和刚开就动，代价不一样。
# ============================================================
scoreboard players set @s zx.dng_on 0
scoreboard players set @s zx.dng_l 0
scoreboard players set @s zx.dng_hp 0
scoreboard players operation @s zx.dng_cd = #now manacore.meta
scoreboard players add @s zx.dng_cd 400

execute at @s run particle minecraft:smoke ~ ~0.1 ~ 0.5 0.1 0.5 0.01 10 normal
execute at @s run playsound minecraft:block.powder_snow.break player @a ~ ~ ~ 0.5 1.1
