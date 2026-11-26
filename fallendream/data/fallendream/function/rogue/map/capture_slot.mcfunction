kill @e[tag=zx.rg_tmp,distance=0..]
summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.rg_tmp"],Marker:1b,Invisible:1b,NoGravity:1b,Invulnerable:1b,Silent:1b}
$item replace entity @e[tag=zx.rg_tmp,distance=0..,limit=1] weapon.mainhand from entity @s $(slot)
$execute unless data storage zx:rogue p."$(uuid)".q run data modify storage zx:rogue p."$(uuid)".q set value []
scoreboard players set #rg_cap zx.meta 0
$execute if items entity @e[tag=zx.rg_tmp,distance=0..,limit=1] weapon.mainhand * store success score #rg_cap zx.meta run data modify storage zx:rogue p."$(uuid)".q append from entity @e[tag=zx.rg_tmp,distance=0..,limit=1] equipment.mainhand
$execute if score #rg_cap zx.meta matches 1 run item replace entity @s $(slot) with minecraft:air
execute if score #rg_cap zx.meta matches 1 run tag @s add zx.rg_pending
kill @e[tag=zx.rg_tmp,distance=0..]
