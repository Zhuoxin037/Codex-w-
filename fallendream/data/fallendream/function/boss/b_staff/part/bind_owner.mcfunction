scoreboard players set #bound bs.ok 0
$execute if entity @e[tag=sd.bs.rig,scores={bs.id=$(id)},distance=0..,limit=1] run ride @s mount @e[tag=sd.bs.rig,scores={bs.id=$(id)},distance=0..,limit=1]
execute on vehicle if entity @s[tag=sd.bs.rig] run scoreboard players set #bound bs.ok 1
execute if score #bound bs.ok matches 1 run tag @s remove sd.bs.unbound
$execute if entity @e[tag=sd.bs.body,scores={bs.id=$(id)},distance=0..,limit=1] run data modify entity @s Rotation set from entity @e[tag=sd.bs.body,scores={bs.id=$(id)},distance=0..,limit=1] Rotation
