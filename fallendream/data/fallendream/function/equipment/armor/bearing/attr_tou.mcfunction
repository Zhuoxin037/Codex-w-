# 换档时先移除上一档，再按占用数安装本档。
execute if score @s zx.br_t matches 1.. run attribute @s minecraft:armor_toughness modifier remove fallendream:br_tou
scoreboard players operation @s zx.br_t = #br_n zx.meta
execute if score @s zx.br_t matches 1.. store result storage zx:work br_attr.amount int 1 run scoreboard players get @s zx.br_t
execute if score @s zx.br_t matches 1.. run function fallendream:equipment/armor/bearing/add_modifier {attribute:"armor_toughness",modifier:"br_tou"}
