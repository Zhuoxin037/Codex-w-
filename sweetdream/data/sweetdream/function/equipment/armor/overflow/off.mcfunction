# ============================================================
# sweetdream:equipment/armor/overflow/off —— 摘下「溢流」：撤生命上限
# ============================================================

execute if score @s zx.ov_hp matches 1 run attribute @s minecraft:max_health modifier remove sweetdream:ov_hp
scoreboard players set @s zx.ov_hp 0
