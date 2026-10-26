$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @s[tag=zx.ub] run return run effect give @s minecraft:slowness 3 1 true
effect give @s minecraft:speed 3 1 true
execute if score @s zx.tf_mg > #now manacore.meta run return 0
scoreboard players operation @s zx.tf_mg = #now manacore.meta
scoreboard players add @s zx.tf_mg 40
function sweetdream:equipment/armor/tide_fold/regen
