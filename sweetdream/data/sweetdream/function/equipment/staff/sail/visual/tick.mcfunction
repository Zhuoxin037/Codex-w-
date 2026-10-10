# Advance cast clock once per player, even if the item is temporarily unequipped.
execute as @a[scores={zx.sl_vt=1..}] run scoreboard players add @s zx.slva 1
execute as @a[scores={zx.slva=80..}] run scoreboard players set @s zx.slva 0
execute as @a[scores={zx.sl_vt=1}] run scoreboard players add @s zx.slve 1
execute as @a[scores={zx.slve=20..}] run scoreboard players set @s zx.slve 19
execute as @a unless score @s zx.sl_vt matches 1 run scoreboard players set @s zx.slve 0
execute as @a[tag=!test_pending_return] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["sail"]}] run function sweetdream:equipment/staff/sail/visual/held
execute as @a[tag=!test_pending_return] unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["sail"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["sail"]}] run function sweetdream:equipment/staff/sail/visual/held
