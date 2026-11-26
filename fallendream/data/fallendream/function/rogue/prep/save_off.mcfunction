# Never replace a nonempty hand until a complete snapshot succeeds.
scoreboard players set #rd_off_ok zx.meta 1
$data remove storage zx:rogue p."$(uuid)".prep_off
execute unless items entity @s weapon.offhand * run return 0
kill @e[tag=zx.rg_tmp,distance=0..]
summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.rg_tmp"],Marker:1b,Invisible:1b,NoGravity:1b,Invulnerable:1b,Silent:1b}
item replace entity @e[tag=zx.rg_tmp,distance=0..,limit=1] weapon.mainhand from entity @s weapon.offhand
scoreboard players set #rd_off_ok zx.meta 0
$execute if items entity @e[tag=zx.rg_tmp,distance=0..,limit=1] weapon.mainhand * store success score #rd_off_ok zx.meta run data modify storage zx:rogue p."$(uuid)".prep_off set from entity @e[tag=zx.rg_tmp,distance=0..,limit=1] equipment.mainhand
execute if score #rd_off_ok zx.meta matches 1 run item replace entity @s weapon.offhand with minecraft:air
kill @e[tag=zx.rg_tmp,distance=0..]
