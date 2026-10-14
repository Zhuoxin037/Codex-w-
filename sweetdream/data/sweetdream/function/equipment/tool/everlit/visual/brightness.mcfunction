execute if score #el_dim zx.meta matches 0 on vehicle run data merge entity @s {brightness:{block:12,sky:10}}
execute if score #el_dim zx.meta matches 1 on vehicle run data merge entity @s {brightness:{block:11,sky:10}}
execute if score #el_dim zx.meta matches 2 on vehicle run data merge entity @s {brightness:{block:10,sky:9}}
execute if score #el_dim zx.meta matches 3 on vehicle run data merge entity @s {brightness:{block:10,sky:8}}
execute if score #el_dim zx.meta matches 4 on vehicle run data merge entity @s {brightness:{block:9,sky:8}}
execute if score #el_dim zx.meta matches 5 on vehicle run data merge entity @s {brightness:{block:8,sky:8}}
execute if score #el_dim zx.meta matches 6 on vehicle run data merge entity @s {brightness:{block:8,sky:7}}
execute if score #el_dim zx.meta matches 7 on vehicle run data merge entity @s {brightness:{block:7,sky:6}}
execute if score #el_dim zx.meta matches 8 on vehicle run data merge entity @s {brightness:{block:6,sky:6}}
scoreboard players operation @s zx.el_dim = #el_dim zx.meta
