scoreboard players add @s zx.s2_hp 0
scoreboard players operation #s2_diff zx.meta = #s2_want_hp zx.meta
scoreboard players operation #s2_diff zx.meta -= @s zx.s2_hp
execute unless score #s2_diff zx.meta matches 0 run function fallendream:batch21/apply_hp
scoreboard players add @s zx.s2_atk 0
scoreboard players operation #s2_diff zx.meta = #s2_want_atk zx.meta
scoreboard players operation #s2_diff zx.meta -= @s zx.s2_atk
execute unless score #s2_diff zx.meta matches 0 run function fallendream:batch21/apply_atk
scoreboard players add @s zx.s2_mana 0
scoreboard players operation #s2_diff zx.meta = #s2_want_mana zx.meta
scoreboard players operation #s2_diff zx.meta -= @s zx.s2_mana
execute unless score #s2_diff zx.meta matches 0 run function fallendream:batch21/apply_mana
