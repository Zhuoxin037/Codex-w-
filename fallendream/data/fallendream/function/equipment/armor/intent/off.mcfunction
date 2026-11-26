# ============================================================
# fallendream:equipment/armor/intent/off —— 摘下「蓄意」：撤生命上限 + 账本
# ------------------------------------------------------------
# 【★ zx.it_hp 门控写 matches 1.. 而不是 matches 1 ★】超限把它当"档位"用
#   (1 = +20% / 2 = +30%), 写死 =1 的话穿超限摘甲永远撤不掉那 +30%。
# 【★ 额外层的 it_hp2 也要撤 ★】它挂在 max_health 上, 不会自己到期。
# ============================================================

execute if score @s zx.it_hp matches 1.. run attribute @s minecraft:max_health modifier remove fallendream:it_hp
execute if score @s zx.it_b_end matches 1.. run attribute @s minecraft:max_health modifier remove fallendream:it_hp2
scoreboard players set @s zx.it_hp 0
scoreboard players set @s zx.it_sum 0
scoreboard players set @s zx.it_a_end 0
scoreboard players set @s zx.it_b_end 0
