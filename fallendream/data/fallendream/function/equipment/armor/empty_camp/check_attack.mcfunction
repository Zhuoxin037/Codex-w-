execute unless score @s zx.ec_badd matches 1.. run return 0
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_camp"],ol:"empty_camp"}] run return run function fallendream:equipment/armor/empty_camp/clear_attack
function fallendream:lib/hp_pct
execute if score #hp_p100 zx.meta matches ..9999 run function fallendream:equipment/armor/empty_camp/clear_attack
