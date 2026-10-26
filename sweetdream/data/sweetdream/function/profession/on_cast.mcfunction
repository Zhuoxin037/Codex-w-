execute unless entity @s[type=minecraft:player] run return 0
# Save shared outputs: this event may be inside a cooldown API.
execute unless data storage zx:work j_cast_stack run data modify storage zx:work j_cast_stack set value []
data modify storage zx:work j_cast_stack append value {out:{},in:{},self:{}}
data modify storage zx:work j_cast_stack[-1].out set from storage manacore:out r
data modify storage zx:work j_cast_stack[-1].in set from storage manacore:in arg
data modify storage zx:work j_cast_stack[-1].self set from storage zx:data self
function sweetdream:lib/uuid
scoreboard players set @s zx.j_book_t -1
scoreboard players set @s zx.j_sor_t -1
execute if score @s zx.job matches 1 if items entity @s weapon.offhand *[custom_data~{zx:["grimoire"]}] if score @s zx.j_orb matches 1.. run function sweetdream:profession/mage/book
execute if score @s zx.j_sorrow matches 1.. run function sweetdream:profession/mage/sorrow_cast
function sweetdream:profession/singer/cast
data modify storage manacore:out r set from storage zx:work j_cast_stack[-1].out
data modify storage manacore:in arg set from storage zx:work j_cast_stack[-1].in
data modify storage zx:data self set from storage zx:work j_cast_stack[-1].self
data remove storage zx:work j_cast_stack[-1]
