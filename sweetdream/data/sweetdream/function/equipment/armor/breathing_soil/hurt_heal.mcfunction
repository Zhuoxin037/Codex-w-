# ============================================================
# sweetdream:equipment/armor/breathing_soil/hurt_heal —— 领域内"每次受伤回 1 点"（2 秒一次）
# ============================================================
execute if score @s zx.so_hc > #now manacore.meta run return 0

scoreboard players set #heal_pt zx.meta 1
function sweetdream:lib/heal

scoreboard players operation @s zx.so_hc = #now manacore.meta
scoreboard players add @s zx.so_hc 40

execute at @s run particle minecraft:heart ~ ~1.2 ~ 0.3 0.3 0.3 0.02 3 normal
