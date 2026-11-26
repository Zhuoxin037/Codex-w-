# Older versions cleared just weapon categories. Also catch the old armor and practice props.
function sweetdream_floor:run/recycle_weapons
function sweetdream:lib/uuid
execute if data storage zx:data self{ok:1b} run data modify storage sweetdream_floor:cleanup weapon.uuid set from storage zx:data self.uuid
function sweetdream_floor:run/recycle_weapon_type {kind:"itemreplace"}
function sweetdream_floor:run/recycle_weapon_type {kind:"look"}
data remove storage sweetdream_floor:cleanup weapon
clear @s minecraft:iron_helmet
clear @s minecraft:iron_chestplate
clear @s minecraft:iron_leggings
clear @s minecraft:iron_boots
tag @s add sd.floor_kit_clean
