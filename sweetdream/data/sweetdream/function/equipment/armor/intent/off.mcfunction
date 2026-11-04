# ============================================================
# sweetdream:equipment/armor/intent/off —— 摘下「蓄意」：撤生命上限 + 账本
# ============================================================

execute if score @s zx.it_hp matches 1 run attribute @s minecraft:max_health modifier remove sweetdream:it_hp
scoreboard players set @s zx.it_hp 0
scoreboard players set @s zx.it_sum 0
