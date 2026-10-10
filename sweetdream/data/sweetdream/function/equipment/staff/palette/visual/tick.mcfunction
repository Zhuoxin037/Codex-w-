# One cast clock per player; unequipping does not restart or pause the action.
execute as @a[scores={zx.pv_age=0..31}] run scoreboard players add @s zx.pv_age 1
execute as @a[tag=!test_pending_return] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["palette"]}] run function sweetdream:equipment/staff/palette/visual/held
execute as @a[tag=!test_pending_return] unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["palette"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["palette"]}] run function sweetdream:equipment/staff/palette/visual/held
