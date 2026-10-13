# ============================================================
# sweetdream:equipment/staff/triad/rename —— 按当前形态把武器改成对应的名字
# ------------------------------------------------------------
# 【执行者】玩家 @s
# 【为什么用 item_modifier 而不是 item replace】
#   · item replace 要**重写整个物品**(lore / custom_data / consumable …全得抄一遍),
#     漏一个组件就静默丢功能, 而且 lore 很长、抄错难查;
#   · item_modifier 只改 item_name **一个**组件, 其余原样保留 —— 与本包其余
#     外观类修饰器(angel_core_visual / apocalypse_visual)同一套写法。
# 【★ 主手 + 副手都要改 ★】武器可能被拿在副手(照万念 myriad 的做法: 它切换时
#   两个槽位都判)。只改主手的话, 副手那把会一直显示旧名字。
# 【★ 必须判 custom_data~{zx:["triad"]} ★】不能无脑对手里的东西改名 ——
#   玩家手里可能刚换成别的武器, 那就把别人的名字改掉了。
# ============================================================

execute if score @s zx.tri_form matches 0 run function sweetdream:equipment/staff/triad/rename_ice
execute if score @s zx.tri_form matches 1 run function sweetdream:equipment/staff/triad/rename_fire
execute if score @s zx.tri_form matches 2 run function sweetdream:equipment/staff/triad/rename_gun
