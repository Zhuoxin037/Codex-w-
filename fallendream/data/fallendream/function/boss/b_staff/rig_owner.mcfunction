$execute if entity @e[tag=sd.bs.body,scores={bs.id=$(id)},distance=0..,limit=1] run scoreboard players set #found bs.ok 1
$execute as @e[tag=sd.bs.body,scores={bs.id=$(id)},distance=0..,limit=1] at @s run function fallendream:boss/b_staff/body_tick
