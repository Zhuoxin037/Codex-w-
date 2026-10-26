execute if score @s zx.job matches 4 if score @s zx.j_form matches 1 run return 0
execute if items entity @s hotbar.* *[custom_data~{j_protect:1b}] run function sweetdream:profession/twin/unguard
execute if items entity @s inventory.* *[custom_data~{j_protect:1b}] run function sweetdream:profession/twin/unguard
execute if items entity @s weapon.offhand *[custom_data~{j_protect:1b}] run function sweetdream:profession/twin/unguard
