kill @e[tag=zx.rg_tmp,distance=0..]
execute at @s run summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.rg_tmp"],Marker:1b,Invisible:1b,NoGravity:1b,Invulnerable:1b,Silent:1b}
$data modify entity @e[tag=zx.rg_tmp,distance=0..,limit=1] equipment.mainhand set from storage zx:rogue p."$(uuid)".q[0]
scoreboard players set #rg_ok zx.meta 0
$execute if items entity @e[tag=zx.rg_tmp,distance=0..,limit=1] weapon.mainhand * unless items entity @s $(slot) * store success score #rg_ok zx.meta run item replace entity @s $(slot) from entity @e[tag=zx.rg_tmp,distance=0..,limit=1] weapon.mainhand
$execute if score #rg_ok zx.meta matches 1 run data remove storage zx:rogue p."$(uuid)".q[0]
kill @e[tag=zx.rg_tmp,distance=0..]
