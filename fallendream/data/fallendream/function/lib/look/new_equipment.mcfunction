# Only player-owned resources/statuses. World objects stay in-world, not fake layers.
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["glimmer"]}] run function fallendream:equipment/armor/glimmer/look_seg
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["late_dusk"]}] if score @s zx.ld_s matches 1.. if score @s zx.ld_t > #now manacore.meta run function fallendream:equipment/armor/late_dusk/look_seg
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["borrow_fire"]}] if score @s zx.bf_rdy matches 1 run function fallendream:equipment/armor/borrow_fire/look_seg
execute if score @s zx.pf_mul matches 1.. if score @s zx.pf_mn matches 1.. run function fallendream:equipment/armor/profile/look_seg
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["ebb_tide"]}] if score @s zx.et_s matches 1.. run function fallendream:equipment/armor/ebb_tide/look_seg

execute at @s run function fallendream:lib/look/owned_objects
