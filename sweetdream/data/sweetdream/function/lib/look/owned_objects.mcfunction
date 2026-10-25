execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["bright_candle"]}] unless items entity @s armor.head *[minecraft:custom_data~{zx:["tide_fold"]}] unless items entity @s armor.chest *[minecraft:custom_data~{zx:["heart_vein"]}] unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["bone_breaker"]}] unless items entity @s armor.legs *[minecraft:custom_data~{zx:["withered_garden"]}] run return 0
execute store result storage zx:work hud_owner.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work hud_owner.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work hud_owner.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work hud_owner.u3 int 1 run scoreboard players get @s manacore.u3
function sweetdream:lib/look/owned_objects_go with storage zx:work hud_owner
