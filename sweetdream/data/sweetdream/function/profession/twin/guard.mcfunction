execute unless score @s zx.j_form matches 1 run return 0
execute unless items entity @s weapon.mainhand * unless items entity @s weapon.offhand * run item replace entity @s weapon.offhand with minecraft:recovery_compass[custom_data={j_temp:1b},item_name={text:"同生体",color:"light_purple"},max_stack_size=1]
execute if items entity @s weapon.mainhand * unless items entity @s weapon.mainhand *[custom_data~{j_protect:1b}] run function sweetdream:profession/twin/guard_hand {hand:"weapon.mainhand",key:"main"}
execute unless items entity @s weapon.mainhand * if items entity @s weapon.offhand * unless items entity @s weapon.offhand *[custom_data~{j_protect:1b}] run function sweetdream:profession/twin/guard_hand {hand:"weapon.offhand",key:"off"}

execute unless items entity @s weapon.mainhand * if items entity @s weapon.offhand *[custom_data~{j_protect:1b}] if score @s zx.j_guard_slot matches 1 run function sweetdream:profession/twin/guard_hand {hand:"weapon.offhand",key:"off"}

execute if score @s zx.j_form matches 1 run function sweetdream:profession/twin/guard_refresh
