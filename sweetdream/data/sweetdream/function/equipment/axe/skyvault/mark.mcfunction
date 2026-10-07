# ============================================================
# sweetdream:equipment/axe/skyvault/mark —— 给 zx.victim 叠一层「升痕」(上限 3)
# ------------------------------------------------------------
# 【执行者】玩家(位置忽略)   【目标】zx.victim
# 【「升痕」存在哪】计分项 zx.stg(0..3, 挂在**生物**身上) —— 用计分项而不是标签,
#   因为要数层数(标签只知道"在不在")。它没接进头顶图标系统, 不影响机制。
# 【★ 有寿命 ★】每 15 秒 −1 层(见 status/decay_stg)。每次叠层都把计时重置为 15 ——
#   也就是"最后一次叠加之后再数 15 秒, 才开始逐层衰减"。改时长要连 decay_stg 一起改。
# ============================================================

scoreboard players add @e[tag=zx.victim,limit=1] zx.stg 1
execute as @e[tag=zx.victim,limit=1] if score @s zx.stg matches 4.. run scoreboard players set @s zx.stg 3
scoreboard players set @e[tag=zx.victim,limit=1] zx.stg_t 15
execute at @e[tag=zx.victim] run particle minecraft:end_rod ~ ~1.2 ~ 0.2 0.3 0.2 0.0 6 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.5 1.2
