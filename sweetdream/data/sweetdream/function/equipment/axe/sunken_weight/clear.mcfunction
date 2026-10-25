# ============================================================
# sweetdream:equipment/axe/sunken_weight/clear —— 层数清零 + 摘移速惩罚
# ============================================================
scoreboard players reset @s zx.sw_n
function sweetdream:equipment/axe/sunken_weight/speed_sync

execute at @s run particle minecraft:block{block_state:"minecraft:iron_block"} ~ ~1 ~ 0.5 0.6 0.5 0.02 12 normal
execute at @s run playsound minecraft:block.anvil.break player @a ~ ~ ~ 0.6 1.3
