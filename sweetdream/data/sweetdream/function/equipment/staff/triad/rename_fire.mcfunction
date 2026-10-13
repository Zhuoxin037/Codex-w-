# ============================================================
# sweetdream:equipment/staff/triad/rename_fire —— 改名「很热的刀」
# ------------------------------------------------------------
# 【执行者】玩家 @s   【谁调它】rename(形态 = 1 时)
# ============================================================

execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["triad"]}] run item modify entity @s weapon.mainhand sweetdream:triad_fire
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["triad"]}] run item modify entity @s weapon.offhand sweetdream:triad_fire
