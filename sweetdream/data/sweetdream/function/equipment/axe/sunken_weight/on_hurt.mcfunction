# ============================================================
# sweetdream:equipment/axe/sunken_weight/on_hurt —— 沉砣：受到任何伤害即清零
# ------------------------------------------------------------
# ★ "任何伤害"用 entity_hurt_player 这条通用钩子（含近战/弹射/环境，除真伤以外都覆盖）。
# ★ 不判伤害来源：设计原文是"受到任何伤害时清零"，不区分来源。
# ============================================================
advancement revoke @s only sweetdream:equipment/axe/sunken_weight_hurt

execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["sunken_weight"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sunken_weight"]}] run return 0

execute if score @s zx.sw_n matches 1.. run function sweetdream:equipment/axe/sunken_weight/clear
