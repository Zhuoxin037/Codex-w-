scoreboard players set #count bs.hits 0
scoreboard players set #next bs.next 0
$execute store result score #count bs.hits run data get storage fallendream:b_staff casts."$(owner)"."$(cast)"."$(uuid)".count 1
$execute store result score #next bs.next run data get storage fallendream:b_staff casts."$(owner)"."$(cast)"."$(uuid)".next 1
$scoreboard players set #limit bs.limit $(limit)
$scoreboard players set #now bs.clock $(now)
execute if score #count bs.hits >= #limit bs.limit run return 0
execute if score #now bs.clock < #next bs.next run return 0
scoreboard players add #count bs.hits 1
$scoreboard players set #next bs.next $(interval)
scoreboard players operation #next bs.next += #now bs.clock
$data modify storage fallendream:b_staff casts."$(owner)"."$(cast)"."$(uuid)" set value {count:0,next:0}
$execute store result storage fallendream:b_staff casts."$(owner)"."$(cast)"."$(uuid)".count int 1 run scoreboard players get #count bs.hits
$execute store result storage fallendream:b_staff casts."$(owner)"."$(cast)"."$(uuid)".next int 1 run scoreboard players get #next bs.next
$execute store success score @s bs.ok run damage @s $(amount) fallendream:b_staff_magic by @e[tag=sd.bs.source,distance=0..,limit=1]
execute if score @s bs.ok matches 1 run function fallendream:equipment/tool/retro_shine/from_entity {source:"@e[tag=sd.bs.source,distance=0..,limit=1]"}
