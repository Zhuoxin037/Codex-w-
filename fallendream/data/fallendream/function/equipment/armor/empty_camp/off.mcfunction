function fallendream:equipment/armor/empty_camp/clear_attack
# ============================================================
# fallendream:equipment/armor/empty_camp/off —— 摘下「空营」：撤属性
# ============================================================

execute if score @s zx.ec_a matches 1.. run attribute @s minecraft:armor modifier remove fallendream:ec_arm
execute if score @s zx.ec_t matches 1.. run attribute @s minecraft:armor_toughness modifier remove fallendream:ec_tou
scoreboard players set @s zx.ec_a 0
scoreboard players set @s zx.ec_t 0
