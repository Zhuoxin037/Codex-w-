# The map may have escrowed items from the map slot and offhand.
data remove storage sweetdream_floor:cleanup weapon
function sweetdream:lib/uuid
execute if data storage zx:data self{ok:1b} run data modify storage sweetdream_floor:cleanup weapon.uuid set from storage zx:data self.uuid
function sweetdream_floor:run/recycle_weapon_type {kind:"sword"}
function sweetdream_floor:run/recycle_weapon_type {kind:"axe"}
function sweetdream_floor:run/recycle_weapon_type {kind:"bow"}
function sweetdream_floor:run/recycle_weapon_type {kind:"staff"}
data remove storage sweetdream_floor:cleanup weapon
tag @s remove sd.floor_kit
tag @s add sd.floor_lobby_weapons_clean
