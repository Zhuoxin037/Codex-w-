# Facing changes the command context before teleport; do not reset yaw from the old context.
execute at @s facing entity @e[tag=sd.kn.target,distance=0..,limit=1] feet rotated ~ 0 run tp @s ~ ~ ~ ~ 0
