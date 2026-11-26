give @s minecraft:cooked_beef 12
give @s minecraft:arrow 32
item replace entity @s armor.head with minecraft:iron_helmet
item replace entity @s armor.chest with minecraft:iron_chestplate
item replace entity @s armor.legs with minecraft:iron_leggings
item replace entity @s armor.feet with minecraft:iron_boots
function sweetdream:equipment/tool/look/give
function sweetdream:equipment/armor/intravenous_pump/give
execute if score @s zx.job matches 1 run function sweetdream:equipment/staff/cage_day/give
execute if score @s zx.job matches 1 run function sweetdream:equipment/sword/tidemark/give
execute if score @s zx.job matches 2 run function sweetdream:equipment/sword/blood_loss/give
execute if score @s zx.job matches 2 run function sweetdream:equipment/sword/tidemark/give
execute if score @s zx.job matches 3 run function sweetdream:equipment/staff/mana_crystal/give
execute if score @s zx.job matches 3 run function sweetdream:equipment/sword/refrain/give
execute if score @s zx.job matches 3 run function sweetdream:equipment/tool/dream_waker/give
execute if score @s zx.job matches 0 run function sweetdream:equipment/sword/tidemark/give
execute if score @s zx.job matches 0 run function sweetdream:equipment/sword/backflow_tide/give
execute if score @s zx.job matches 4 run function sweetdream:equipment/sword/tidemark/give
execute if score @s zx.job matches 4 run function sweetdream:equipment/sword/backflow_tide/give
