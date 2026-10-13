# ============================================================
# sweetdream:equipment/staff/triad/rename_gun —— 改名「很重的枪」
# ------------------------------------------------------------
# 【执行者】玩家 @s   【谁调它】rename(形态 = 2 时)
# ============================================================

execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["triad"]}] run item modify entity @s weapon.mainhand sweetdream:triad_gun
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["triad"]}] run item modify entity @s weapon.offhand sweetdream:triad_gun
