# Executor remains the boss; only the execution position is the safe candidate.
scoreboard players set @s sdk.clear 1
execute facing entity @a[tag=sd.kn.blink_target,distance=0..,limit=1] feet rotated ~ 0 run tp @s ~ ~ ~ ~ 0
scoreboard players set @s sdk.fall 0
scoreboard players set @s sdk.fallsteps 0
execute store result storage fallendream:knight aggro.id int 1 run scoreboard players get @s sdk.id
tag @e[tag=sd.kn.target,distance=0..] remove sd.kn.target
execute as @a[tag=sd.kn.blink_target,distance=0..,limit=1] at @s run function fallendream:boss/knight/target/accept
execute at @s rotated ~ 0 positioned ^ ^ ^-0.84375 run tp @e[tag=sd.kn.current_rig,distance=0..,limit=1] ~ ~ ~ ~ 0
execute as @e[tag=sd.kn.current_rig,distance=0..,limit=1] run function fallendream:boss/knight/blink/apply {clip:"strike",frame:0}
