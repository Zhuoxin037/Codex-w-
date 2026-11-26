$tp @e[tag=sd.bs.rig,scores={bs.id=$(id)},distance=0..,limit=1] ~ ~ ~
execute store result score @s bs.yaw run data get entity @s Rotation[0] 100
$execute unless score @s bs.yaw = @s bs.oldyaw as @e[tag=sd.bs.bone,scores={bs.id=$(id)},distance=0..] run data modify entity @s Rotation set from entity @e[tag=sd.bs.body,scores={bs.id=$(id)},distance=0..,limit=1] Rotation
scoreboard players operation @s bs.oldyaw = @s bs.yaw
