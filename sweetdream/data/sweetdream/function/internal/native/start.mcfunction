# /damage already dispatches these callbacks in internal/damage/one.
execute if data storage zx:work hit_success_stack[-1] run return 0
execute unless data storage zx:config damage_text{enabled:1b} unless items entity @s armor.head *[minecraft:custom_data~{zx:["bright_candle"]}] unless items entity @s armor.chest *[minecraft:custom_data~{zx:["borrow_fire"]}] unless items entity @s armor.legs *[minecraft:custom_data~{zx:["late_dusk"]}] unless items entity @s armor.legs *[minecraft:custom_data~{zx:["profile"]}] run return 0
execute unless data storage zx:work native_stack run data modify storage zx:work native_stack set value []
$data modify storage zx:work native_stack append value {melee:$(melee),charged:0,u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work native_stack[-1].u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage zx:work native_stack[-1].u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage zx:work native_stack[-1].u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage zx:work native_stack[-1].u3 int 1 run scoreboard players get @s manacore.u3
$execute if entity @s[type=minecraft:player] run function sweetdream:internal/native/charge {melee:$(melee)}
function sweetdream:internal/native/scan with storage zx:work native_stack[-1]
data remove storage zx:work native_stack[-1]
