$execute unless entity @e[tag=sd.kn.body,scores={sdk.id=$(owner)},distance=0..,limit=1] run return run function sweetdream:boss/knight/wave/end
$execute if entity @e[tag=sd.kn.body,tag=zx.stop,scores={sdk.id=$(owner)},distance=0..,limit=1] run return 0
tag @s add sd.kn.current_wave
$tag @e[tag=sd.kn.body,scores={sdk.id=$(owner)},distance=0..,limit=1] add sd.kn.current_body
scoreboard players operation #aggro sdk.id = @s sdk.owner
data modify storage sweetdream:knight aggro.id set from storage sweetdream:knight wave.owner
execute as @e[tag=sd.kn.current_body,distance=0..,limit=1] at @s run function sweetdream:boss/knight/target/load with storage sweetdream:knight aggro
scoreboard players add @s sdk.age 1
execute at @s run function sweetdream:boss/knight/wave/step
execute if entity @s[tag=sd.kn.wave] at @s run function sweetdream:boss/knight/wave/step
# dup-ok: second collision-tested wave substep
execute if entity @s[tag=sd.kn.wave] at @s run function sweetdream:boss/knight/wave/step
# dup-ok: third collision-tested wave substep
execute if entity @s[tag=sd.kn.wave] at @s run function sweetdream:boss/knight/wave/step
execute if entity @s[tag=sd.kn.wave] if score @s sdk.age matches 36.. run function sweetdream:boss/knight/wave/end
tag @e[tag=sd.kn.current_body,distance=0..] remove sd.kn.current_body
tag @e[tag=sd.kn.target,distance=0..] remove sd.kn.target
tag @s remove sd.kn.current_wave
