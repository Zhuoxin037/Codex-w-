# ============================================================
# sweetdream:equipment/staff/triad/rename_ice —— 改名「很冰的斧」
# ------------------------------------------------------------
# 【执行者】玩家 @s   【谁调它】rename(形态 = 0 时)
# 【判据】只认带 custom_data~{zx:["triad"]} 的那把(部分匹配, 全包统一口径)。
# ============================================================

execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["triad"]}] run item modify entity @s weapon.mainhand sweetdream:triad_ice
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["triad"]}] run item modify entity @s weapon.offhand sweetdream:triad_ice
