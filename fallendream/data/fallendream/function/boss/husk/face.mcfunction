# Set facing in the execution context; never restore yaw from its old value.
execute if entity @e[tag=sd.hk.target,distance=0..,limit=1] at @s facing entity @e[tag=sd.hk.target,distance=0..,limit=1] feet rotated ~ 0 run tp @s ~ ~ ~ ~ 0
