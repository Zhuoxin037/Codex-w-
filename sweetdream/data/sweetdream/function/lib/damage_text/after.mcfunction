execute unless data storage zx:work hit_success_stack[-1].float{open:1b} run return 0
data modify storage zx:work hit_success_stack[-1].float.open set value 0b
function sweetdream:lib/damage_text/sample
execute store result score #dt_hp zx.meta run data get storage zx:work hit_success_stack[-1].float.hp
execute store result score #dt_ab zx.meta run data get storage zx:work hit_success_stack[-1].float.ab
scoreboard players operation #dt_hp zx.meta -= @s zx.dt_hp
scoreboard players operation #dt_ab zx.meta -= @s zx.dt_ab
execute if score #dt_hp zx.meta matches ..-1 run scoreboard players set #dt_hp zx.meta 0
execute if score #dt_ab zx.meta matches ..-1 run scoreboard players set #dt_ab zx.meta 0
scoreboard players operation #dt_total zx.meta = #dt_hp zx.meta
scoreboard players operation #dt_total zx.meta += #dt_ab zx.meta
scoreboard players operation #dt_amount zx.meta = #dt_total zx.meta
execute store result score #dt_children zx.meta run data get storage zx:work hit_success_stack[-1].float.children
scoreboard players operation #dt_amount zx.meta -= #dt_children zx.meta
execute if score #dt_amount zx.meta matches 1.. run function sweetdream:lib/damage_text/show
execute unless data storage zx:work hit_success_stack[-2].float{open:1b} run return 0
execute store result score #dt_parent zx.meta run data get storage zx:work hit_success_stack[-2].float.sid
execute unless score #dt_parent zx.meta = @s zx.sid run return 0
execute store result score #dt_parent zx.meta run data get storage zx:work hit_success_stack[-2].float.children
scoreboard players operation #dt_parent zx.meta += #dt_total zx.meta
execute store result storage zx:work hit_success_stack[-2].float.children int 1 run scoreboard players get #dt_parent zx.meta
