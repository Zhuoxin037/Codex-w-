$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
scoreboard players set #tf_set zx.meta 0
execute as @a[tag=zx.ub,limit=1] if items entity @s armor.head *[minecraft:custom_data~{zx:["tide_fold"]}] if items entity @s armor.feet *[minecraft:custom_data~{zx:["ebb_tide"]}] run scoreboard players set #tf_set zx.meta 1
execute unless score #tf_set zx.meta matches 1 run return 0
scoreboard players operation #et_life zx.meta = @s zx.tf_life
execute positioned ^-4 ^ ^ run function sweetdream:equipment/armor/tide_fold/expand_one with storage zx:work tf
execute positioned ^-2 ^ ^ run function sweetdream:equipment/armor/tide_fold/expand_one with storage zx:work tf
function sweetdream:equipment/armor/tide_fold/expand_one with storage zx:work tf
execute positioned ^2 ^ ^ run function sweetdream:equipment/armor/tide_fold/expand_one with storage zx:work tf
execute positioned ^4 ^ ^ run function sweetdream:equipment/armor/tide_fold/expand_one with storage zx:work tf
scoreboard players set @s zx.tf_exp 1
