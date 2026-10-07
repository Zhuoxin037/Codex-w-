# 金色书页光尘；仅在真实命中的灾示事件触发，展示实体数量为零。
particle minecraft:wax_on ~ ~1 ~ 1.1 0.65 1.1 0.02 20 normal
particle minecraft:enchant ~ ~1.2 ~ 1.4 0.6 1.4 0.15 24 normal
playsound minecraft:block.enchantment_table.use player @a[distance=..24] ~ ~ ~ 0.8 1.2
execute if score @s zx.ap_on matches ..3 if score @s zx.apvc matches 3.. run function sweetdream:equipment/staff/apocalypse/visual/world_heavy
