# @s is the actor; position/rotation are still those of the wall.
function sweetdream:lib/entity_id
$data modify storage zx:work tf_pair set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3),id:$(id),nx:$(nx),nz:$(nz),cx:$(cx),cy:$(cy),cz:$(cz),sid:0}
execute store result storage zx:work tf_pair.sid int 1 run scoreboard players get @s zx.sid
scoreboard players set #tf_front zx.meta 0
scoreboard players set #tf_back zx.meta 0
execute positioned ^ ^ ^1000000 if entity @s[distance=..1000000] run scoreboard players set #tf_front zx.meta 1
execute positioned ^ ^ ^-1000000 if entity @s[distance=..1000000] run scoreboard players set #tf_back zx.meta 1
scoreboard players set #tf_side zx.meta 0
execute if score #tf_front zx.meta matches 1 if score #tf_back zx.meta matches 0 run scoreboard players set #tf_side zx.meta 1
execute if score #tf_front zx.meta matches 0 if score #tf_back zx.meta matches 1 run scoreboard players set #tf_side zx.meta -1
function sweetdream:equipment/armor/tide_fold/test_state with storage zx:work tf_pair
