# 在当前维度里收所有到点的冷冻/时停(由 unfreeze_sweep 逐维度调用)
execute as @e[tag=zx.freeze] if score @s zx.fz_end <= #now manacore.meta run function sweetdream:lib/unfreeze_one
execute as @e[tag=zx.stop] if score @s zx.ts_end <= #now manacore.meta run function sweetdream:lib/timestop_one